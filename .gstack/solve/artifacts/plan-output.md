# Phase 2: PLAN — Engineering Review Output

## Architecture Decision
Flutter + Firebase + Riverpod architecture with feature-first folder structure. Firebase Functions in TypeScript for backend crawling and AI generation.

## Implementation Plan

### Files to Create (in order)

#### 1. Project Setup
- `pubspec.yaml` — Flutter dependencies
- `lib/main.dart` — App entry point with Firebase init
- `lib/app.dart` — MaterialApp with theme and router

#### 2. Core Infrastructure
- `lib/core/theme/app_theme.dart` — Material 3 theme
- `lib/core/constants/app_constants.dart` — App-wide constants
- `lib/core/router/app_router.dart` — GoRouter configuration
- `lib/core/services/firebase_service.dart` — Firebase initialization

#### 3. Models
- `lib/models/user_profile.dart` — User profile model
- `lib/models/job.dart` — Job listing model
- `lib/models/application.dart` — Application tracking model
- `lib/models/cover_letter.dart` — Cover letter model
- `lib/models/achievement.dart` — Achievement/gamification models

#### 4. Services
- `lib/services/auth_service.dart` — Firebase Auth wrapper
- `lib/services/profile_service.dart` — User profile CRUD
- `lib/services/job_service.dart` — Job fetching & matching
- `lib/services/application_service.dart` — Application tracking
- `lib/services/ai_service.dart` — Cover letter / intro message generation
- `lib/services/gamification_service.dart` — XP, levels, achievements

#### 5. State Management (Riverpod Providers)
- `lib/providers/auth_provider.dart`
- `lib/providers/profile_provider.dart`
- `lib/providers/job_provider.dart`
- `lib/providers/application_provider.dart`
- `lib/providers/gamification_provider.dart`

#### 6. Features/Screens
- `lib/features/auth/login_screen.dart`
- `lib/features/auth/signup_screen.dart`
- `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/profile/profile_screen.dart`
- `lib/features/profile/profile_edit_screen.dart`
- `lib/features/jobs/jobs_dashboard_screen.dart`
- `lib/features/jobs/job_detail_screen.dart`
- `lib/features/jobs/job_search_config_screen.dart`
- `lib/features/cover_letter/cover_letter_screen.dart`
- `lib/features/application/application_tracker_screen.dart`
- `lib/features/gamification/gamification_dashboard_screen.dart`
- `lib/features/gamification/achievements_screen.dart`
- `lib/features/home/home_screen.dart` — Main shell with bottom nav

#### 7. Shared Widgets
- `lib/widgets/job_card.dart`
- `lib/widgets/match_score_indicator.dart`
- `lib/widgets/xp_progress_bar.dart`
- `lib/widgets/achievement_badge.dart`
- `lib/widgets/stat_card.dart`
- `lib/widgets/empty_state.dart`

#### 8. Firebase Functions
- `functions/src/index.ts` — Function exports
- `functions/src/crawlers/job_crawler.ts` — Job crawling logic
- `functions/src/ai/cover_letter_generator.ts` — AI generation
- `functions/src/ai/intro_message_generator.ts` — Intro messages
- `functions/src/gamification/xp_engine.ts` — XP calculation
- `functions/src/matching/job_matcher.ts` — Match scoring

#### 9. Tests
- `test/models/` — Model serialization tests
- `test/services/` — Service unit tests
- `test/widgets/` — Widget tests
- `test/features/` — Screen tests

## Test Plan
| Test | Type | What it verifies |
|------|------|-----------------|
| UserProfile serialization | unit | toJson/fromJson round-trip |
| Job model | unit | Model creation and scoring |
| Achievement unlocking | unit | XP thresholds and badge logic |
| GamificationService | unit | XP calculation, level-up, streaks |
| JobCard widget | widget | Renders job info, match score |
| LoginScreen | widget | Form validation, auth flow |
| JobsDashboard | widget | List rendering, filters |

## Risk Assessment
- **API rate limits**: Mitigated by scheduled crawling with backoff
- **AI generation cost**: Mitigated by caching and rate limiting per user
- **Firebase costs**: Mitigated by efficient queries, pagination
- **LinkedIn TOS**: Avoided by using legitimate APIs (Adzuna, RemoteOK)
