import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/logger.dart';

/// Notification service for managing local notifications
/// WorkManager handles all scheduled notifications via Firestore using time periods
/// This service only handles initialization and test notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  /// Returns true if permissions are granted, false otherwise
  Future<bool> init() async {
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
        AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create notification channel for Android 8.0+ (pre-create in main process)
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
          description: 'Streak-saver reminder for incomplete habits',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      AppLogger.debug(
        'Notification channel created in main process',
        tag: 'NotificationService',
      );
    }

    // Check if permissions are granted
    final hasPermissions = await checkPermissionStatus();

    AppLogger.info(
      'NotificationService initialized (permissions: $hasPermissions)',
      tag: 'NotificationService',
    );

    return hasPermissions;
  }

  /// Request notification permissions (Android 13+ / iOS)
  /// Returns true if granted, false otherwise
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    final status = await Permission.notification.request();
    final granted = status.isGranted;

    AppLogger.info(
      'Notification permission requested: ${granted ? "granted" : "denied"}',
      tag: 'NotificationService',
    );

    return granted;
  }

  /// Check current notification permission status
  Future<bool> checkPermissionStatus() async {
    if (kIsWeb) return true;

    final status = await Permission.notification.status;
    return status.isGranted;
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
          icon: '@drawable/ic_notification',
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
