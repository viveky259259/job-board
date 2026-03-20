import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/features/auth/login_screen.dart';
import 'package:job_board/features/auth/signup_screen.dart';
import 'package:job_board/features/home/home_screen.dart';
import 'package:job_board/features/onboarding/onboarding_screen.dart';
import 'package:job_board/features/profile/profile_screen.dart';
import 'package:job_board/features/profile/profile_edit_screen.dart';
import 'package:job_board/features/jobs/job_detail_screen.dart';
import 'package:job_board/features/cover_letter/cover_letter_screen.dart';
import 'package:job_board/features/gamification/achievements_screen.dart';
import 'package:job_board/features/resume_analyzer/resume_analyzer_screen.dart';
import 'package:job_board/features/interview_prep/interview_prep_screen.dart';
import 'package:job_board/features/interview_prep/interview_prep_landing.dart';
import 'package:job_board/features/analytics/analytics_screen.dart';
import 'package:job_board/features/follow_up/follow_up_screen.dart';
import 'package:job_board/features/settings/settings_screen.dart';
import 'package:job_board/features/paywall/paywall_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return null;

      final isLoggedIn = authState.value != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/signup';
      final isOnboarding = loc == '/onboarding';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && loc == '/login') return '/';
      if (!isLoggedIn && isOnboarding) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'profile/edit',
            builder: (context, state) => const ProfileEditScreen(),
          ),
          GoRoute(
            path: 'job/:jobId',
            builder: (context, state) {
              final jobId = state.pathParameters['jobId']!;
              return JobDetailScreen(jobId: jobId);
            },
          ),
          GoRoute(
            path: 'cover-letter/:jobId',
            builder: (context, state) {
              final jobId = state.pathParameters['jobId']!;
              return CoverLetterScreen(jobId: jobId);
            },
          ),
          GoRoute(
            path: 'interview-prep/:jobId',
            builder: (context, state) {
              final jobId = state.pathParameters['jobId']!;
              return InterviewPrepScreen(jobId: jobId);
            },
          ),
          GoRoute(
            path: 'interview-prep-framework',
            builder: (context, state) => const InterviewPrepLanding(),
          ),
          GoRoute(
            path: 'achievements',
            builder: (context, state) => const AchievementsScreen(),
          ),
          GoRoute(
            path: 'resume-analyzer',
            builder: (context, state) => const ResumeAnalyzerScreen(),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'follow-ups',
            builder: (context, state) => const FollowUpScreen(),
          ),
          GoRoute(
            path: 'upgrade',
            builder: (context, state) => const PaywallScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
