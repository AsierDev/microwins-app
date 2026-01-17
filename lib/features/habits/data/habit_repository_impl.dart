import 'package:hive_flutter/hive_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/local/hive_setup.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../../../core/utils/logger.dart';
import '../domain/entities/habit.dart';
import '../domain/habit_repository.dart';
import 'models/habit_model.dart';
import 'mappers/habit_mapper.dart';

class HabitRepositoryImpl implements HabitRepository {
  final Box<HabitModel> _habitBox;
  final SyncManager _syncManager;

  HabitRepositoryImpl(this._syncManager)
    : _habitBox = Hive.box<HabitModel>(HiveSetup.habitsBoxName);

  @override
  Future<void> createHabit(Habit habit) async {
    final model = HabitMapper.toModel(habit);
    await _habitBox.put(model.id, model);

    // Queue sync operation with complete habit data
    await _syncManager.queueOperation('createHabit', {
      'id': model.id,
      'name': model.name,
      'icon': model.icon,
      'category': model.category,
      'durationMinutes': model.durationMinutes,
      'currentStreak': model.currentStreak,
      'bestStreak': model.bestStreak,
      'sortOrder': model.sortOrder,
      'isArchived': model.isArchived,
      'createdAt': model.createdAt.toIso8601String(),
      'updatedAt': model.updatedAt.toIso8601String(),
      'lastCompletedDate': model.lastCompletedDate?.toIso8601String(),
      'lastNotifiedDate': model.lastNotifiedDate?.toIso8601String(),
      'customReminderTime': model.customReminderTime,
      'reminderEnabled': model.reminderEnabled,
    });
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final model = HabitMapper.toModel(habit);
    await _habitBox.put(model.id, model);

    // Queue sync operation with complete habit data
    await _syncManager.queueOperation('updateHabit', {
      'id': model.id,
      'name': model.name,
      'icon': model.icon,
      'category': model.category,
      'durationMinutes': model.durationMinutes,
      'currentStreak': model.currentStreak,
      'bestStreak': model.bestStreak,
      'sortOrder': model.sortOrder,
      'isArchived': model.isArchived,
      'createdAt': model.createdAt.toIso8601String(),
      'updatedAt': model.updatedAt.toIso8601String(),
      'lastCompletedDate': model.lastCompletedDate?.toIso8601String(),
      'lastNotifiedDate': model.lastNotifiedDate?.toIso8601String(),
      'customReminderTime': model.customReminderTime,
      'reminderEnabled': model.reminderEnabled,
    });
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);

    await _syncManager.queueOperation('deleteHabit', {'id': id});
  }

  @override
  Future<List<Habit>> getHabits() async {
    return _habitBox.values.map((e) => HabitMapper.toEntity(e)).toList();
  }

  @override
  Stream<List<Habit>> watchHabits() {
    return _habitBox
        .watch()
        .map((event) {
          return _habitBox.values.map((e) => HabitMapper.toEntity(e)).toList();
        })
        .startWith(
          _habitBox.values.map((e) => HabitMapper.toEntity(e)).toList(),
        );
  }

  @override
  Future<void> updateHabitsOrder(List<Habit> habits) async {
    for (final habit in habits) {
      final model = HabitMapper.toModel(habit);
      await _habitBox.put(model.id, model);

      // We might want to optimize this to a single batch sync later
      await _syncManager.queueOperation('updateHabit', {
        'id': model.id,
        'sortOrder': model.sortOrder,
      });
    }
  }

  @override
  Future<void> syncFromCloud() async {
    try {
      final remoteHabits = await _syncManager.fetchHabitsFromFirestore();
      if (remoteHabits.isEmpty) return;

      // Simple strategy: If local is empty, take all from cloud.
      // If local has data, we might want to merge, but for now let's just add missing ones
      // or update existing ones if cloud is newer (we don't have timestamps easily accessible here without parsing).

      // For this fix (Data Loss on Reinstall), the local box is likely empty or has only default data.
      // So we can iterate and put.

      for (final data in remoteHabits) {
        try {
          // We need to map the Map<String, dynamic> back to HabitModel.
          // Since HabitModel.fromJson doesn't exist (it's a Hive object), we need to construct it manually
          // or add a fromJson factory.
          // Let's construct it manually based on the keys we pushed.

          final habit = HabitModel(
            id: data['id'],
            name: data['name'],
            icon: data['icon'],
            category: data['category'],
            durationMinutes: data['durationMinutes'],
            currentStreak: data['currentStreak'] ?? 0,
            bestStreak: data['bestStreak'] ?? 0,
            sortOrder: data['sortOrder'] ?? 0,
            isArchived: data['isArchived'] ?? false,
            createdAt: DateTime.parse(data['createdAt']),
            updatedAt: DateTime.parse(data['updatedAt']),
            lastCompletedDate: data['lastCompletedDate'] != null
                ? DateTime.parse(data['lastCompletedDate'])
                : null,
            lastNotifiedDate: data['lastNotifiedDate'] != null
                ? DateTime.parse(data['lastNotifiedDate'])
                : null,
            customReminderTime: data['customReminderTime'] as String?,
            reminderEnabled: data['reminderEnabled'] as bool? ?? true,
          );

          await _habitBox.put(habit.id, habit);
        } catch (e) {
          AppLogger.error(
            'Error syncing habit ${data['id']}',
            tag: 'HabitRepository',
            error: e,
          );
        }
      }
    } catch (e) {
      AppLogger.error(
        'Error syncing from cloud',
        tag: 'HabitRepository',
        error: e,
      );
    }
  }

  @override
  Future<List<Habit>> getIncompleteHabitsForToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final allHabits = await getHabits();

    // Filter habits that haven't been completed today
    return allHabits.where((habit) {
      // Skip archived habits
      if (habit.isArchived) return false;

      // Check if habit was completed today
      if (habit.lastCompletedDate == null) return true;

      final lastCompleted = DateTime(
        habit.lastCompletedDate!.year,
        habit.lastCompletedDate!.month,
        habit.lastCompletedDate!.day,
      );

      // Include habit if it wasn't completed today
      return !lastCompleted.isAtSameMomentAs(today);
    }).toList();
  }
}
