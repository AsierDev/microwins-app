import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../../features/habits/domain/entities/habit.dart';
import 'habit_reminder_storage.dart';
import 'habit_reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Check if exact alarm permission is granted
  Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true; // iOS doesn't need this

    try {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking exact alarm permission: $e');
      }
      return false;
    }
  }

  /// Request exact alarm permission (Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error requesting exact alarm permission: $e');
      }
      return false;
    }
  }

  /// Schedule habit reminder using WorkManager periodic checks
  /// This is the ONLY reliable method on Android 12+
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required int hour,
    required int minute,
    required int durationMinutes,
  }) async {
    try {
      // ALWAYS use periodic checks - this is the only reliable solution
      final reminderTime =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      final reminder = HabitReminderModel(
        habitId: habitId,
        habitName: habitName,
        reminderTime: reminderTime,
        durationMinutes: durationMinutes,
        lastNotifiedDate: null,
      );

      await HabitReminderStorage.saveReminder(reminder);

      if (kDebugMode) {
        print(
          '✅ Scheduled reminder for $habitName at $reminderTime (WorkManager checks every 15 min)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling reminder: $e');
      }
    }
  }

  /// Delete reminder from storage
  Future<void> deleteReminder(String habitId) async {
    await HabitReminderStorage.deleteReminder(habitId);
    if (kDebugMode) {
      print('🗑️ Deleted reminder: $habitId');
    }
  }

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Get local timezone - handle abbreviations that don't exist in timezone database
    final String timeZoneName = DateTime.now().timeZoneName;
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback for abbreviations like "CET", "PST" etc
      if (kDebugMode) {
        print('Timezone $timeZoneName not found, using default location');
      }
      // Use a common European timezone as fallback for CET
      tz.setLocalLocation(tz.getLocation('Europe/Madrid'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create notification channel for Android 8.0+
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_habit_channel',
          'Daily Habits',
          description: 'Notifications for daily habits',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    if (kDebugMode) {
      print('✅ NotificationService initialized');
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String habitId,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    try {
      // Calculate next occurrence
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Time for $habitName! ⏰',
        '$habitName',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_habit_channel',
            'Daily Habits',
            channelDescription: 'Notifications for daily habits',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      if (kDebugMode) {
        final isToday = scheduledDate.day == now.day;
        print(
          '✅ Scheduled reminder for "$habitName" at $hour:${minute.toString().padLeft(2, '0')} ${isToday ? 'TODAY' : 'TOMORROW'} (${scheduledDate.day}/${scheduledDate.month})',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule notification: $e');
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    if (kDebugMode) {
      print('🗑️ Cancelled notification with ID: $id');
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    if (kDebugMode) {
      print('🗑️ Cancelled all notifications');
    }
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_habit_channel',
          'Daily Habits',
          channelDescription: 'Notifications for daily habits',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    if (kDebugMode) {
      print('📬 Showed immediate notification: $title');
    }
  }
}
