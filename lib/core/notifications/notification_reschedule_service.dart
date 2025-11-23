import '../../features/habits/domain/habit_repository.dart';
import 'notification_service.dart';
import '../utils/logger.dart';

class NotificationRescheduleService {
  /// Reschedules all active habit notifications
  /// Should be called on app startup and after completing habits
  static Future<void> rescheduleAllHabitNotifications(
    HabitRepository habitRepository,
  ) async {
    try {
      final habits = await habitRepository.getHabits();

      for (final habit in habits) {
        if (habit.reminderTime.isNotEmpty && habit.reminderDays.isNotEmpty) {
          final timeParts = habit.reminderTime.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          await NotificationService().scheduleDailyNotification(
            id: habit.id.hashCode,
            habitId: habit.id,
            habitName: habit.name,
            hour: hour,
            minute: minute,
          );
        }
      }

      AppLogger.info(
        'Rescheduled ${habits.length} habit notifications',
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
