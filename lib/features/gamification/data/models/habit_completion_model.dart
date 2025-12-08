import 'package:hive/hive.dart';

part 'habit_completion_model.g.dart';

@HiveType(typeId: 1)
class HabitCompletionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String habitId;

  @HiveField(2)
  late DateTime completedAt;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  late bool isSynced;

  HabitCompletionModel({
    required this.id,
    required this.habitId,
    required this.completedAt,
    required this.createdAt,
    this.isSynced = false,
  });

  factory HabitCompletionModel.create({
    required String habitId,
    required DateTime completedAt,
  }) {
    return HabitCompletionModel(
      id: '${habitId}_${completedAt.millisecondsSinceEpoch}',
      habitId: habitId,
      completedAt: completedAt,
      createdAt: DateTime.now(),
      isSynced: false,
    );
  }

  /// Verifica si esta completación corresponde a una fecha específica (ignorando hora)
  bool isForDate(DateTime date) {
    final completionDate = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
    final targetDate = DateTime(date.year, date.month, date.day);
    return completionDate.isAtSameMomentAs(targetDate);
  }

  /// Verifica si esta completación es de esta semana (lunes a domingo)
  bool isThisWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Encontrar el lunes de esta semana
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final completionDate = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );

    return !completionDate.isBefore(monday) && !completionDate.isAfter(sunday);
  }

  /// Obtiene el índice del día de la semana (0=Lunes, 6=Domingo)
  int get weekdayIndex {
    // En DateTime.weekday: 1=Lunes, 7=Domingo
    // Queremos: 0=Lunes, 6=Domingo
    return completedAt.weekday - 1;
  }

  /// Crea una copia con algunos campos modificados
  HabitCompletionModel copyWith({
    String? id,
    String? habitId,
    DateTime? completedAt,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return HabitCompletionModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
