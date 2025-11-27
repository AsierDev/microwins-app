import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Handler for resetting the daily notification flag at midnight
/// Called by the callback dispatcher when 'midnightReschedule' task runs
/// This allows a new notification to be sent the next day
Future<bool> resetDailyNotificationFlag() async {
  try {
    AppLogger.debug('Midnight Worker: Resetting daily notification flag...', tag: 'MidnightWorker');

    // Get SharedPreferences and clear the last notification date
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_streak_notification_date');

    AppLogger.info('Midnight reschedule complete: notification flag reset', tag: 'MidnightWorker');

    return Future.value(true);
  } catch (e) {
    AppLogger.error('Midnight worker error', tag: 'MidnightWorker', error: e);
    return Future.value(false);
  }
}
