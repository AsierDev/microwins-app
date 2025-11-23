import 'package:hive_flutter/hive_flutter.dart';

part 'habit_reminder_model.g.dart';

@HiveType(typeId: 3)
class HabitReminderModel {
  @HiveField(0)
  final String habitId;

  @HiveField(1)
  final String habitName;

  @HiveField(2)
  final String reminderTime; // Format: "HH:mm"

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final DateTime? lastNotifiedDate;

  HabitReminderModel({
    required this.habitId,
    required this.habitName,
    required this.reminderTime,
    required this.durationMinutes,
    this.lastNotifiedDate,
  });

  HabitReminderModel copyWith({
    String? habitId,
    String? habitName,
    String? reminderTime,
    int? durationMinutes,
    DateTime? lastNotifiedDate,
  }) {
    return HabitReminderModel(
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      reminderTime: reminderTime ?? this.reminderTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      lastNotifiedDate: lastNotifiedDate ?? this.lastNotifiedDate,
    );
  }
}
