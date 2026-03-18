import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { crawlJobs as crawlJobsImpl } from "./crawlers/job_crawler";
import { generateCoverLetter as genCoverLetterImpl } from "./ai/cover_letter_generator";
import { generateIntroMessage as genIntroMessageImpl } from "./ai/intro_message_generator";
import { calculateXp } from "./gamification/xp_engine";
import { matchJobs as matchJobsImpl } from "./matching/job_matcher";

admin.initializeApp();

export const crawlJobs = functions.https.onCall(async (request) => {
  const { roles, locations, jobTypes, remote } = request.data;
  const userId = request.auth?.uid;
  if (!userId) throw new functions.https.HttpsError("unauthenticated", "Login required");

  const jobs = await crawlJobsImpl({ roles, locations, jobTypes, remote });

  const db = admin.firestore();
  const batch = db.batch();
  for (const job of jobs) {
    const ref = db.collection("jobs").doc(job.id);
    batch.set(ref, job, { merge: true });
  }
  await batch.commit();

  return { count: jobs.length };
});

export const generateCoverLetter = functions.https.onCall(async (request) => {
  const userId = request.auth?.uid;
  if (!userId) throw new functions.https.HttpsError("unauthenticated", "Login required");

  const result = await genCoverLetterImpl(request.data);
  return result;
});

export const generateIntroMessage = functions.https.onCall(async (request) => {
  const userId = request.auth?.uid;
  if (!userId) throw new functions.https.HttpsError("unauthenticated", "Login required");

  const result = await genIntroMessageImpl(request.data);
  return result;
});

export const onApplicationCreated = functions.firestore
  .document("users/{userId}/applications/{appId}")
  .onCreate(async (snap, context) => {
    const { userId } = context.params;
    await calculateXp(userId, "job_saved", {});
  });

export const onApplicationUpdated = functions.firestore
  .document("users/{userId}/applications/{appId}")
  .onUpdate(async (change, context) => {
    const { userId } = context.params;
    const before = change.before.data();
    const after = change.after.data();

    if (before.status !== after.status) {
      await calculateXp(userId, "status_update", {
        newStatus: after.status,
        matchScore: after.matchScore || 0,
      });
    }
  });

export const scheduledCrawl = functions.pubsub
  .schedule("every 6 hours")
  .onRun(async () => {
    const db = admin.firestore();
    const usersSnap = await db.collection("users")
      .where("preferences.targetRoles", "!=", [])
      .limit(50)
      .get();

    for (const userDoc of usersSnap.docs) {
      const prefs = userDoc.data().preferences;
      if (prefs?.targetRoles?.length > 0) {
        try {
          const jobs = await crawlJobsImpl({
            roles: prefs.targetRoles,
            locations: prefs.locations || [],
            jobTypes: prefs.jobTypes || [],
            remote: prefs.remotePreference || [],
          });

          const batch = db.batch();
          for (const job of jobs) {
            batch.set(db.collection("jobs").doc(job.id), job, { merge: true });
          }
          await batch.commit();
        } catch (err) {
          console.error(`Crawl failed for user ${userDoc.id}:`, err);
        }
      }
    }
  });

export const matchJobsForUser = functions.https.onCall(async (request) => {
  const userId = request.auth?.uid;
  if (!userId) throw new functions.https.HttpsError("unauthenticated", "Login required");

  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) throw new functions.https.HttpsError("not-found", "User not found");

  const profile = userDoc.data()!;
  const jobsSnap = await db.collection("jobs").orderBy("postedAt", "desc").limit(100).get();

  const scored = jobsSnap.docs.map((doc) => {
    const job = doc.data();
    const score = matchJobsImpl(job, profile);
    return { id: doc.id, ...job, matchScore: score };
  });

  scored.sort((a: any, b: any) => b.matchScore - a.matchScore);
  return { jobs: scored.slice(0, 50) };
});
