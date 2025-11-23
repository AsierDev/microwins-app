import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../firebase_options.dart';

/// Background task that runs every 15 minutes to check for due notifications
/// Uses Firestore (multi-process safe) instead of Hive
@pragma('vm:entry-point')
void habitCheckWorker() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) {
        print('🔔 WorkManager: Checking for due notifications...');
      }

      // Initialize Firebase in WorkManager process
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Get current user ID from SharedPreferences (multi-process safe)
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');

      if (userId == null) {
        if (kDebugMode) {
          print('⚠️ No user logged in, skipping notification check');
        }
        return Future.value(true);
      }

      // Read habits from Firestore (multi-process safe)
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('habits')
          .where('isArchived', isEqualTo: false)
          .get();

      if (kDebugMode) {
        print('📦 Found ${snapshot.docs.length} habits in Firestore');
      }

      final now = DateTime.now();
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
      final today = DateTime(now.year, now.month, now.day);

      int notificationsShown = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final reminderTime = data['reminderTime'] as String? ?? '';

        if (reminderTime.isEmpty) continue;

        // Parse reminder time
        final timeParts = reminderTime.split(':');
        if (timeParts.length != 2) continue;

        final reminderHour = int.tryParse(timeParts[0]);
        final reminderMinute = int.tryParse(timeParts[1]);

        if (reminderHour == null || reminderMinute == null) continue;

        final reminderTimeOfDay = TimeOfDay(
          hour: reminderHour,
          minute: reminderMinute,
        );

        // Calculate time difference in minutes
        final currentMinutes = currentTime.hour * 60 + currentTime.minute;
        final reminderMinutes =
            reminderTimeOfDay.hour * 60 + reminderTimeOfDay.minute;
        final diff = currentMinutes - reminderMinutes;

        // Check if we should fire this notification (within 15-minute window)
        final shouldNotify = diff >= 0 && diff <= 15;

        // Check if already notified today (stored in Firestore)
        final lastNotifiedStr = data['lastNotifiedDate'] as String?;
        bool alreadyNotifiedToday = false;

        if (lastNotifiedStr != null) {
          final lastNotified = DateTime.parse(lastNotifiedStr);
          final lastNotifiedDay = DateTime(
            lastNotified.year,
            lastNotified.month,
            lastNotified.day,
          );
          alreadyNotifiedToday = lastNotifiedDay.isAtSameMomentAs(today);
        }

        if (shouldNotify && !alreadyNotifiedToday) {
          // Show notification
          final habitName = data['name'] as String? ?? 'Habit';
          final durationMinutes = data['durationMinutes'] as int? ?? 15;

          await _showNotification(
            habitId: doc.id,
            habitName: habitName,
            durationMinutes: durationMinutes,
          );

          // Update last notified timestamp in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('habits')
              .doc(doc.id)
              .update({'lastNotifiedDate': now.toIso8601String()});

          notificationsShown++;

          if (kDebugMode) {
            print('✅ Showed notification for: $habitName');
          }
        }
      }

      if (kDebugMode) {
        print('✅ Showed $notificationsShown notifications');
      }

      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ WorkManager error: $e');
      }
      return Future.value(false);
    }
  });
}

/// Show an immediate notification
Future<void> _showNotification({
  required String habitId,
  required String habitName,
  required int durationMinutes,
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
    habitId.hashCode,
    'Time for $habitName! ⏰',
    '$durationMinutes min',
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
  );
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});
}
