import 'package:hive_flutter/hive_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/local/hive_setup.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../../../core/utils/logger.dart';
import '../domain/completion_repository.dart';
import '../data/models/habit_completion_model.dart';

class CompletionRepositoryImpl implements CompletionRepository {
  final Box<HabitCompletionModel> _completionBox;
  final SyncManager _syncManager;

  CompletionRepositoryImpl(this._syncManager)
    : _completionBox = Hive.box<HabitCompletionModel>(
        HiveSetup.completionsBoxName,
      );

  @override
  Future<void> createCompletion(HabitCompletionModel completion) async {
    await _completionBox.put(completion.id, completion);

    // Queue sync operation
    await _syncManager.queueOperation('createCompletion', {
      'id': completion.id,
      'habitId': completion.habitId,
      'completedAt': completion.completedAt.toIso8601String(),
      'createdAt': completion.createdAt.toIso8601String(),
      'isSynced': completion.isSynced,
    });
  }

  @override
  Future<void> updateCompletion(HabitCompletionModel completion) async {
    await _completionBox.put(completion.id, completion);

    await _syncManager.queueOperation('updateCompletion', {
      'id': completion.id,
      'habitId': completion.habitId,
      'completedAt': completion.completedAt.toIso8601String(),
      'createdAt': completion.createdAt.toIso8601String(),
      'isSynced': completion.isSynced,
    });
  }

  @override
  Future<void> deleteCompletion(String id) async {
    await _completionBox.delete(id);

    await _syncManager.queueOperation('deleteCompletion', {'id': id});
  }

  @override
  Future<List<HabitCompletionModel>> getCompletions() async {
    return _completionBox.values.toList();
  }

  @override
  Future<List<HabitCompletionModel>> getCompletionsForHabit(
    String habitId,
  ) async {
    return _completionBox.values
        .where((completion) => completion.habitId == habitId)
        .toList();
  }

  @override
  Future<List<HabitCompletionModel>> getCompletionsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _completionBox.values.where((completion) {
      final completionDate = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      return !completionDate.isBefore(start) && !completionDate.isAfter(end);
    }).toList();
  }

  @override
  Stream<List<HabitCompletionModel>> watchCompletions() {
    return _completionBox
        .watch()
        .map((event) => _completionBox.values.toList())
        .startWith(_completionBox.values.toList());
  }

  @override
  Stream<List<HabitCompletionModel>> watchCompletionsForHabit(String habitId) {
    return watchCompletions().map(
      (completions) => completions
          .where((completion) => completion.habitId == habitId)
          .toList(),
    );
  }

  @override
  Future<void> syncFromCloud() async {
    try {
      final remoteCompletions = await _syncManager
          .fetchCompletionsFromFirestore();
      if (remoteCompletions.isEmpty) return;

      for (final data in remoteCompletions) {
        try {
          final completion = HabitCompletionModel(
            id: data['id'],
            habitId: data['habitId'],
            completedAt: DateTime.parse(data['completedAt']),
            createdAt: DateTime.parse(data['createdAt']),
            isSynced: data['isSynced'] ?? true,
          );

          await _completionBox.put(completion.id, completion);
        } catch (e) {
          AppLogger.error(
            'Error syncing completion ${data['id']}',
            tag: 'CompletionRepository',
            error: e,
          );
        }
      }
    } catch (e) {
      AppLogger.error(
        'Error syncing completions from cloud',
        tag: 'CompletionRepository',
        error: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String id) async {
    final completion = _completionBox.get(id);
    if (completion != null) {
      final updatedCompletion = completion.copyWith(isSynced: true);
      await _completionBox.put(id, updatedCompletion);
    }
  }

  @override
  Future<List<HabitCompletionModel>> getUnsyncedCompletions() async {
    return _completionBox.values
        .where((completion) => !completion.isSynced)
        .toList();
  }

  @override
  Future<void> deleteCompletionsForHabit(String habitId) async {
    final completionsToDelete = _completionBox.values
        .where((completion) => completion.habitId == habitId)
        .toList();

    for (final completion in completionsToDelete) {
      await _completionBox.delete(completion.id);
      await _syncManager.queueOperation('deleteCompletion', {
        'id': completion.id,
      });
    }
  }
}
