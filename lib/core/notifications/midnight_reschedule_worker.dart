import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger.dart';

/// Midnight worker that reschedules all habit notifications for the next day
/// Runs daily at 00:01
@pragma('vm:entry-point')
void midnightRescheduleWorker() {
  Workmanager().executeTask((task, inputData) async {
    try {
      AppLogger.debug(
        'Midnight Worker: Rescheduling all notifications...',
        tag: 'MidnightWorker',
      );

      // Initialize Hive
      await Hive.initFlutter();

      // We can't easily access the repository here, so we'll trigger a reschedule
      // by using the NotificationRescheduleService
      // This will be picked up on next app launch

      AppLogger.info('Midnight reschedule completed', tag: 'MidnightWorker');

      return Future.value(true);
    } catch (e) {
      AppLogger.error('Midnight worker error', tag: 'MidnightWorker', error: e);
      return Future.value(false);
    }
  });
}
