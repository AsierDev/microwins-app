import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../firebase_options.dart';
import '../utils/logger.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../local/hive_setup.dart';
import 'notification_period.dart';

/// Background task that runs every 15 minutes to check for due notifications
/// Uses Firestore as source of truth, updates both Firestore and Hive
@pragma('vm:entry-point')
void habitCheckWorker() {
  Workmanager().executeTask((task, inputData) async {
    try {
      AppLogger.debug(
        'WorkManager: Checking for due notifications...',
        tag: 'HabitCheckWorker',
      );

      // Initialize Firebase in WorkManager process
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Hive for local updates
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HabitModelAdapter());
      }
      final habitBox = await Hive.openBox<HabitModel>(HiveSetup.habitsBoxName);

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

      // Read habits from Firestore (source of truth)
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('habits')
          .where('isArchived', isEqualTo: false)
          .get();

      AppLogger.debug(
        'Found ${snapshot.docs.length} habits in Firestore',
        tag: 'HabitCheckWorker',
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int notificationsShown = 0;

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final reminderTime = data['reminderTime'] as String? ?? '';

          if (reminderTime.isEmpty) continue;

          // Parse period from reminderTime
          NotificationPeriod? period;
          try {
            period = NotificationPeriod.fromString(reminderTime);
          } catch (e) {
            AppLogger.warning(
              'Could not parse reminderTime for habit ${doc.id}: $reminderTime',
              tag: 'HabitCheckWorker',
              error: e,
            );
            continue;
          }

          // Check if current time is within this period
          final isWithinPeriod = period.isWithinPeriod(now);

          if (!isWithinPeriod) {
            // Not within the notification period yet
            continue;
          }

          // Check if already notified today (from Firestore)
          final lastNotifiedStr = data['lastNotifiedDate'] as String?;
          bool alreadyNotifiedToday = false;

          if (lastNotifiedStr != null) {
            try {
              final lastNotified = DateTime.parse(lastNotifiedStr);
              final lastNotifiedDay = DateTime(
                lastNotified.year,
                lastNotified.month,
                lastNotified.day,
              );
              alreadyNotifiedToday = lastNotifiedDay.isAtSameMomentAs(today);
            } catch (e) {
              AppLogger.warning(
                'Could not parse lastNotifiedDate for habit ${doc.id}: $lastNotifiedStr',
                tag: 'HabitCheckWorker',
              );
            }
          }

          if (isWithinPeriod && !alreadyNotifiedToday) {
            // Show notification
            final habitName = data['name'] as String? ?? 'Habit';
            final durationMinutes = data['durationMinutes'] as int? ?? 15;

            await _showNotification(
              habitId: doc.id,
              habitName: habitName,
              durationMinutes: durationMinutes,
            );

            // Update lastNotifiedDate in Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('habits')
                .doc(doc.id)
                .update({'lastNotifiedDate': now.toIso8601String()});

            // Update local Hive cache as well
            final localHabit = habitBox.get(doc.id);
            if (localHabit != null) {
              localHabit.lastNotifiedDate = now;
              await localHabit.save();
            }

            notificationsShown++;

            AppLogger.info(
              'Showed notification for: $habitName (${period.label})',
              tag: 'HabitCheckWorker',
            );
          } else if (isWithinPeriod && alreadyNotifiedToday) {
            AppLogger.debug(
              'Skipping notification for ${data['name']} - already notified today',
              tag: 'HabitCheckWorker',
            );
          }
        } catch (e) {
          AppLogger.error(
            'Error processing habit ${doc.id}',
            tag: 'HabitCheckWorker',
            error: e,
          );
        }
      }

      AppLogger.info(
        'Notification check complete: showed $notificationsShown notifications',
        tag: 'HabitCheckWorker',
      );

      return Future.value(true);
    } catch (e) {
      AppLogger.error('WorkManager error', tag: 'HabitCheckWorker', error: e);
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
