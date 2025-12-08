import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_manager.dart';
import '../domain/completion_repository.dart';
import '../data/models/habit_completion_model.dart';
import 'completion_repository_impl.dart';

part 'completion_provider.g.dart';

@riverpod
CompletionRepository completionRepository(Ref ref) {
  return CompletionRepositoryImpl(SyncManager());
}

@riverpod
Stream<List<HabitCompletionModel>> completionsStream(Ref ref) {
  final repository = ref.watch(completionRepositoryProvider);
  return repository.watchCompletions();
}
