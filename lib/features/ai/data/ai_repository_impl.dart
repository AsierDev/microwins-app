import '../../habits/domain/entities/habit.dart';
import '../domain/ai_repository.dart';
import 'open_router_service.dart';

class AiRepositoryImpl implements AiRepository {
  final OpenRouterService _service;

  AiRepositoryImpl(this._service);

  @override
  Future<List<Habit>> generateHabits(String goal) {
    return _service.generateHabits(goal);
  }
}
