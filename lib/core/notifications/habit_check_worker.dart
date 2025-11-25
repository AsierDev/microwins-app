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
    AppLogger.debug(
      'WorkManager: Checking for streak-saver notification...',
      tag: 'HabitCheckWorker',
    );

    // Initialize Firebase in WorkManager process
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Hive for local access
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitModelAdapter());
    }
    await Hive.openBox<HabitModel>(HiveSetup.habitsBoxName);

    // Get current user ID from SharedPreferences (multi-process safe)
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');

    if (userId == null) {
      AppLogger.warning(
        'No user logged in, skipping notification check',
        tag: 'HabitCheckWorker',
      );
      return Future.value(true);
    }

    // Check if notifications are enabled
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (!notificationsEnabled) {
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

    // Check if we're within the notification window (current 15-min period includes the reminder time)
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final reminderMinutes = reminderHour * 60 + reminderMinute;

    // 15-minute window check (if WorkManager runs every 15 minutes)
    final isWithinWindow =
        (currentMinutes >= reminderMinutes) &&
        (currentMinutes < reminderMinutes + 15);

    if (!isWithinWindow) {
      AppLogger.debug(
        'Not within notification window (${now.hour}:${now.minute} vs $dailyReminderTime)',
        tag: 'HabitCheckWorker',
      );
      return Future.value(true);
    }

    // Check if we already notified today
    final lastNotifiedStr = prefs.getString('last_streak_notification_date');
    final today = DateTime(now.year, now.month, now.day);

    if (lastNotifiedStr != null) {
      try {
        final lastNotified = DateTime.parse(lastNotifiedStr);
        final lastNotifiedDay = DateTime(
          lastNotified.year,
          lastNotified.month,
          lastNotified.day,
        );

        if (lastNotifiedDay.isAtSameMomentAs(today)) {
          AppLogger.debug(
            'Already sent streak notification today',
            tag: 'HabitCheckWorker',
          );
          return Future.value(true);
        }
      } catch (e) {
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

    // Only notify if there are incomplete habits
    if (incompleteHabits.isNotEmpty) {
      final count = incompleteHabits.length;
      final habitWord = count == 1 ? 'habit' : 'habits';

      await _showNotification(
        title: "Don't lose your streak! 🔥",
        body:
            "You have $count $habitWord left today. Take 5 mins to keep your momentum!",
      );

      // Update last notified date
      await prefs.setString(
        'last_streak_notification_date',
        now.toIso8601String(),
      );

      AppLogger.info(
        'Sent streak-saver notification for $count incomplete habits',
        tag: 'HabitCheckWorker',
      );
    } else {
      AppLogger.debug(
        'All habits complete! No notification needed.',
        tag: 'HabitCheckWorker',
      );
    }

    return Future.value(true);
  } catch (e) {
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
      AndroidInitializationSettings('@mipmap/ic_launcher');

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
      ),
    ),
  );
}
