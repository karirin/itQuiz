const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const {createRequire} = require("node:module");

// 本番の配信処理を使い、FirebaseとFCMだけをメモリ内に置き換える。実際の送信は行わない。
function deliveryHarness({failRecentWrite = false, successCount = 1, learning = true, now = Date.now()} = {}) {
  const file = path.join(__dirname, "../index.js");
  const localRequire = createRequire(file);
  const values = new Map([
    ["notificationPreferences/learner", {learning}],
    ["notificationPreferences/learner/learning", learning],
    ["pushTokens", {learner: {phone: {token: "test-token"}}}],
    ["pushTokens/learner", {phone: {token: "test-token"}}],
  ]);
  const sent = [];
  const db = {ref: (location = "") => ({
    get: async () => ({
      val: () => values.get(location) ?? null,
      forEach: (visit) => Object.entries(values.get(location) ?? {})
          .forEach(([key, value]) => visit({key, val: () => value})),
    }),
    transaction: async (change) => {
      if (failRecentWrite && location.startsWith("notificationDeliveries/recent/")) {
        throw new Error("Test write failure");
      }
      const next = change(values.get(location) ?? null);
      if (next === undefined) return {committed: false};
      values.set(location, next);
      return {committed: true};
    },
    remove: async () => { values.delete(location); },
    update: async (updates) => {
      for (const [key, value] of Object.entries(updates)) values.set(key, value);
    },
  })};
  const handler = (_options, callback) => callback;
  const modules = {
    "firebase-functions/v2/database": {onValueCreated: handler, onValueUpdated: handler, onValueWritten: handler},
    "firebase-functions/v2/scheduler": {onSchedule: handler},
    "firebase-functions/v2/https": {onRequest: handler},
    "firebase-functions": {logger: {info() {}, warn() {}, error() {}}},
    "firebase-admin/app": {initializeApp() {}},
    "firebase-admin/database": {getDatabase: () => db},
    "firebase-admin/messaging": {getMessaging: () => ({sendEachForMulticast: async (message) => {
      sent.push(message);
      return {successCount, responses: [{success: successCount > 0}]};
    }})},
    "@apple/app-store-server-library": {
      Environment: {PRODUCTION: "production", SANDBOX: "sandbox"},
      OfferDiscountType: {}, SignedDataVerifier: class {},
    },
  };
  const context = {
    require: (name) => modules[name] ?? localRequire(name),
    __dirname: path.dirname(file), exports: {}, process,
    Date: class extends Date { static now() { return now; } },
  };
  vm.runInNewContext(fs.readFileSync(file, "utf8") + "\nexports.testSendToUser = sendToUser;", context);
  const send = () => context.exports.testSendToUser({
    uid: "learner", type: "review_due", deliveryKey: "20261009",
    title: "すきま時間に3問", body: "今日の知識を少し増やそう。",
    data: {dueCount: 0, reminderKind: "quick_quiz"}, expiresAt: 1791547200000,
  });
  return {send, sent, values, runSchedule: context.exports.sendReviewReminders};
}

test("concurrent/retried deliveries send once and preserve the compatible data and expiry", async () => {
  const mock = deliveryHarness();
  const outcomes = await Promise.all([mock.send(), mock.send()]);
  assert.equal(outcomes.filter(Boolean).length, 1);
  assert.equal(mock.sent.length, 1);
  assert.equal(mock.sent[0].data.type, "review_due");
  assert.equal(mock.sent[0].data.reminderKind, "quick_quiz");
  assert.equal(mock.sent[0].data.dueCount, "0");
  assert.equal(mock.sent[0].apns.headers["apns-expiration"], "1791547200");
  assert.ok(mock.values.get("notificationDeliveries/recent/learner") > 0);
  assert.equal(await mock.send(), false);
});

test("a failed recent-delivery write never retries an already sent notification", async () => {
  const mock = deliveryHarness({failRecentWrite: true});
  assert.equal(await mock.send(), true);
  assert.equal(await mock.send(), false);
  assert.equal(mock.sent.length, 1);
});

test("a delivery that reaches no devices releases the receipt for a later retry", async () => {
  const mock = deliveryHarness({successCount: 0});
  assert.equal(await mock.send(), false);
  assert.equal(mock.values.has("notificationDeliveries/review_due/learner/20261009"), false);
  assert.equal(mock.values.has("notificationDeliveries/recent/learner"), false);
});

test("the final send checks opt-out again", async () => {
  const mock = deliveryHarness({learning: false});
  assert.equal(await mock.send(), false);
  assert.equal(mock.sent.length, 0);
});

test("a slightly delayed scheduler still sends the intended slot once", async () => {
  const scheduleTime = "2026-10-09T11:00:00Z";
  const mock = deliveryHarness({now: Date.parse(scheduleTime) + 2 * 60000});
  await mock.runSchedule({scheduleTime});
  await mock.runSchedule({scheduleTime});
  assert.equal(mock.sent.length, 1);
  assert.equal(mock.sent[0].data.reminderKind, "quick_quiz");
});

test("a stale scheduled job cannot send at an unexpected hour", async () => {
  const scheduleTime = "2026-10-09T11:00:00Z";
  const mock = deliveryHarness({now: Date.parse(scheduleTime) + 60 * 60000});
  await mock.runSchedule({scheduleTime});
  assert.equal(mock.sent.length, 0);
});
