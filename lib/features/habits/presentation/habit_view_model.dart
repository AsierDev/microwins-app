import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/habit.dart';
import '../../../core/notifications/notification_service.dart';
import '../data/habit_provider.dart';

part 'habit_view_model.g.dart';

@riverpod
class HabitViewModel extends _$HabitViewModel {
  @override
  Stream<List<Habit>> build() {
    return ref.watch(habitRepositoryProvider).watchHabits();
  }

  Future<void> addHabit({
    required String name,
    required String icon,
    required String category,
    required int durationMinutes,
    required String reminderTime,
    required List<int> reminderDays,
  }) async {
    // Get current habits to determine sortOrder
    final existingHabits = await ref.read(habitRepositoryProvider).getHabits();
    final maxSortOrder = existingHabits.isEmpty
        ? -1
        : existingHabits
              .map((h) => h.sortOrder)
              .reduce((a, b) => a > b ? a : b);

    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      category: category,
      durationMinutes: durationMinutes,
      reminderTime: reminderTime,
      reminderDays: reminderDays,
      sortOrder: maxSortOrder + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(habitRepositoryProvider).createHabit(habit);

    // Schedule notification using WorkManager
    if (reminderTime.isNotEmpty) {
      final timeParts = reminderTime.split(':');
      await NotificationService().scheduleHabitReminder(
        habitId: habit.id,
        habitName: name,
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
        durationMinutes: durationMinutes,
      );
    }
  }

  Future<void> deleteHabit(String id) async {
    // Remove reminder from storage
    await NotificationService().deleteReminder(id);

    // Delete from repository
    await ref.read(habitRepositoryProvider).deleteHabit(id);
  }

  Future<void> completeHabit(String id) async {
    final habits = await ref.read(habitRepositoryProvider).getHabits();
    final habit = habits.firstWhere((h) => h.id == id);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (habit.lastCompletedDate != null) {
      final lastDate = habit.lastCompletedDate!;
      final lastCompletedDay = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );

      if (lastCompletedDay.isAtSameMomentAs(today)) {
        // Already completed today
        return;
      }
    }

    int newStreak = 1;
    if (habit.lastCompletedDate != null) {
      final lastDate = habit.lastCompletedDate!;
      final lastCompletedDay = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );
      final yesterday = today.subtract(const Duration(days: 1));

      if (lastCompletedDay.isAtSameMomentAs(yesterday)) {
        newStreak = habit.currentStreak + 1;
      }
    }

    final newBestStreak = newStreak > habit.bestStreak
        ? newStreak
        : habit.bestStreak;

    final updatedHabit = habit.copyWith(
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      lastCompletedDate: now,
      updatedAt: now,
    );

    await ref.read(habitRepositoryProvider).updateHabit(updatedHabit);

    // Reschedule notification if reminder time changed
    if (updatedHabit.reminderTime.isNotEmpty) {
      final timeParts = updatedHabit.reminderTime.split(':');
      await NotificationService().scheduleHabitReminder(
        habitId: updatedHabit.id,
        habitName: updatedHabit.name,
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
        durationMinutes: updatedHabit.durationMinutes,
      );
    } else {
      // Remove reminder if turned off
      await NotificationService().deleteReminder(habit.id);
    }
  }

  Future<void> reorderHabits(int oldIndex, int newIndex) async {
    final habits = await ref.read(habitRepositoryProvider).getHabits();
    // Create a mutable copy and sort by current sortOrder to ensure we are working with the correct order
    final sortedHabits = List<Habit>.from(habits)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = sortedHabits.removeAt(oldIndex);
    sortedHabits.insert(newIndex, item);

    // Update sortOrder for all items
    final updatedHabits = <Habit>[];
    for (int i = 0; i < sortedHabits.length; i++) {
      if (sortedHabits[i].sortOrder != i) {
        updatedHabits.add(sortedHabits[i].copyWith(sortOrder: i));
      }
    }

    if (updatedHabits.isNotEmpty) {
      await ref.read(habitRepositoryProvider).updateHabitsOrder(updatedHabits);
    }
  }
}
