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

    // Get daily reminder time (default/global)
    final globalReminderTime =
        prefs.getString('daily_reminder_time') ?? '20:00';
    debugPrint('⏰ Global default reminder: $globalReminderTime');

    // Get current time for comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get all habits from Hive
    final habitBox = Hive.box<HabitModel>(HiveSetup.habitsBoxName);
    final allHabits = habitBox.values.toList();
    debugPrint('📦 Total habits in Hive: ${allHabits.length}');

    // Group habits by their effective reminder time
    final Map<String, List<HabitModel>> habitsByReminderTime = {};
    for (final habit in allHabits) {
      // Skip archived habits or habits with notifications disabled
      if (habit.isArchived || !habit.reminderEnabled) {
        debugPrint(
          '⏭️ Skipping habit "${habit.name}" (archived: ${habit.isArchived}, reminder: ${habit.reminderEnabled})',
        );
        continue;
      }

      // Determine effective reminder time (custom or default)
      final effectiveTime = habit.customReminderTime ?? globalReminderTime;
      habitsByReminderTime.putIfAbsent(effectiveTime, () => []).add(habit);
    }

    debugPrint(
      '🗂️ Habits grouped by ${habitsByReminderTime.length} different reminder times',
    );

    // Check each time group and send notifications if within window
    int totalNotificationsSent = 0;
    for (final entry in habitsByReminderTime.entries) {
      final reminderTime = entry.key;
      final habitsForTime = entry.value;

      // Parse reminder time
      final timeParts = reminderTime.split(':');
      final reminderHour = int.parse(timeParts[0]);
      final reminderMinute = int.parse(timeParts[1]);

      // Check if we're within the notification window (±30 minutes)
      final currentMinutes = now.hour * 60 + now.minute;
      final reminderMinutes = reminderHour * 60 + reminderMinute;
      final minuteDifference = (currentMinutes - reminderMinutes).abs();
      final isWithinWindow = minuteDifference <= 30;

      debugPrint(
        '  ⏰ Time $reminderTime: ${habitsForTime.length} habit(s), window: $isWithinWindow (diff: $minuteDifference min)',
      );

      if (!isWithinWindow) {
        debugPrint('    ⏸️ Not within window, skipping this time group');
        continue;
      }

      // Filter out completed habits for today
      final incompleteHabits = habitsForTime.where((habit) {
        if (habit.lastCompletedDate == null) return true;

        final lastCompleted = DateTime(
          habit.lastCompletedDate!.year,
          habit.lastCompletedDate!.month,
          habit.lastCompletedDate!.day,
        );

        return !lastCompleted.isAtSameMomentAs(today);
      }).toList();

      debugPrint(
        '    🎯 Incomplete habits for $reminderTime: ${incompleteHabits.length}/${habitsForTime.length}',
      );

      // Send notification if there are incomplete habits
      if (incompleteHabits.isNotEmpty) {
        // Check if we already notified for this specific time today
        final notificationKey =
            'last_notification_${reminderTime.replaceAll(':', '')}';
        final lastNotifiedStr = prefs.getString(notificationKey);

        if (lastNotifiedStr != null) {
          try {
            final lastNotified = DateTime.parse(lastNotifiedStr);
            final lastNotifiedDay = DateTime(
              lastNotified.year,
              lastNotified.month,
              lastNotified.day,
            );

            if (lastNotifiedDay.isAtSameMomentAs(today)) {
              debugPrint(
                '    ✅ Already notified for $reminderTime today, skipping',
              );
              continue;
            }
          } catch (e) {
            debugPrint(
              '    ⚠️ Could not parse last notification date for $reminderTime: $e',
            );
          }
        }

        // Send notification
        final count = incompleteHabits.length;
        final habitWord = count == 1 ? 'habit' : 'habits';
        final habitNames = incompleteHabits
            .take(3)
            .map((h) => h.name)
            .join(', ');
        final title = "Don't lose your streak! 🔥";
        final body = count <= 3
            ? 'Complete your reminder: $habitNames'
            : 'You have $count $habitWord left today. Take 5 mins to keep your momentum!';

        debugPrint('    📬 Sending notification for $reminderTime:');
        debugPrint('       Title: $title');
        debugPrint('       Body: $body');

        await _showNotification(title: title, body: body);

        // Update last notified timestamp for this specific time
        await prefs.setString(notificationKey, now.toIso8601String());

        totalNotificationsSent++;
        debugPrint('    ✅ Notification sent successfully for $reminderTime');
      } else {
        debugPrint('    🎉 All habits complete for $reminderTime!');
      }
    }

    if (totalNotificationsSent > 0) {
      AppLogger.info(
        'Sent $totalNotificationsSent notification(s) for different reminder times',
        tag: 'HabitCheckWorker',
      );
    } else {
      AppLogger.debug('No notifications needed', tag: 'HabitCheckWorker');
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
