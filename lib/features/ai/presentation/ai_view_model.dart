import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../habits/domain/entities/habit.dart';
import '../data/ai_provider.dart';

part 'ai_view_model.g.dart';

@riverpod
class AiViewModel extends _$AiViewModel {
  @override
  FutureOr<List<Habit>> build() {
    return [];
  }

  Future<void> generateHabits(String goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(aiRepositoryProvider).generateHabits(goal));
  }
}
