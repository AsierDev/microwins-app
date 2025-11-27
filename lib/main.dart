import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';

import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';
import 'core/local/hive_setup.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/callback_dispatcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await HiveSetup.init();

  // Initialize Notifications (mobile only)
  if (!kIsWeb) {
    await NotificationService().init();

    // Initialize WorkManager with unified callback dispatcher
    await Workmanager().initialize(callbackDispatcher);

    debugPrint('✅ WorkManager initialized');

    // Register periodic task (runs every 15 minutes)
    // Note: Android may not execute exactly every 15 min due to battery optimization
    await Workmanager().registerPeriodicTask(
      'habit-notification-check',
      'habitCheck',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false, // Allow execution even on low battery
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );

    debugPrint(
      '✅ Periodic task registered: habit-notification-check (every 15 min)',
    );

    // Register daily midnight reschedule (starts at 00:01, runs daily)
    await Workmanager().registerPeriodicTask(
      'midnight-reschedule',
      'midnightReschedule',
      frequency: const Duration(hours: 24),
      initialDelay: _calculateDelayUntilMidnight(),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );

    debugPrint('✅ Periodic task registered: midnight-reschedule (daily)');
  }

  // Initialize Ads
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  runApp(const ProviderScope(child: MyApp()));
}

/// Calculate delay until next midnight (00:01)
Duration _calculateDelayUntilMidnight() {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 1);
  return tomorrow.difference(now);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'MicroWins',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
