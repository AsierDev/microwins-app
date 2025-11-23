import '../../habits/domain/entities/habit.dart';

abstract class AiRepository {
  Future<List<Habit>> generateHabits(String goal);
}
