import 'package:workmanager/workmanager.dart';
import '../utils/logger.dart';
import 'habit_check_worker.dart';
import 'midnight_reschedule_worker.dart';

/// Unified callback dispatcher for all WorkManager background tasks
/// This is the single entry point that routes task names to their handlers
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      AppLogger.debug(
        'WorkManager task started: $task',
        tag: 'CallbackDispatcher',
      );

      switch (task) {
        case 'habitCheck':
          return await checkHabitsAndNotify();

        case 'midnightReschedule':
          return await resetDailyNotificationFlag();

        default:
          AppLogger.warning('Unknown task: $task', tag: 'CallbackDispatcher');
          return Future.value(true);
      }
    } catch (e) {
      AppLogger.error(
        'CallbackDispatcher error for task: $task',
        tag: 'CallbackDispatcher',
        error: e,
      );
      return Future.value(false);
    }
  });
}
