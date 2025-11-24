import '../../features/habits/domain/habit_repository.dart';
import '../utils/logger.dart';

/// Service for rescheduling notifications on app startup
/// Resets lastNotifiedDate to allow notifications to fire again
class NotificationRescheduleService {
  /// Reschedules all active habit notifications by resetting lastNotifiedDate
  /// Should be called on app startup
  static Future<void> rescheduleAllHabitNotifications(
    HabitRepository habitRepository,
  ) async {
    try {
      final habits = await habitRepository.getHabits();
      int resetCount = 0;

      for (final habit in habits) {
        if (habit.reminderTime.isNotEmpty && !habit.isArchived) {
          // Reset lastNotifiedDate to allow notifications to fire again
          await habitRepository.updateHabit(
            habit.copyWith(lastNotifiedDate: null),
          );
          resetCount++;
        }
      }

      AppLogger.info(
        'Reset notification state for $resetCount habits',
        tag: 'NotificationReschedule',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to reschedule notifications',
        tag: 'NotificationReschedule',
        error: e,
      );
    }
  }
}
