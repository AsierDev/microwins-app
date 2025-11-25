import 'entities/habit.dart';

abstract class HabitRepository {
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<List<Habit>> getHabits();
  Stream<List<Habit>> watchHabits();
  Future<void> updateHabitsOrder(List<Habit> habits);
  Future<void> syncFromCloud();
  Future<List<Habit>> getIncompleteHabitsForToday();
}
