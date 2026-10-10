const DEFAULT_TIME_ZONE = "Asia/Tokyo";
const DAY_MS = 24 * 60 * 60 * 1000;
const QUIET_INTERVAL_MS = 3 * 60 * 60 * 1000;

function object(value) {
  return value && typeof value === "object" ? value : {};
}

function localDateParts(timestamp, timeZone) {
  const options = {
    timeZone, year: "numeric", month: "2-digit", day: "2-digit",
    hour: "2-digit", minute: "2-digit", hourCycle: "h23",
  };
  let formatter;
  try {
    formatter = new Intl.DateTimeFormat("en-CA", options);
  } catch {
    formatter = new Intl.DateTimeFormat("en-CA", {...options, timeZone: DEFAULT_TIME_ZONE});
  }
  const parts = Object.fromEntries(formatter.formatToParts(new Date(timestamp))
      .map((part) => [part.type, part.value]));
  const historyDateKey = `${parts.year}-${parts.month}-${parts.day}`;
  return {
    dateKey: `${parts.year}${parts.month}${parts.day}`,
    historyDateKey,
    weekday: new Date(`${historyDateKey}T00:00:00Z`).getUTCDay(),
    hour: Number(parts.hour),
    minute: Number(parts.minute),
  };
}

function isSameDay(timestamp, local, timeZone) {
  return Number.isFinite(Number(timestamp)) && Number(timestamp) > 0 &&
    localDateParts(Number(timestamp), timeZone).dateKey === local.dateKey;
}

function reminderSlot(preferences, now) {
  if (preferences.learning === false) return null;
  const timeZone = preferences.timeZone || DEFAULT_TIME_ZONE;
  const local = localDateParts(now, timeZone);
  const configuredHour = preferences.reminderHour;
  const hour = Number.isInteger(configuredHour) ? Math.min(Math.max(configuredHour, 6), 23) : 20;
  // 火曜・金曜の週2回。半時間・45分の時差も、現地の設定時刻ちょうどに扱う。
  if (![2, 5].includes(local.weekday) || local.hour !== hour || local.minute !== 0) return null;
  if (isSameDay(preferences.lastLearnedAt, local, timeZone) ||
      isSameDay(preferences.initialLearningReminderAt, local, timeZone)) return null;
  return {...local, timeZone};
}

function hasLearnedToday(answers, rates, reviewActivity, local) {
  return Object.values(object(answers)).some((days) => Number(object(days)[local.historyDateKey]) > 0) ||
    Object.values(object(rates)).some((counts) => Number(object(counts).answer) > 0) ||
    Number(object(reviewActivity).completedAt) > 0;
}

function dueReviewCount(answers, now) {
  return Object.entries(object(answers)).filter(([key, raw]) => {
    const value = object(raw);
    // テスト用・習得済み・不正なレコードを文面に含めない。旧データの期日なしは復習対象。
    return !key.startsWith("codexReview") && typeof value.quizQuestion === "string" &&
      !value.masteredAt && Number(value.nextReviewAt ?? 0) <= now;
  }).length;
}

function reminderMessage({local, dueCount, lastLearnedAt, now}) {
  if (dueCount > 0) {
    return {
      title: "前に間違えた問題、今なら解けるかも",
      body: "少しだけ復習してみよう。ホームからすぐに始められます。",
      kind: "review",
    };
  }
  // 日付に応じて文面を変え、同じ配信の再試行では変えない。
  const day = Math.floor(Date.parse(`${local.historyDateKey}T00:00:00Z`) / DAY_MS);
  const week = Math.floor((day + 3) / 7);
  const index = ((week * 2 + (local.weekday === 5 ? 1 : 0)) % 4 + 4) % 4;
  const messages = [
    {title: "すきま時間に3問", body: "クイズで今日の知識を少し増やそう。"},
    {title: local.hour >= 18 ? "今日もおつかれさま" : "ちょっとひと息、クイズを3問",
      body: "ひと息つきながら、クイズを3問どうですか？"},
    {title: "3問だけ、気軽に挑戦", body: "知っていることを確かめながら、少しだけ学んでみよう。"},
    {title: "クイズを3問やってみよう", body: "今日の小さな発見を、次の冒険につなげよう。"},
  ];
  if (index === 3 && Number(lastLearnedAt) > 0 && now - Number(lastLearnedAt) >= 7 * DAY_MS) {
    return {title: "また3問から始めよう", body: "自分のペースで大丈夫。気軽にクイズを楽しもう。", kind: "quick_quiz"};
  }
  return {...messages[index], kind: "quick_quiz"};
}

async function sendLearningReminder({uid, now, db, sendToUser}) {
  const read = async (path) => (await db.ref(path).get()).val();
  const preferences = object(await read(`notificationPreferences/${uid}`));
  const local = reminderSlot(preferences, now);
  if (!local) return false;

  const [answers, rates, reviewActivity, recentDeliveryAt] = await Promise.all([
    read(`answers/${uid}`),
    read(`rates/${uid}/_analysisDays/${local.historyDateKey}`),
    read(`ReviewActivity/${uid}/${local.historyDateKey}`),
    read(`notificationDeliveries/recent/${uid}`),
  ]);
  if (hasLearnedToday(answers, rates, reviewActivity, local)) return false;
  if (Number(recentDeliveryAt) > now - QUIET_INTERVAL_MS) return false;

  const reviews = await read(`IncorrectAnswers/${uid}`);
  const dueCount = dueReviewCount(reviews, now);
  const message = reminderMessage({local, dueCount, lastLearnedAt: preferences.lastLearnedAt, now});
  // 旧バージョンもホームの学習へ進める既存typeと、日単位の重複防止キーを維持する。
  return sendToUser({
    uid, type: "review_due", deliveryKey: local.dateKey,
    title: message.title, body: message.body,
    expiresAt: now + 60 * 60 * 1000,
    data: {dueCount, reminderKind: message.kind},
  });
}

module.exports = {localDateParts, reminderSlot, hasLearnedToday, dueReviewCount, reminderMessage, sendLearningReminder};
