# Brainstorm: JobHunter AI — Agentic Job Search & Application Platform
**Date**: 2026-03-18
**Type**: Feature ideation + product design
**Tech Stack**: Flutter, Firebase, Firebase Functions

## Central Question
How do we build an **agentic job hunting system** that crawls jobs, matches them to the user's profile, generates tailored application materials, and gamifies the entire process — all from the applicant's perspective?

---

## Mind Map

```
                         ┌─── Job Crawling & Aggregation
                         │    ├── Multi-source (LinkedIn, Indeed, Adzuna, RemoteOK)
                         │    ├── User-defined search criteria
                         │    ├── Deduplication across sources
                         │    └── Freshness tracking & expiry
                         │
                         ├─── Smart Matching Engine
                         │    ├── Skills overlap scoring
                         │    ├── Experience level fit
                         │    ├── Salary range alignment
                         │    ├── Location/remote preference
                         │    └── Company culture signals
                         │
    [JOBHUNTER AI]  ─────├─── AI Content Generation
                         │    ├── Cover letter (tailored per job)
                         │    ├── Intro/cold outreach messages
                         │    ├── Resume bullet point suggestions
                         │    └── Interview prep questions
                         │
                         ├─── Application Pipeline
                         │    ├── Save → Apply → Interview → Offer/Reject
                         │    ├── Status tracking with timestamps
                         │    ├── Notes & follow-up reminders
                         │    └── Analytics (conversion funnel)
                         │
                         ├─── Gamification Layer
                         │    ├── XP & Levels (Job Seeker → Job Master)
                         │    ├── Daily/Weekly streaks
                         │    ├── Achievement badges
                         │    ├── Weekly challenges
                         │    └── Profile completeness as first quest
                         │
                         └─── User Profile & Preferences
                              ├── Resume data (skills, experience, education)
                              ├── Target role preferences
                              ├── Salary expectations
                              └── Job search intensity setting
```

---

## Deep Dive: Edge Cases & Solutions

### Job Crawling Edge Cases
| Edge Case | Impact | Solution |
|-----------|--------|----------|
| Duplicate jobs from multiple sources | Cluttered dashboard | Dedup by title+company+location hash |
| Expired/filled positions | Wasted applications | TTL on jobs, re-verify before apply |
| Rate limiting from job APIs | Crawling fails | Exponential backoff, queue-based crawling |
| Incomplete job descriptions | Poor AI generation | Flag incomplete, ask user for context |
| Fake/spam job postings | Trust erosion | Source reputation scoring, user flagging |
| Jobs requiring work authorization | Irrelevant results | User preference filter |

### AI Generation Edge Cases
| Edge Case | Impact | Solution |
|-----------|--------|----------|
| User profile too sparse | Generic output | Require minimum profile completeness (60%) before generation |
| Job description is vague | Poor tailoring | Generate best-effort + highlight assumptions |
| Cover letter sounds robotic | Rejection | Multiple tone options (professional, casual, enthusiastic) |
| Same cover letter for similar jobs | Lazy applications | Force variation, track similarity scores |
| ATS keyword optimization | Parsed out | Include keyword extraction and ATS scoring |

### Application Tracking Edge Cases
| Edge Case | Impact | Solution |
|-----------|--------|----------|
| User applies outside the app | Incomplete tracking | Manual "mark as applied" option |
| No response from company | Stuck in limbo | Auto-archive after 30 days, ghost detection |
| Multiple rounds of interviews | Complex status | Sub-statuses: phone screen, technical, onsite, final |
| Salary negotiation tracking | Missing data | Optional salary tracking per application |

### Gamification Edge Cases
| Edge Case | Impact | Solution |
|-----------|--------|----------|
| Gaming the system (spam applications) | Quality drops | Quality multipliers (match score > 70% = 2x XP) |
| Streak anxiety | User stress | "Streak freeze" items, grace periods |
| New user overwhelm | Drop-off | Guided onboarding quest chain |
| No jobs in user's niche | Can't earn XP | Award XP for profile improvement, not just applications |

---

## Deep Dive: Gamification Design

### XP System
```
Action                          XP      Condition
──────────────────────────────────────────────────────
Complete profile section        50      Per section
Daily login                     10      Once per day
Save a job                      5       Max 20/day
Apply to a job                  25      Match > 50%
Apply to high-match job         50      Match > 80%
Customize cover letter          15      After generation
Send intro message              20      -
Update application status       10      -
Receive interview               100     Manual input
Receive offer                   500     Manual input
Complete weekly challenge       200     -
```

### Level System
```
Level 1:  Job Seeker          0 XP
Level 2:  Active Hunter       500 XP
Level 3:  Application Pro     1,500 XP
Level 4:  Interview Ready     3,500 XP
Level 5:  Career Warrior      7,000 XP
Level 6:  Job Master          15,000 XP
Level 7:  Hiring Magnet       30,000 XP
```

### Achievements (Badges)
- 🎯 **First Blood** — Apply to your first job
- 📝 **Wordsmith** — Generate 10 cover letters
- 🔥 **On Fire** — 7-day application streak
- 💯 **Perfect Match** — Apply to a 95%+ match job
- 🏆 **Interview Champion** — Get 5 interviews
- 🎓 **Profile Master** — 100% profile completeness
- 📨 **Networker** — Send 20 intro messages
- 🚀 **Quick Draw** — Apply within 1 hour of job posting
- 🌍 **Explorer** — Apply to jobs in 5 different cities
- 💎 **Diamond Hands** — Maintain 30-day streak

### Weekly Challenges (rotating)
- "Apply to 5 jobs with 70%+ match"
- "Customize 3 cover letters"
- "Update your profile with new skills"
- "Send 5 intro messages"
- "Research 3 companies"

---

## Deep Dive: Architecture

### Data Flow
```
┌──────────────────────────────────────────────────────────┐
│                    Flutter Frontend                        │
│  ┌──────┐  ┌──────────┐  ┌────────┐  ┌───────────────┐  │
│  │ Auth │  │ Profile   │  │ Jobs   │  │ Gamification  │  │
│  │Screen│  │ Setup     │  │Dashboard│  │ Dashboard     │  │
│  └──┬───┘  └────┬─────┘  └───┬────┘  └──────┬────────┘  │
│     │           │             │               │           │
│     └───────────┴─────────────┴───────────────┘           │
│                         │                                  │
│              Riverpod State Management                     │
│                         │                                  │
│              Firebase SDK / Cloud Functions                 │
└─────────────────────────┼──────────────────────────────────┘
                          │
┌─────────────────────────┼──────────────────────────────────┐
│                   Firebase Backend                          │
│                         │                                   │
│  ┌──────────────────────┼────────────────────────────┐     │
│  │           Cloud Functions (TypeScript)              │     │
│  │  ┌─────────┐  ┌───────────┐  ┌──────────────┐    │     │
│  │  │Job      │  │AI Content │  │Gamification  │    │     │
│  │  │Crawler  │  │Generator  │  │Engine        │    │     │
│  │  │(Scheduled│  │(Gemini API)│  │(XP/Achieve)  │    │     │
│  │  │+ OnCall)│  │           │  │              │    │     │
│  │  └────┬────┘  └─────┬─────┘  └──────┬───────┘    │     │
│  └───────┼─────────────┼───────────────┼─────────────┘     │
│          │             │               │                    │
│  ┌───────┴─────────────┴───────────────┴─────────────┐     │
│  │                  Firestore                          │     │
│  │  users/ jobs/ applications/ achievements/           │     │
│  │  cover_letters/ weekly_challenges/                   │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌────────────────┐  ┌────────────────┐                     │
│  │  Firebase Auth  │  │ Cloud Storage  │                     │
│  │  (Email/Google) │  │ (Resumes/Docs) │                     │
│  └────────────────┘  └────────────────┘                     │
└──────────────────────────────────────────────────────────────┘
```

### Firestore Schema
```
users/{uid}
  ├── profile: { name, email, headline, summary, photoUrl }
  ├── skills: [string]
  ├── experience: [{ title, company, startDate, endDate, description }]
  ├── education: [{ school, degree, field, year }]
  ├── preferences: { roles[], locations[], salaryMin, salaryMax, remote, jobTypes[] }
  ├── gamification: { xp, level, currentStreak, longestStreak, lastActiveDate }
  └── settings: { searchIntensity, notifications }

jobs/{jobId}
  ├── title, company, location, description
  ├── salary: { min, max, currency }
  ├── type: full-time|part-time|contract|internship
  ├── remote: remote|hybrid|onsite
  ├── source: adzuna|remoteok|indeed|manual
  ├── sourceUrl, postedAt, expiresAt
  ├── requirements: [string]
  └── companyLogo, companyUrl

users/{uid}/applications/{appId}
  ├── jobId, status: saved|applied|interviewing|offered|rejected|ghosted
  ├── coverLetterId, introMessageId
  ├── appliedAt, statusUpdates: [{ status, at, note }]
  └── notes

users/{uid}/cover_letters/{clId}
  ├── jobId, content, tone
  ├── atsScore, version
  └── createdAt

users/{uid}/achievements/{achieveId}
  ├── type, unlockedAt
  └── metadata

weekly_challenges/{challengeId}
  ├── title, description, criteria
  ├── xpReward, startDate, endDate
  └── participants: { uid: { progress, completed } }
```

---

## Synthesis

### Key Insights
1. **Agentic = Proactive**: The system should surface jobs, not wait for search. Scheduled crawling + push notifications.
2. **Quality > Quantity**: Gamification must reward quality applications (high match score), not spam.
3. **Profile is the Foundation**: Everything depends on a rich user profile. Make profile completion the first "quest."
4. **AI needs guardrails**: Generated content should be editable, versionable, and never auto-sent.
5. **Ghost detection is key UX**: Most applicants suffer from "application black holes." Auto-detecting ghosting and suggesting follow-ups is a differentiator.

### Decision Points
- **Job Source APIs**: Start with Adzuna (free tier) + RemoteOK (free) + manual input. Add more later.
- **AI Provider**: Gemini API (Firebase integration is native).
- **State Management**: Riverpod (testable, scalable).
- **Monetization (future)**: Premium tier for unlimited AI generations, more sources, priority crawling.

### Next Steps → Implementation
See `.gstack/solve/artifacts/plan-output.md` for the full implementation plan.
