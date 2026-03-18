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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
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
            path: 'achievements',
            builder: (context, state) => const AchievementsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
