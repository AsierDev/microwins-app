import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../firebase_options.dart';
import '../utils/logger.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../local/hive_setup.dart';

/// Handler for checking habits and sending streak-saver notification
/// Called by the callback dispatcher when 'habitCheck' task runs
Future<bool> checkHabitsAndNotify() async {
  try {
    debugPrint('═══════════════════════════════');
    debugPrint('🔔 HABIT CHECK WORKER STARTED');
    debugPrint('📅 Time: ${DateTime.now()}');

    AppLogger.debug(
      'WorkManager: Checking for streak-saver notification...',
      tag: 'HabitCheckWorker',
    );

    // Initialize Firebase in WorkManager process
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized');
    } catch (e) {
      // Firebase might already be initialized - this is ok
      debugPrint(
        '⚠️ Firebase initialization: $e (might already be initialized)',
      );
    }

    // Initialize Hive for local access
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitModelAdapter());
    }
    await Hive.openBox<HabitModel>(HiveSetup.habitsBoxName);
    debugPrint('✅ Hive initialized');

    // Get current user ID from SharedPreferences (multi-process safe)
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    debugPrint('🔑 User ID: $userId');

    if (userId == null) {
      debugPrint('⚠️ No user logged in, skipping notification check');
      AppLogger.warning(
        'No user logged in, skipping notification check',
        tag: 'HabitCheckWorker',
      );
      return Future.value(true);
    }

    // Check if notifications are enabled
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    debugPrint('🔔 Notifications enabled: $notificationsEnabled');
    if (!notificationsEnabled) {
      debugPrint('⚠️ Notifications disabled in settings, skipping');
      AppLogger.debug(
        'Notifications disabled, skipping',
        tag: 'HabitCheckWorker',
      );
      return Future.value(true);
    }

    // Get daily reminder time (e.g., "20:00")
    final dailyReminderTime = prefs.getString('daily_reminder_time') ?? '20:00';
    final timeParts = dailyReminderTime.split(':');
    final reminderHour = int.parse(timeParts[0]);
    final reminderMinute = int.parse(timeParts[1]);
    debugPrint('⏰ Configured reminder: $dailyReminderTime');

    // Check if we're within the notification window (using ±30 minutes)
    // WorkManager doesn't guarantee exact 15-min execution, so we use a wider window
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final reminderMinutes = reminderHour * 60 + reminderMinute;
    debugPrint(
      '🕐 Current time: ${now.hour}:${now.minute} ($currentMinutes minutes)',
    );
    debugPrint(
      '🎯 Reminder time: $reminderHour:$reminderMinute ($reminderMinutes minutes)',
    );

    // ± 30-minute window check (flexible for WorkManager scheduling)
    final minuteDifference = (currentMinutes - reminderMinutes).abs();
    final isWithinWindow = minuteDifference <= 30;
    debugPrint(
      '📊 Minute difference: $minuteDifference (within ±30min window: $isWithinWindow)',
    );

    if (!isWithinWindow) {
      debugPrint('⏸️ Not within notification window, skipping');
      AppLogger.debug(
        'Not within notification window (${now.hour}:${now.minute} vs $dailyReminderTime)',
        tag: 'HabitCheckWorker',
      );
      return Future.value(true);
    }

    // Check if we already notified today
    final lastNotifiedStr = prefs.getString('last_streak_notification_date');
    final today = DateTime(now.year, now.month, now.day);
    debugPrint('📆 Today: $today');
    debugPrint('📝 Last notified: $lastNotifiedStr');

    if (lastNotifiedStr != null) {
      try {
        final lastNotified = DateTime.parse(lastNotifiedStr);
        final lastNotifiedDay = DateTime(
          lastNotified.year,
          lastNotified.month,
          lastNotified.day,
        );

        if (lastNotifiedDay.isAtSameMomentAs(today)) {
          debugPrint('✅ Already sent notification today, skipping');
          AppLogger.debug(
            'Already sent streak notification today',
            tag: 'HabitCheckWorker',
          );
          return Future.value(true);
        }
      } catch (e) {
        debugPrint('⚠️ Could not parse last notification date: $e');
        AppLogger.warning(
          'Could not parse last notification date',
          tag: 'HabitCheckWorker',
          error: e,
        );
      }
    }

    // Get incomplete habits for today using repository
    // Note: We create repository with current user context from Hive box
    final habitBox = Hive.box<HabitModel>(HiveSetup.habitsBoxName);
    final allHabits = habitBox.values.toList();
    debugPrint('📦 Total habits in Hive: ${allHabits.length}');

    // Filter out incomplete habits
    final incompleteHabits = allHabits.where((habit) {
      if (habit.isArchived) return false;
      if (habit.lastCompletedDate == null) return true;

      final lastCompleted = DateTime(
        habit.lastCompletedDate!.year,
        habit.lastCompletedDate!.month,
        habit.lastCompletedDate!.day,
      );

      return !lastCompleted.isAtSameMomentAs(today);
    }).toList();

    AppLogger.debug(
      'Found ${incompleteHabits.length} incomplete habits',
      tag: 'HabitCheckWorker',
    );
    debugPrint('🎯 Incomplete habits: ${incompleteHabits.length}');

    // Only notify if there are incomplete habits
    if (incompleteHabits.isNotEmpty) {
      final count = incompleteHabits.length;
      final habitWord = count == 1 ? 'habit' : 'habits';
      const title = "Don't lose your streak! 🔥";
      final body =
          'You have $count $habitWord left today. Take 5 mins to keep your momentum!';

      debugPrint('📬 Sending notification:');
      debugPrint('   Title: $title');
      debugPrint('   Body: $body');

      await _showNotification(title: title, body: body);

      // Update last notified date
      await prefs.setString(
        'last_streak_notification_date',
        now.toIso8601String(),
      );

      debugPrint('✅ Notification sent successfully!');
      AppLogger.info(
        'Sent streak-saver notification for $count incomplete habits',
        tag: 'HabitCheckWorker',
      );
    } else {
      debugPrint('🎉 All habits complete! No notification needed.');
      AppLogger.debug(
        'All habits complete! No notification needed.',
        tag: 'HabitCheckWorker',
      );
    }

    debugPrint('═══════════════════════════════');
    return Future.value(true);
  } catch (e) {
    debugPrint('❌ ERROR in HabitCheckWorker: $e');

    AppLogger.error('WorkManager error', tag: 'HabitCheckWorker', error: e);
    return Future.value(false);
  }
}

/// Show a streak-saver notification
Future<void> _showNotification({
  required String title,
  required String body,
}) async {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_notification');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await notificationsPlugin.initialize(initializationSettings);

  await notificationsPlugin.show(
    999, // Fixed ID for the daily streak notification
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_habit_channel',
        'Daily Habits',
        channelDescription: 'Streak-saver reminder for incomplete habits',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@drawable/ic_notification',
      ),
    ),
  );
}
