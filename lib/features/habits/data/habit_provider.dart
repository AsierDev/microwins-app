import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../auth/data/auth_provider.dart';
import '../domain/habit_repository.dart';
import 'habit_repository_impl.dart';

part 'habit_provider.g.dart';

@Riverpod(keepAlive: true)
SyncManager syncManager(SyncManagerRef ref) {
  return SyncManager();
}

@Riverpod(keepAlive: true)
HabitRepository habitRepository(HabitRepositoryRef ref) {
  // Rebuild repository when auth state changes (login/logout)
  ref.watch(authStateProvider);

  final syncManager = ref.watch(syncManagerProvider);
  final repository = HabitRepositoryImpl(syncManager);
  // Trigger sync in background
  repository.syncFromCloud();
  return repository;
}
