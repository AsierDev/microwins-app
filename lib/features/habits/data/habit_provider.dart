import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/local/hive_setup.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../auth/data/auth_provider.dart';
import '../domain/habit_repository.dart';
import 'habit_repository_impl.dart';
import 'models/habit_model.dart';

part 'habit_provider.g.dart';

@Riverpod(keepAlive: true)
SyncManager syncManager(SyncManagerRef ref) {
  return SyncManager();
}

@Riverpod(keepAlive: true)
HabitRepository habitRepository(HabitRepositoryRef ref) {
  // Watch auth state to rebuild when user changes
  final authState = ref.watch(authStateProvider);
  final previousUserId = ref.read(previousUserIdProvider);
  final currentUserId = authState.value;

  // If user changed (including logout), clear local data for isolation
  if (previousUserId != null && previousUserId != currentUserId) {
    Hive.box<HabitModel>(HiveSetup.habitsBoxName).clear();
  }

  // Update previous user ID tracker (deferred to avoid modifying during build)
  Future.microtask(() {
    ref.read(previousUserIdProvider.notifier).update(currentUserId);
  });

  final syncManager = ref.watch(syncManagerProvider);
  final repository = HabitRepositoryImpl(syncManager);

  // Only sync from cloud if user is logged in
  if (currentUserId != null) {
    repository.syncFromCloud();
  }

  return repository;
}
