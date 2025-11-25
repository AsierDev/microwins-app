import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit.freezed.dart';

@freezed
class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String name,
    required String icon,
    required String category,
    required int durationMinutes,
    @Default(0) int currentStreak,
    @Default(0) int bestStreak,
    @Default(0) int sortOrder,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastCompletedDate,
    DateTime? lastNotifiedDate,
    @Default(false) bool isSynced,
  }) = _Habit;
}
