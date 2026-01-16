import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/local/hive_setup.dart';
import '../../auth/data/auth_provider.dart';
import '../../habits/data/habit_provider.dart';
import '../domain/completion_repository.dart';
import '../data/models/habit_completion_model.dart';
import 'completion_repository_impl.dart';

part 'completion_provider.g.dart';

@Riverpod(keepAlive: true)
CompletionRepository completionRepository(CompletionRepositoryRef ref) {
  // Watch auth state to rebuild when user changes
  final authState = ref.watch(authStateProvider);
  final previousUserId = ref.read(previousUserIdProvider);
  final currentUserId = authState.value;

  // If user changed (including logout), clear local data for isolation
  if (previousUserId != null && previousUserId != currentUserId) {
    Hive.box<HabitCompletionModel>(HiveSetup.completionsBoxName).clear();
  }

  final syncManager = ref.watch(syncManagerProvider);
  final repository = CompletionRepositoryImpl(syncManager);

  // Only sync from cloud if user is logged in
  if (currentUserId != null) {
    repository.syncFromCloud();
  }

  return repository;
}

@riverpod
Stream<List<HabitCompletionModel>> completionsStream(CompletionsStreamRef ref) {
  final repository = ref.watch(completionRepositoryProvider);
  return repository.watchCompletions();
}
