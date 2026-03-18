import * as admin from "firebase-admin";

const XP_REWARDS: Record<string, number> = {
  job_saved: 5,
  job_applied: 25,
  job_applied_high_match: 50,
  cover_letter_generated: 15,
  intro_message_sent: 20,
  status_update: 10,
  interview_received: 100,
  offer_received: 500,
  daily_login: 10,
};

const LEVEL_THRESHOLDS = [0, 500, 1500, 3500, 7000, 15000, 30000];

export async function calculateXp(
  userId: string,
  action: string,
  metadata: Record<string, any>
): Promise<void> {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(userId);

  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) return;

    const data = userDoc.data()!;
    const gamification = data.gamification || {
      xp: 0,
      level: 1,
      currentStreak: 0,
      longestStreak: 0,
      lastActiveDate: null,
      unlockedAchievements: [],
    };

    let xpReward = XP_REWARDS[action] || 0;

    if (action === "status_update") {
      if (metadata.newStatus === "interviewing") xpReward = XP_REWARDS.interview_received;
      if (metadata.newStatus === "offered") xpReward = XP_REWARDS.offer_received;
    }

    if (action === "job_applied" && metadata.matchScore >= 80) {
      xpReward = XP_REWARDS.job_applied_high_match;
    }

    const newXp = gamification.xp + xpReward;

    let newLevel = gamification.level;
    while (newLevel < LEVEL_THRESHOLDS.length && newXp >= LEVEL_THRESHOLDS[newLevel]) {
      newLevel++;
    }

    const today = new Date().toISOString().split("T")[0];
    let newStreak = gamification.currentStreak;

    if (gamification.lastActiveDate) {
      const lastDate = new Date(gamification.lastActiveDate);
      const daysDiff = Math.floor(
        (Date.now() - lastDate.getTime()) / 86400000
      );

      if (daysDiff === 1) {
        newStreak++;
      } else if (daysDiff > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    const longestStreak = Math.max(newStreak, gamification.longestStreak || 0);

    transaction.update(userRef, {
      "gamification.xp": newXp,
      "gamification.level": newLevel,
      "gamification.currentStreak": newStreak,
      "gamification.longestStreak": longestStreak,
      "gamification.lastActiveDate": today,
    });
  });
}
