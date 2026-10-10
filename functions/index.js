const {onValueCreated, onValueUpdated, onValueWritten} = require("firebase-functions/v2/database");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onRequest} = require("firebase-functions/v2/https");
const {logger} = require("firebase-functions");
const {initializeApp} = require("firebase-admin/app");
const {getDatabase} = require("firebase-admin/database");
const {getMessaging} = require("firebase-admin/messaging");
const fs = require("fs");
const path = require("path");
const {sendLearningReminder} = require("./learning-reminders");
const {
  Environment,
  OfferDiscountType,
  SignedDataVerifier,
} = require("@apple/app-store-server-library");

initializeApp({
  databaseURL: "https://itquiz-9b027-default-rtdb.firebaseio.com",
});

const db = getDatabase();
const TIME_ZONE = "Asia/Tokyo";
const APP_BUNDLE_ID = "Swift-Beginners-app.it";
const APP_APPLE_ID = 6469339499;
const APPLE_ROOT_CERTIFICATES = [
  "AppleIncRootCertificate.cer",
  "AppleRootCA-G2.cer",
  "AppleRootCA-G3.cer",
].map((file) => fs.readFileSync(path.join(__dirname, "certs", file)));
const APP_STORE_VERIFIERS = [
  {
    environment: Environment.PRODUCTION,
    verifier: new SignedDataVerifier(
        APPLE_ROOT_CERTIFICATES,
        true,
        Environment.PRODUCTION,
        APP_BUNDLE_ID,
        APP_APPLE_ID,
    ),
  },
  {
    environment: Environment.SANDBOX,
    verifier: new SignedDataVerifier(
        APPLE_ROOT_CERTIFICATES,
        true,
        Environment.SANDBOX,
        APP_BUNDLE_ID,
    ),
  },
];
const DATABASE_EVENT_OPTIONS = {
  region: "us-central1",
  memory: "256MiB",
  maxInstances: 3,
};
const SCHEDULE_OPTIONS = {
  region: "us-central1",
  memory: "256MiB",
  maxInstances: 1,
};

const CATEGORY_SETTING = {
  review_due: "learning",
  friend_request: "friends",
  battle_invite: "battles",
  battle_result: "battles",
  weekly_league_warning: "weeklyLeague",
  weekly_league_result: "weeklyLeague",
  guild_reward: "guild",
  guild_raid_started: "guild",
  referral_reward: "friends",
};

const REFERRAL_REWARD_COINS = 5000;

function object(value) {
  return value && typeof value === "object" ? value : {};
}

function number(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

function safeKey(value) {
  return String(value).replace(/[.#$\[\]/]/g, "_").slice(0, 180);
}

function withoutUndefined(value) {
  return Object.fromEntries(Object.entries(value).filter(([, item]) => item !== undefined));
}

async function verifyAppStoreNotification(signedPayload) {
  let lastError;
  for (const candidate of APP_STORE_VERIFIERS) {
    try {
      const payload = await candidate.verifier.verifyAndDecodeNotification(signedPayload);
      return {...candidate, payload};
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError;
}

function appStoreLifecycleType(notificationType, subtype, transaction, previousSummary) {
  if (notificationType === "TEST") return "test";
  if (notificationType === "SUBSCRIBED") {
    return transaction.offerDiscountType === OfferDiscountType.FREE_TRIAL ?
      "trial_started" : "subscription_started";
  }
  if (notificationType === "DID_RENEW") {
    return previousSummary.startedAsTrial && !previousSummary.firstPaidAt ?
      "trial_converted" : "subscription_renewed";
  }
  if (notificationType === "DID_FAIL_TO_RENEW") return "billing_retry_started";
  if (notificationType === "GRACE_PERIOD_EXPIRED") return "grace_period_expired";
  if (notificationType === "EXPIRED") return "subscription_expired";
  if (notificationType === "REFUND") return "subscription_refunded";
  if (notificationType === "REVOKE") return "subscription_revoked";
  if (notificationType === "DID_CHANGE_RENEWAL_STATUS" && subtype === "AUTO_RENEW_DISABLED") {
    return "auto_renew_disabled";
  }
  if (notificationType === "DID_CHANGE_RENEWAL_STATUS" && subtype === "AUTO_RENEW_ENABLED") {
    return "auto_renew_enabled";
  }
  return "subscription_status_changed";
}

/**
 * App Store Server Notifications V2の署名をApple公式ライブラリで検証し、
 * 初回購入・無料体験開始・初回有料更新を別イベントとして保存する。
 */
exports.appStoreServerNotifications = onRequest(
    {region: "us-central1", memory: "256MiB", maxInstances: 3},
    async (request, response) => {
      if (request.method !== "POST") {
        response.set("Allow", "POST").status(405).send("Method Not Allowed");
        return;
      }

      const signedPayload = request.body?.signedPayload;
      if (typeof signedPayload !== "string" || signedPayload.length === 0) {
        response.status(400).send("signedPayload is required");
        return;
      }

      try {
        const verified = await verifyAppStoreNotification(signedPayload);
        const payload = verified.payload;
        const data = object(payload.data);
        const transaction = typeof data.signedTransactionInfo === "string" ?
          await verified.verifier.verifyAndDecodeTransaction(data.signedTransactionInfo) : {};
        const renewal = typeof data.signedRenewalInfo === "string" ?
          await verified.verifier.verifyAndDecodeRenewalInfo(data.signedRenewalInfo) : {};
        const notificationType = payload.notificationType || "UNKNOWN";
        const subtype = payload.subtype || "NONE";
        const notificationID = payload.notificationUUID ||
          `${notificationType}-${payload.signedDate || Date.now()}`;
        const originalTransactionID = transaction.originalTransactionId ||
          renewal.originalTransactionId || transaction.transactionId || notificationID;
        const subscriptionRef = db.ref(
            `subscriptionLifecycle/${safeKey(originalTransactionID)}`,
        );

        const result = await subscriptionRef.transaction((rawValue) => {
          const current = object(rawValue);
          const events = object(current.events);
          const eventKey = safeKey(notificationID);
          if (events[eventKey]) return;

          const previousSummary = object(current.summary);
          const lifecycleType = appStoreLifecycleType(
              notificationType,
              subtype,
              transaction,
              previousSummary,
          );
          const occurredAt = transaction.purchaseDate || payload.signedDate || Date.now();
          const isTrialStart = lifecycleType === "trial_started";
          const summary = withoutUndefined({
            ...previousSummary,
            originalTransactionId: originalTransactionID,
            productId: transaction.productId || renewal.productId || previousSummary.productId,
            appAccountToken: transaction.appAccountToken || renewal.appAccountToken ||
              previousSummary.appAccountToken,
            environment: transaction.environment || renewal.environment || verified.environment,
            startedAsTrial: previousSummary.startedAsTrial || isTrialStart,
            startedAt: previousSummary.startedAt ||
              ((lifecycleType === "trial_started" || lifecycleType === "subscription_started") ?
                occurredAt : undefined),
            firstPaidAt: lifecycleType === "trial_converted" ? occurredAt :
              previousSummary.firstPaidAt,
            lastEventType: lifecycleType,
            lastNotificationType: notificationType,
            lastUpdatedAt: Date.now(),
          });
          const event = withoutUndefined({
            lifecycleType,
            notificationType,
            subtype,
            notificationUUID: payload.notificationUUID,
            transactionId: transaction.transactionId,
            originalTransactionId: originalTransactionID,
            productId: transaction.productId || renewal.productId,
            appAccountToken: transaction.appAccountToken || renewal.appAccountToken,
            transactionReason: transaction.transactionReason,
            offerType: transaction.offerType,
            offerDiscountType: transaction.offerDiscountType,
            priceMilliunits: transaction.price,
            currency: transaction.currency,
            purchaseDate: transaction.purchaseDate,
            expiresDate: transaction.expiresDate,
            autoRenewStatus: renewal.autoRenewStatus,
            environment: transaction.environment || renewal.environment || verified.environment,
            receivedAt: Date.now(),
          });

          return {...current, summary, events: {...events, [eventKey]: event}};
        }, {applyLocally: false});

        if (!result.committed) {
          logger.info("Duplicate App Store notification ignored", {notificationID});
        }
        response.status(200).send("OK");
      } catch (error) {
        logger.error("App Store notification verification failed", {error});
        response.status(400).send("Invalid signedPayload");
      }
    },
);

async function notificationEnabled(uid, type) {
  const setting = CATEGORY_SETTING[type];
  if (!setting) return true;
  const snapshot = await db.ref(`notificationPreferences/${uid}/${setting}`).get();
  return snapshot.val() !== false;
}

async function claimDelivery(uid, type, deliveryKey) {
  const ref = db.ref(`notificationDeliveries/${type}/${uid}/${safeKey(deliveryKey)}`);
  const result = await ref.transaction((current) => {
    if (current !== null) return;
    return Date.now();
  }, {applyLocally: false});
  return {claimed: result.committed, ref};
}

async function tokenRecords(uid) {
  const snapshot = await db.ref(`pushTokens/${uid}`).get();
  const records = [];
  snapshot.forEach((child) => {
    const value = object(child.val());
    if (typeof value.token === "string" && value.token.length > 0) {
      records.push({key: child.key, token: value.token});
    }
  });
  return records;
}

async function sendToUser({uid, type, deliveryKey, title, body, data = {}, expiresAt}) {
  if (!uid || !(await notificationEnabled(uid, type))) return false;

  const records = await tokenRecords(uid);
  if (records.length === 0) return false;

  const delivery = await claimDelivery(uid, type, deliveryKey);
  if (!delivery.claimed) return false;

  const stringData = Object.fromEntries(
      Object.entries({...data, type}).map(([key, value]) => [key, String(value)]),
  );

  try {
    const response = await getMessaging().sendEachForMulticast({
      tokens: records.map((record) => record.token),
      notification: {title, body},
      data: stringData,
      apns: {
        headers: {
          "apns-priority": "10",
          ...(expiresAt ? {"apns-expiration": String(Math.floor(expiresAt / 1000))} : {}),
        },
        payload: {
          aps: {
            sound: "default",
            badge: 1,
            "thread-id": type,
          },
        },
      },
    });

    const removals = {};
    response.responses.forEach((item, index) => {
      const code = item.error?.code;
      if (code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token") {
        removals[`pushTokens/${uid}/${records[index].key}`] = null;
      }
    });
    if (Object.keys(removals).length > 0) await db.ref().update(removals);

    if (response.successCount === 0) {
      await delivery.ref.remove();
      return false;
    }
    // 配信済みの通知がある時間帯は、学習へのお誘いを控える。
    // 記録の失敗で送信済み通知を再送しないよう、配信の成否とは分けて扱う。
    try {
      await db.ref(`notificationDeliveries/recent/${uid}`).transaction(
          (current) => Math.max(number(current), Date.now()), {applyLocally: false},
      );
    } catch (error) {
      logger.warn("Recent push delivery could not be recorded", {uid, error});
    }
    return true;
  } catch (error) {
    await delivery.ref.remove();
    logger.error("Push delivery failed", {uid, type, deliveryKey, error});
    throw error;
  }
}

async function guildMemberIds(guildId) {
  const snapshot = await db.ref(`guilds/${guildId}/members`).get();
  return snapshot.exists() ? Object.keys(object(snapshot.val())) : [];
}

async function sendToGuild(guildId, message) {
  const members = await guildMemberIds(guildId);
  await Promise.all(members.map((uid) => sendToUser({...message, uid})));
}

exports.notifyFriendRequest = onValueCreated(
    {...DATABASE_EVENT_OPTIONS, ref: "/friendRequests/{toUid}/{fromUid}"},
    async (event) => {
      const value = object(event.data.val());
      const fromUid = event.params.fromUid;
      const name = value.name || "冒険者";
      await sendToUser({
        uid: event.params.toUid,
        type: "friend_request",
        deliveryKey: fromUid,
        title: "フレンド申請が届きました",
        body: `${name}さんからフレンド申請が届いています。`,
        data: {fromUid},
      });
    },
);

exports.awardReferralOnFriendship = onValueCreated(
    {...DATABASE_EVENT_OPTIONS, ref: "/friends/{inviteeUid}/{inviterUid}"},
    async (event) => {
      const {inviteeUid, inviterUid} = event.params;
      if (!inviteeUid || !inviterUid || inviteeUid === inviterUid) return;

      const inviteRef = db.ref(`referralInvites/${inviteeUid}`);
      const invite = object((await inviteRef.get()).val());
      if (invite.inviterUid !== inviterUid || invite.status === "rewarded") return;
      if (invite.status !== "pending" && invite.status !== "awarding") return;

      const friends = object((await db.ref(`friends/${inviteeUid}`).get()).val());
      const friendIds = Object.keys(friends);
      if (friendIds.length !== 1 || friendIds[0] !== inviterUid) return;

      const reservation = await inviteRef.transaction((currentValue) => {
        const current = object(currentValue);
        if (current.inviterUid !== inviterUid || current.status === "rewarded") return;
        if (current.status !== "pending" && current.status !== "awarding") return;
        return {
          ...current,
          status: "awarding",
          eligibleAt: number(current.eligibleAt) || Date.now(),
        };
      }, {applyLocally: false});
      if (!reservation.committed) return;

      const rewardId = safeKey(`referral-${inviteeUid}`);
      await Promise.all([
        applyReferralCoins({
          uid: inviterUid,
          rewardId,
          role: "inviter",
          otherUid: inviteeUid,
        }),
        applyReferralCoins({
          uid: inviteeUid,
          rewardId,
          role: "invitee",
          otherUid: inviterUid,
        }),
      ]);

      await inviteRef.update({
        status: "rewarded",
        rewardedAt: Date.now(),
        rewardCoins: REFERRAL_REWARD_COINS,
      });

      await Promise.all([
        sendToUser({
          uid: inviterUid,
          type: "referral_reward",
          deliveryKey: rewardId,
          title: "紹介特典 5,000コイン獲得！",
          body: "招待した友達とフレンドになりました。コインを受け取りました。",
          data: {inviteeUid, rewardCoins: REFERRAL_REWARD_COINS},
        }),
        sendToUser({
          uid: inviteeUid,
          type: "referral_reward",
          deliveryKey: rewardId,
          title: "紹介特典 5,000コイン獲得！",
          body: "招待コードでフレンドになりました。コインを受け取りました。",
          data: {inviterUid, rewardCoins: REFERRAL_REWARD_COINS},
        }),
      ]);
    },
);

async function applyReferralCoins({uid, rewardId, role, otherUid}) {
  const userRef = db.ref(`users/${uid}`);
  const transaction = await userRef.transaction((rawUser) => {
    if (!rawUser || typeof rawUser !== "object") return;
    const user = {...rawUser};
    const claims = object(user.referralRewardClaims);
    if (claims[rewardId]) return;

    user.userMoney = number(user.userMoney) + REFERRAL_REWARD_COINS;
    user.referralRewardClaims = {
      ...claims,
      [rewardId]: {
        amount: REFERRAL_REWARD_COINS,
        role,
        otherUid,
        claimedAt: Date.now(),
      },
    };
    return user;
  }, {applyLocally: false});

  if (!transaction.committed) {
    const user = object((await userRef.get()).val());
    const claims = object(user.referralRewardClaims);
    if (!claims[rewardId]) {
      throw new Error(`Failed to grant referral reward to ${uid}`);
    }
  }
}

exports.notifyBattleStatus = onValueUpdated(
    {...DATABASE_EVENT_OPTIONS, ref: "/battles/{battleId}"},
    async (event) => {
      const beforeBattle = object(event.data.before.val());
      const battle = object(event.data.after.val());
      const before = beforeBattle.status;
      const after = battle.status;
      if (before === after || !after) return;

      const battleId = event.params.battleId;
      if (after === "waiting_opponent") {
        const challengerName = battle.challengerName || "冒険者";
        const category = battleCategoryName(battle.category);
        await sendToUser({
          uid: battle.opponentUid,
          type: "battle_invite",
          deliveryKey: battleId,
          title: `${challengerName}さんから対戦！`,
          body: `${category}の5問クイズが届きました。`,
          data: {battleId},
        });
      } else if (after === "finished") {
        const recipients = [battle.challengerUid, battle.opponentUid].filter(Boolean);
        await Promise.all(recipients.map((uid) => sendToUser({
          uid,
          type: "battle_result",
          deliveryKey: battleId,
          title: "対戦結果が確定しました",
          body: "勝敗と獲得したリーグポイントを確認しよう。",
          data: {battleId},
        })));
      }
    },
);

exports.notifyLeagueResult = onValueCreated(
    {...DATABASE_EVENT_OPTIONS, ref: "/leagueResults/{uid}/{seasonId}"},
    async (event) => {
      const result = object(event.data.val());
      const nextTier = leagueTierName(result.nextTier);
      let title = "週間リーグの結果が確定しました";
      if (result.movement === "promoted") title = `${nextTier}リーグへ昇格！`;
      if (result.movement === "relegated") title = `${nextTier}リーグから再挑戦`;
      const reward = number(result.rewardCoins);
      const body = reward > 0 ? `最終${number(result.rank)}位。${reward}コインを受け取れます。` :
        `最終${number(result.rank)}位。新しいリーグを確認しよう。`;
      await sendToUser({
        uid: event.params.uid,
        type: "weekly_league_result",
        deliveryKey: event.params.seasonId,
        title,
        body,
        data: {seasonId: event.params.seasonId},
      });
    },
);

exports.notifyGuildRaidStarted = onValueWritten(
    {...DATABASE_EVENT_OPTIONS, ref: "/guilds/{guildId}/guildBoss/current"},
    async (event) => {
      const before = object(event.data.before.val());
      const raid = object(event.data.after.val());
      if (raid.status !== "active") return;
      if (before.raidId === raid.raidId && before.status === "active") return;
      const guildId = event.params.guildId;
      const raidId = safeKey(raid.raidId || String(raid.createdAt || Date.now()));
      await sendToGuild(guildId, {
        type: "guild_raid_started",
        deliveryKey: `${guildId}-${raidId}`,
        title: "ギルドボス出現！",
        body: `ボス「${raid.bossName || "謎のボス"}」が現れました。仲間と討伐しよう！`,
        data: {guildId, raidId},
      });
    },
);

exports.notifyGuildRaidCompleted = onValueUpdated(
    {...DATABASE_EVENT_OPTIONS, ref: "/guilds/{guildId}/guildBoss/current"},
    async (event) => {
      const before = object(event.data.before.val());
      const after = object(event.data.after.val());
      if (before.status === "completed" || after.status !== "completed") return;
      const {guildId} = event.params;
      const raidId = safeKey(after.raidId || String(after.createdAt || Date.now()));
      await sendToGuild(guildId, {
        type: "guild_reward",
        deliveryKey: `raid-${raidId}`,
        title: "ギルドボス討伐！",
        body: "討伐完了！ギルド全体で100問正解すると、次のボスが出現します。",
        data: {guildId, raidId},
      });
    },
);

exports.notifyGuildMissionReward = onValueUpdated(
    {...DATABASE_EVENT_OPTIONS, ref: "/guilds/{guildId}/guildProgress"},
    async (event) => {
      const before = object(event.data.before.val());
      const after = object(event.data.after.val());
      const beforeAwards = flattenMissionAwards(object(before.missionAwards));
      const afterAwards = flattenMissionAwards(object(after.missionAwards));
      const newAwardKeys = afterAwards.filter((key) => !beforeAwards.includes(key));
      if (newAwardKeys.length === 0) return;

      const guildId = event.params.guildId;
      await sendToGuild(guildId, {
        type: "guild_reward",
        deliveryKey: `mission-${newAwardKeys.sort().join("+")}`,
        title: "ギルドミッション達成！",
        body: "達成報酬を受け取れます。ギルドを確認しよう。",
        data: {guildId, missionId: newAwardKeys[0]},
      });
    },
);

exports.notifyGuildRankReward = onValueUpdated(
    {...DATABASE_EVENT_OPTIONS, ref: "/guilds/{guildId}/guildProgress"},
    async (event) => {
      const before = object(object(event.data.before.val()).rankAchievements);
      const after = object(object(event.data.after.val()).rankAchievements);
      const newRanks = Object.keys(after).filter((rank) => before[rank] === undefined);
      if (newRanks.length === 0) return;

      const guildId = event.params.guildId;
      const rank = newRanks.sort((a, b) => guildRankOrder(a) - guildRankOrder(b)).at(-1);
      await sendToGuild(guildId, {
        type: "guild_reward",
        deliveryKey: `rank-${rank}`,
        title: `ギルドが${guildRankName(rank)}に到達！`,
        body: "到達報酬を受け取れます。ギルドを確認しよう。",
        data: {guildId, rank},
      });
    },
);

function flattenMissionAwards(awards) {
  const keys = [];
  const lifetime = object(awards.lifetime);
  Object.keys(lifetime).forEach((missionId) => keys.push(`lifetime/${missionId}`));
  const weekly = object(awards.weekly);
  Object.entries(weekly).forEach(([weekId, rawMissions]) => {
    Object.keys(object(rawMissions)).forEach((missionId) => keys.push(`weekly/${weekId}/${missionId}`));
  });
  return keys;
}

exports.sendReviewReminders = onSchedule(
    {...SCHEDULE_OPTIONS, schedule: "*/15 * * * *", timeZone: TIME_ZONE},
    async (event) => {
      const invokedAt = Date.now();
      const scheduledAt = Date.parse(event.scheduleTime);
      const now = Number.isFinite(scheduledAt) ? scheduledAt : invokedAt;
      // 起動が少し遅れても予定枠を使う。大幅に遅れたお誘いは送らない。
      if (invokedAt - now > 10 * 60 * 1000) return;
      const tokenUsers = object((await db.ref("pushTokens").get()).val());
      const uids = Object.keys(tokenUsers);
      await mapLimit(uids, 20, async (uid) => {
        await sendLearningReminder({uid, now, db, sendToUser});
      });
    },
);

exports.sendWeeklyLeagueWarnings = onSchedule(
    {...SCHEDULE_OPTIONS, schedule: "0 20 * * 0", timeZone: TIME_ZONE},
    async () => {
      const seasonId = boundaryWeekId(new Date(), 4);
      const profiles = object((await db.ref("leagueProfiles").get()).val());
      const groupCache = new Map();

      await mapLimit(Object.entries(profiles), 15, async ([uid, rawProfile]) => {
        const profile = object(rawProfile);
        if (profile.currentSeasonId !== seasonId || !profile.currentGroupId) return;
        const cacheKey = `${seasonId}/${profile.currentGroupId}`;
        if (!groupCache.has(cacheKey)) {
          groupCache.set(cacheKey, db.ref(`leagueGroups/${cacheKey}/members`).get());
        }
        const members = rankedMembers(object((await groupCache.get(cacheKey)).val()));
        const rankIndex = members.findIndex((member) => member.uid === uid);
        if (rankIndex < 0) return;

        const rank = rankIndex + 1;
        const tier = profile.currentTier || "bronze";
        const promotion = tier === "master" ? 0 : promotionCount(members.length);
        const relegation = tier === "bronze" ? 0 : relegationCount(members.length);
        const relegationStart = members.length - relegation + 1;
        let body;

        if (promotion > 0 && rank <= promotion + 2) {
          if (rank <= promotion) {
            body = `現在${rank}位、昇格圏です。月曜4時まで順位を守ろう！`;
          } else {
            const target = members[promotion - 1]?.score || 0;
            const needed = Math.max(1, target - members[rankIndex].score + 1);
            body = `現在${rank}位。あと${needed}ポイントで昇格圏です！`;
          }
        } else if (relegation > 0 && rank >= relegationStart - 2) {
          if (rank >= relegationStart) {
            const safeScore = members[relegationStart - 2]?.score || 0;
            const needed = Math.max(1, safeScore - members[rankIndex].score + 1);
            body = `現在${rank}位。あと${needed}ポイントで残留圏です。`;
          } else {
            body = `現在${rank}位。降格ラインが近づいています。月曜4時までに挑戦しよう。`;
          }
        }
        if (!body) return;

        await sendToUser({
          uid,
          type: "weekly_league_warning",
          deliveryKey: seasonId,
          title: "週間リーグ終了まであと8時間",
          body,
          data: {seasonId},
        });
      });
    },
);

exports.finalizeWeeklyLeagues = onSchedule(
    {...SCHEDULE_OPTIONS, schedule: "5 4 * * 1", timeZone: TIME_ZONE, timeoutSeconds: 540},
    async () => {
      const currentSeasonId = boundaryWeekId(new Date(), 4);
      const profiles = object((await db.ref("leagueProfiles").get()).val());
      const groupCache = new Map();

      await mapLimit(Object.entries(profiles), 12, async ([uid, rawProfile]) => {
        const profile = object(rawProfile);
        const seasonId = profile.currentSeasonId;
        const groupId = profile.currentGroupId;
        if (!seasonId || !groupId || seasonId === currentSeasonId) return;

        const resultRef = db.ref(`leagueResults/${uid}/${seasonId}`);
        if ((await resultRef.get()).exists()) return;

        const cacheKey = `${seasonId}/${groupId}`;
        if (!groupCache.has(cacheKey)) {
          groupCache.set(cacheKey, db.ref(`leagueGroups/${cacheKey}/members`).get());
        }
        const members = rankedMembers(object((await groupCache.get(cacheKey)).val()));
        const index = members.findIndex((member) => member.uid === uid);
        const tier = profile.currentTier || "bronze";
        const result = leagueResult(tier, members, index);

        const transaction = await resultRef.transaction((current) => {
          if (current !== null) return;
          return {...result, finalizedAt: Date.now()};
        }, {applyLocally: false});
        if (!transaction.committed) return;
        await db.ref(`leagueProfiles/${uid}`).update({
          currentTier: result.nextTier,
          lastResultSeasonId: seasonId,
        });
      });
    },
);

function rankedMembers(rawMembers) {
  return Object.entries(rawMembers).map(([uid, raw]) => {
    const member = object(raw);
    return {
      uid,
      score: number(member.score),
      scoreReachedAt: number(member.scoreReachedAt) || Number.MAX_SAFE_INTEGER,
      joinedAt: number(member.joinedAt) || Number.MAX_SAFE_INTEGER,
    };
  }).sort((a, b) => b.score - a.score || a.scoreReachedAt - b.scoreReachedAt ||
    a.uid.localeCompare(b.uid));
}

function leagueResult(tier, members, index) {
  if (index < 0) {
    return {tier, rank: Math.max(members.length, 1), score: 0, movement: "stayed",
      nextTier: tier, rewardCoins: 0, rewardClaimed: true};
  }
  const rank = index + 1;
  const promotions = promotionCount(members.length);
  const relegations = relegationCount(members.length);
  const relegationStartsAt = Math.max(members.length - relegations + 1, 1);
  let movement = "stayed";
  let nextTier = tier;
  if (promotions > 0 && rank <= promotions && tier !== "master") {
    movement = "promoted";
    nextTier = promotedTier(tier);
  } else if (relegations > 0 && rank >= relegationStartsAt && tier !== "bronze") {
    movement = "relegated";
    nextTier = relegatedTier(tier);
  }
  let rewardCoins;
  if (tier === "master" && rank <= 3) rewardCoins = 500;
  else if (movement === "promoted") rewardCoins = 300;
  else if (movement === "relegated") rewardCoins = 50;
  else rewardCoins = members[index].score > 0 ? 100 : 0;
  return {tier, rank, score: members[index].score, movement, nextTier, rewardCoins,
    rewardClaimed: rewardCoins === 0};
}

function promotionCount(count) {
  if (count >= 20) return 5;
  if (count >= 10) return 3;
  if (count >= 2) return Math.min(2, count - 1);
  return 0;
}

function relegationCount(count) {
  if (count >= 20) return 5;
  if (count >= 10) return 3;
  return 0;
}

function promotedTier(tier) {
  return {bronze: "silver", silver: "gold", gold: "master", master: "master"}[tier] || "bronze";
}

function relegatedTier(tier) {
  return {bronze: "bronze", silver: "bronze", gold: "silver", master: "gold"}[tier] || "bronze";
}

function leagueTierName(tier) {
  return {bronze: "ブロンズ", silver: "シルバー", gold: "ゴールド", master: "マスター"}[tier] || "ブロンズ";
}

function guildRankName(rank) {
  return {bronze: "ブロンズ", silver: "シルバー", gold: "ゴールド", platinum: "プラチナ",
    diamond: "ダイヤモンド", master: "マスター", legend: "レジェンド"}[rank] || rank;
}

function guildRankOrder(rank) {
  return ["beginner", "bronze", "silver", "gold", "platinum", "diamond", "master", "legend"].indexOf(rank);
}

function battleCategoryName(category) {
  return {itPassport: "ITパスポート", fundamentalInfo: "基本情報", appliedInfo: "応用情報",
    security: "情報セキュリティ"}[category] || category || "クイズ";
}

function boundaryWeekId(date, boundaryHour) {
  const shifted = new Date(date.getTime() + (9 - boundaryHour) * 3600000);
  const day = shifted.getUTCDay() || 7;
  shifted.setUTCDate(shifted.getUTCDate() + 4 - day);
  const yearStart = new Date(Date.UTC(shifted.getUTCFullYear(), 0, 1));
  const week = Math.ceil((((shifted - yearStart) / 86400000) + 1) / 7);
  return `${shifted.getUTCFullYear()}-W${String(week).padStart(2, "0")}`;
}

async function mapLimit(items, limit, operation) {
  for (let index = 0; index < items.length; index += limit) {
    await Promise.all(items.slice(index, index + limit).map(operation));
  }
}
