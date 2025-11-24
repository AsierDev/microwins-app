import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

/// Notification service for managing local notifications
/// WorkManager handles all scheduled notifications via Firestore
/// This service only handles initialization and test notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Check if exact alarm permission is granted (Android 12+)
  Future<bool> hasExactAlarmPermission() async {
    if (kIsWeb || !Platform.isAndroid) return true;

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

  /// Initialize the notification service
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

  /// Show an immediate notification (for testing)
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

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    AppLogger.debug('Cancelled all notifications', tag: 'NotificationService');
  }
}
