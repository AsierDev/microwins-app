import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'habit_reminder_storage.dart';
import 'habit_reminder_model.dart';
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Check if exact alarm permission is granted
  Future<bool> hasExactAlarmPermission() async {
    if (kIsWeb || !Platform.isAndroid)
      return true; // Web and iOS don't need this

    try {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    } catch (e) {
      AppLogger.error(
        'Error checking exact alarm permission',
        tag: 'NotificationService',
        error: e,
      );
      return false;
    }
  }

  /// Request exact alarm permission (Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    if (kIsWeb || !Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    } catch (e) {
      AppLogger.error(
        'Error requesting exact alarm permission',
        tag: 'NotificationService',
        error: e,
      );
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

      AppLogger.info(
        'Scheduled reminder for $habitName at $reminderTime (WorkManager checks every 15 min)',
        tag: 'NotificationService',
      );
    } catch (e) {
      AppLogger.error(
        'Error scheduling reminder',
        tag: 'NotificationService',
        error: e,
      );
    }
  }

  /// Delete reminder from storage
  Future<void> deleteReminder(String habitId) async {
    await HabitReminderStorage.deleteReminder(habitId);
    AppLogger.debug('Deleted reminder: $habitId', tag: 'NotificationService');
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
      AppLogger.debug(
        'Timezone $timeZoneName not found, using default location',
        tag: 'NotificationService',
      );
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
    if (!kIsWeb && Platform.isAndroid) {
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

    AppLogger.info(
      'NotificationService initialized',
      tag: 'NotificationService',
    );
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
        habitName,
        scheduledDate,
        const NotificationDetails(
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

      final isToday = scheduledDate.day == now.day;
      AppLogger.info(
        'Scheduled reminder for "$habitName" at $hour:${minute.toString().padLeft(2, '0')} ${isToday ? 'TODAY' : 'TOMORROW'} (${scheduledDate.day}/${scheduledDate.month})',
        tag: 'NotificationService',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to schedule notification',
        tag: 'NotificationService',
        error: e,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    AppLogger.debug(
      'Cancelled notification with ID: $id',
      tag: 'NotificationService',
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    AppLogger.debug('Cancelled all notifications', tag: 'NotificationService');
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
    AppLogger.debug(
      'Showed immediate notification: $title',
      tag: 'NotificationService',
    );
  }
}
