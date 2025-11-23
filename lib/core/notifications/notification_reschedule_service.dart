import 'package:flutter/foundation.dart';
import '../../features/habits/domain/habit_repository.dart';
import 'notification_service.dart';

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

      if (kDebugMode) {
        print('🔄 Rescheduled ${habits.length} habit notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to reschedule notifications: $e');
      }
    }
  }
}
