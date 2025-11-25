import '../../domain/entities/habit.dart';
import '../models/habit_model.dart';

class HabitMapper {
  static Habit toEntity(HabitModel model) {
    return Habit(
      id: model.id,
      name: model.name,
      icon: model.icon,
      category: model.category,
      durationMinutes: model.durationMinutes,
      currentStreak: model.currentStreak,
      bestStreak: model.bestStreak,
      sortOrder: model.sortOrder,
      isArchived: model.isArchived,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      lastCompletedDate: model.lastCompletedDate,
      lastNotifiedDate: model.lastNotifiedDate,
      isSynced: model.isSynced,
    );
  }

  static HabitModel toModel(Habit entity) {
    return HabitModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      category: entity.category,
      durationMinutes: entity.durationMinutes,
      currentStreak: entity.currentStreak,
      bestStreak: entity.bestStreak,
      sortOrder: entity.sortOrder,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastCompletedDate: entity.lastCompletedDate,
      lastNotifiedDate: entity.lastNotifiedDate,
      isSynced: entity.isSynced,
    );
  }
}
