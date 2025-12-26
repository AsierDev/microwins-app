import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/habits/presentation/home_screen.dart';
import '../../features/habits/presentation/create_habit_screen.dart';
import '../../features/gamification/presentation/progress_screen.dart';
import '../../features/gamification/presentation/badges_screen.dart';
import '../../features/ai/presentation/discover_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/privacy/presentation/privacy_policy_screen.dart';
import '../../features/habits/domain/entities/habit.dart';

import '../../features/home/presentation/scaffold_with_navbar.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final isRevisit = state.uri.queryParameters['revisit'] == 'true';
          return OnboardingScreen(isRevisit: isRevisit);
        },
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/discover', builder: (context, state) => const DiscoverScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
              GoRoute(path: '/badges', builder: (context, state) => const BadgesScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/create-habit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final habitToEdit = state.extra as Habit?;
          return CreateHabitScreen(habitToEdit: habitToEdit);
        },
      ),
      GoRoute(
        path: '/privacy-policy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  );
}
