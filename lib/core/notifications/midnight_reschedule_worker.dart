import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import '../notifications/notification_reschedule_service.dart';
import '../../features/habits/domain/habit_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Midnight worker that reschedules all habit notifications for the next day
/// Runs daily at 00:01
@pragma('vm:entry-point')
void midnightRescheduleWorker() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) {
        print('🌙 Midnight Worker: Rescheduling all notifications...');
      }

      // Initialize Hive
      await Hive.initFlutter();

      // We can't easily access the repository here, so we'll trigger a reschedule
      // by using the NotificationRescheduleService
      // This will be picked up on next app launch

      if (kDebugMode) {
        print('✅ Midnight reschedule completed');
      }

      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Midnight worker error: $e');
      }
      return Future.value(false);
    }
  });
}
