import '../entities/habit.dart';
import '../habit_repository.dart';

class GetHabitsUseCase {
  final HabitRepository _repository;

  GetHabitsUseCase(this._repository);

  Stream<List<Habit>> call() {
    return _repository.watchHabits();
  }
}
