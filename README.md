# JobHunter AI

An agentic job search and application platform built with Flutter, Firebase, and Firebase Cloud Functions. Crawls jobs from multiple sources, matches them to your profile, generates AI-powered cover letters and intro messages, and gamifies the entire job hunt.

## Features

### Job Crawling & Smart Matching
- Multi-source job aggregation (RemoteOK, Adzuna API, manual input)
- Intelligent matching algorithm scoring jobs 0-100% against your profile
- Filters by job type, remote preference, location, and salary
- Automatic deduplication across sources
- Scheduled crawling via Cloud Functions (every 6 hours)

### AI Content Generation
- **Cover Letters** — Tailored per job, with 3 tone options (professional, enthusiastic, casual)
- **Intro Messages** — Short networking messages for LinkedIn or cold email
- ATS compatibility scoring on generated cover letters
- Edit, copy, and share generated content
- Falls back to smart template generation when Cloud Functions aren't deployed

### Application Tracker
- Full pipeline: Saved → Applied → Interviewing → Offered / Rejected / Ghosted
- Ghost detection — flags applications with no response after 30 days
- Status history with timestamps and notes
- Application funnel analytics

### Gamification
- **XP System** — Earn XP for every action (saving jobs, applying, getting interviews)
- **7 Levels** — Job Seeker → Active Hunter → Application Pro → Interview Ready → Career Warrior → Job Master → Hiring Magnet
- **12 Achievement Badges** — First Blood, Wordsmith, On Fire, Perfect Match, Diamond Hands, and more
- **Daily Streaks** — Track consecutive active days
- **Quality Multipliers** — High-match applications (80%+) earn 2x XP
- **Profile Completeness** — First "quest" to complete your profile

### User Profile
- Skills, experience, education
- Job preferences (target roles, locations, salary, remote, job types)
- Profile completeness scoring with weighted sections
- Guided 3-step onboarding flow

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.38 + Dart 3.10 |
| State Management | Riverpod |
| Navigation | GoRouter |
| Backend | Firebase Cloud Functions (TypeScript) |
| Database | Cloud Firestore |
| Auth | Firebase Authentication |
| UI | Material 3 with custom theme |

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # MaterialApp configuration
├── core/
│   ├── constants/               # App-wide constants (XP, levels, etc.)
│   ├── theme/                   # Material 3 theme
│   └── router/                  # GoRouter configuration
├── models/                      # Data models (UserProfile, Job, Application, etc.)
├── services/                    # Business logic (auth, jobs, AI, gamification)
├── providers/                   # Riverpod providers
├── features/
│   ├── auth/                    # Login & signup screens
│   ├── onboarding/              # 3-step profile setup
│   ├── home/                    # Main shell with bottom navigation
│   ├── jobs/                    # Job dashboard & detail screens
│   ├── cover_letter/            # AI cover letter & intro message generation
│   ├── application/             # Application tracker
│   ├── gamification/            # XP, levels, achievements
│   └── profile/                 # Profile view & edit
└── widgets/                     # Shared components

functions/
└── src/
    ├── index.ts                 # Cloud Function exports
    ├── crawlers/                # Job crawling logic
    ├── ai/                      # Cover letter & intro message generation
    ├── gamification/            # XP engine
    └── matching/                # Job matching algorithm

test/
├── models/                      # Model serialization & logic tests
├── services/                    # Service unit tests
└── widgets/                     # Widget tests
```

## Getting Started

### Prerequisites
- Flutter 3.38+ installed
- Node.js 20+ (for Cloud Functions)
- A Firebase project

### Setup

1. **Clone and install dependencies:**
   ```bash
   flutter pub get
   cd functions && npm install && cd ..
   ```

2. **Configure Firebase:**
   ```bash
   # Install FlutterFire CLI if you haven't
   dart pub global activate flutterfire_cli

   # Configure your Firebase project
   flutterfire configure

   # Deploy Cloud Functions (optional — app works with local fallbacks)
   cd functions && npm run build && firebase deploy --only functions
   ```

3. **Run the app:**
   ```bash
   flutter run -d chrome    # Web
   flutter run              # Mobile
   ```

### Firebase Security Rules

Add these Firestore rules for basic security:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /applications/{appId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /cover_letters/{clId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    match /jobs/{jobId} {
      allow read: if request.auth != null;
      allow write: if false; // Only Cloud Functions write jobs
    }
  }
}
```

## Testing

```bash
flutter test                    # Run all tests (39 tests)
flutter analyze                 # Static analysis (0 issues)
```

## Edge Cases Handled

- **Duplicate jobs** — Deduplicated by title+company hash across sources
- **Expired jobs** — TTL tracking, isExpired flag
- **Ghost detection** — Auto-flags applications with no response after 30 days
- **Sparse profiles** — Requires minimum profile completeness before AI generation
- **No API keys** — Falls back to intelligent template-based generation
- **Gaming the system** — Quality multipliers reward high-match applications, not spam
- **Streak anxiety** — Grace period tracking for streaks

## Architecture Decisions

- **Riverpod over BLoC** — More testable, less boilerplate for this scale
- **Static matching** — `calculateMatchScore` is a pure static function, fully testable without Firebase
- **Graceful degradation** — Every Cloud Function has a local fallback, so the app works without deployment
- **Feature-first folders** — Each feature is self-contained for maintainability
