import '../entities/habit.dart';
import '../habit_repository.dart';

class CreateHabitUseCase {
  final HabitRepository _repository;

  CreateHabitUseCase(this._repository);

  Future<void> call(Habit habit) {
    return _repository.createHabit(habit);
  }
}
