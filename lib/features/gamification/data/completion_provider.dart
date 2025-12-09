import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_provider.dart';
import '../../habits/data/habit_provider.dart';
import '../domain/completion_repository.dart';
import '../data/models/habit_completion_model.dart';
import 'completion_repository_impl.dart';

part 'completion_provider.g.dart';

@Riverpod(keepAlive: true)
CompletionRepository completionRepository(CompletionRepositoryRef ref) {
  // Rebuild repository when auth state changes (login/logout)
  ref.watch(authStateProvider);

  final syncManager = ref.watch(syncManagerProvider);
  final repository = CompletionRepositoryImpl(syncManager);

  // Trigger sync in background
  repository.syncFromCloud();

  return repository;
}

@riverpod
Stream<List<HabitCompletionModel>> completionsStream(CompletionsStreamRef ref) {
  final repository = ref.watch(completionRepositoryProvider);
  return repository.watchCompletions();
}
