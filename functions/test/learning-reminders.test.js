const test = require("node:test");
const assert = require("node:assert/strict");
const {reminderSlot, reminderMessage, dueReviewCount, sendLearningReminder} = require("../learning-reminders");

const friday = Date.parse("2026-10-09T20:00:00+09:00");
const uid = "learner";

function harness(values = {}) {
  const sent = [];
  const reads = [];
  return {
    sent, reads,
    run: (now = friday) => sendLearningReminder({
      uid, now,
      db: {ref: (path) => ({get: async () => {
        reads.push(path);
        return {val: () => values[path] ?? null};
      }})},
      sendToUser: async (message) => { sent.push(message); return true; },
    }),
  };
}

test("a full week has exactly two slots, on Tuesday and Friday at the selected hour", () => {
  const start = Date.parse("2026-10-05T00:00:00+09:00");
  const slots = [];
  for (let minutes = 0; minutes < 7 * 24 * 60; minutes += 15) {
    const slot = reminderSlot({}, start + minutes * 60000);
    if (slot) slots.push([slot.historyDateKey, slot.hour]);
  }
  assert.deepEqual(slots, [["2026-10-06", 20], ["2026-10-09", 20]]);
  assert.equal(reminderSlot({reminderHour: 8}, friday), null);
  assert.equal(reminderSlot({reminderHour: 8}, Date.parse("2026-10-09T08:00:00+09:00")).hour, 8);
});

test("local weekdays, fractional offsets, DST and invalid time zones use the right slot", () => {
  assert.equal(reminderSlot({timeZone: "America/Los_Angeles", reminderHour: 23},
      Date.parse("2026-10-07T06:00:00Z")).historyDateKey, "2026-10-06");
  assert.equal(reminderSlot({timeZone: "Asia/Kathmandu"},
      Date.parse("2026-10-09T14:15:00Z")).hour, 20);
  assert.equal(reminderSlot({timeZone: "America/New_York"},
      Date.parse("2026-11-04T01:00:00Z")).historyDateKey, "2026-11-03");
  assert.equal(reminderSlot({timeZone: "invalid/zone"}, friday).hour, 20);
  assert.equal(reminderSlot({reminderHour: null}, friday).hour, 20);
});

test("opt-out, today's learning and the first local reminder suppress regular delivery", async () => {
  for (const pref of [
    {learning: false},
    {lastLearnedAt: friday - 12 * 3600000},
    {initialLearningReminderAt: friday},
  ]) {
    const mock = harness({[`notificationPreferences/${uid}`]: pref});
    assert.equal(await mock.run(), false);
    assert.equal(mock.sent.length, 0);
    assert.equal(mock.reads.length, 1);
  }
  assert.ok(reminderSlot({lastLearnedAt: friday - 86400000}, friday));
  assert.ok(reminderSlot({initialLearningReminderAt: friday - 86400000}, friday));
});

test("existing quiz, dated accuracy and review records also suppress today's invitation", async () => {
  const cases = [
    {[`answers/${uid}`]: {itBasic: {"2026-10-09": 3}}},
    {[`rates/${uid}/_analysisDays/2026-10-09`]: {itBasic: {answer: 3, correct: 2}}},
    {[`ReviewActivity/${uid}/2026-10-09`]: {completedAt: friday - 3600000}},
  ];
  for (const values of cases) {
    const mock = harness(values);
    assert.equal(await mock.run(), false);
    assert.equal(mock.sent.length, 0);
  }
  const yesterday = harness({[`answers/${uid}`]: {itBasic: {"2026-10-08": 3, "2026-10-09": 0}}});
  assert.equal(await yesterday.run(), true);
});

test("an invitation waits at least three hours after another notification", async () => {
  const recent = harness({[`notificationDeliveries/recent/${uid}`]: friday - 2 * 3600000});
  assert.equal(await recent.run(), false);
  const older = harness({[`notificationDeliveries/recent/${uid}`]: friday - 3 * 3600000});
  assert.equal(await older.run(), true);
});

test("learners without due reviews receive a three-question invitation through the compatible route", async () => {
  const mock = harness();
  assert.equal(await mock.run(), true);
  assert.equal(mock.sent.length, 1);
  const message = mock.sent[0];
  assert.equal(message.type, "review_due");
  assert.equal(message.deliveryKey, "20261009");
  assert.deepEqual(message.data, {dueCount: 0, reminderKind: "quick_quiz"});
  assert.equal(message.expiresAt, friday + 3600000);
  assert.match(message.title + message.body, /3問/);
});

test("only actual due reviews select the review invitation", async () => {
  const reviews = {
    due: {quizQuestion: "復習", nextReviewAt: friday - 1},
    future: {quizQuestion: "明日", nextReviewAt: friday + 86400000},
    codexReview1: {quizQuestion: "テスト", nextReviewAt: friday - 1},
    mastered: {quizQuestion: "習得済み", masteredAt: friday - 1},
    legacy: {quizQuestion: "旧データ"},
    invalid: {nextReviewAt: 1},
    invalidDate: {quizQuestion: "壊れた期日", nextReviewAt: "invalid"},
  };
  assert.equal(dueReviewCount(reviews, friday), 2);
  const mock = harness({[`IncorrectAnswers/${uid}`]: reviews});
  assert.equal(await mock.run(), true);
  assert.equal(mock.sent[0].data.reminderKind, "review");
  assert.equal(mock.sent[0].data.dueCount, 2);
  assert.match(mock.sent[0].body, /復習/);
});

test("copy varies across invitations, contains no emoji, and daytime copy never assumes night", () => {
  const titles = new Set();
  const start = Date.parse("2026-10-05T08:00:00+09:00");
  for (let day = 0; day < 35; day++) {
    const now = start + day * 86400000;
    const local = reminderSlot({reminderHour: 8}, now);
    if (!local) continue;
    for (const dueCount of [0, 3]) {
      for (const lastLearnedAt of [0, now - 10 * 86400000]) {
        const message = reminderMessage({local, dueCount, lastLearnedAt, now});
        assert.doesNotMatch(message.title + message.body, /\p{Extended_Pictographic}/u);
        assert.doesNotMatch(message.title + message.body, /寝る前|今日もおつかれさま/);
        titles.add(message.title);
      }
    }
  }
  assert.ok(titles.size >= 5);
});
