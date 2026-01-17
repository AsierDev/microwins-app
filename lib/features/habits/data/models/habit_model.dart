import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late String category;

  @HiveField(4)
  late int durationMinutes;

  @HiveField(7)
  late int currentStreak;

  @HiveField(8)
  late int bestStreak;

  @HiveField(9)
  late int sortOrder;

  @HiveField(10)
  late bool isArchived;

  @HiveField(11)
  late DateTime createdAt;

  @HiveField(12)
  late DateTime updatedAt;

  @HiveField(13)
  late bool isSynced;

  @HiveField(14)
  DateTime? lastCompletedDate;

  @HiveField(15)
  DateTime? lastNotifiedDate;

  @HiveField(16)
  String? customReminderTime;

  @HiveField(17)
  late bool reminderEnabled;

  HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.durationMinutes,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.sortOrder = 0,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.lastCompletedDate,
    this.lastNotifiedDate,
    this.customReminderTime,
    this.reminderEnabled = true,
  });
}
