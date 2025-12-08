import 'package:uuid/uuid.dart';
import '../../../gamification/data/models/habit_completion_model.dart';

/// Servicio que maneja la lógica de gamificación y seguimiento de progreso
class GamificationService {
  static const Uuid _uuid = Uuid();

  /// Registra una nueva completación de hábito
  static HabitCompletionModel recordCompletion({
    required String habitId,
    required DateTime completedAt,
  }) {
    return HabitCompletionModel.create(
      habitId: habitId,
      completedAt: completedAt,
    );
  }

  /// Calcula el streak actual basado en el historial de completiones
  static int calculateCurrentStreak(List<HabitCompletionModel> completions) {
    if (completions.isEmpty) return 0;

    // Ordenar completiones por fecha (más reciente primero)
    final sortedCompletions = List<HabitCompletionModel>.from(completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    int streak = 0;
    DateTime? currentDate;

    for (final completion in sortedCompletions) {
      final completionDate = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );

      if (currentDate == null) {
        // Primera completación, verificar si es hoy o ayer
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));

        if (completionDate.isAtSameMomentAs(today) ||
            completionDate.isAtSameMomentAs(yesterday)) {
          streak = 1;
          currentDate = completionDate;
        } else {
          break; // No hay streak activo
        }
      } else {
        // Verificar si es el día anterior al actual
        final expectedPreviousDay = currentDate.subtract(
          const Duration(days: 1),
        );

        if (completionDate.isAtSameMomentAs(expectedPreviousDay)) {
          streak++;
          currentDate = completionDate;
        } else if (completionDate.isBefore(expectedPreviousDay)) {
          break; // Rompió el streak
        }
        // Si es posterior, continuamos (múltiples completiones del mismo día)
      }
    }

    return streak;
  }

  /// Calcula el mejor streak histórico
  static int calculateBestStreak(List<HabitCompletionModel> completions) {
    if (completions.isEmpty) return 0;

    // Agrupar completiones por día
    final Map<DateTime, List<HabitCompletionModel>> dailyCompletions = {};

    for (final completion in completions) {
      final day = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );

      if (!dailyCompletions.containsKey(day)) {
        dailyCompletions[day] = [];
      }
      dailyCompletions[day]!.add(completion);
    }

    // Ordenar los días
    final sortedDays = dailyCompletions.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    int currentStreak = 0;
    int bestStreak = 0;
    DateTime? lastDay;

    for (final day in sortedDays) {
      if (lastDay == null) {
        currentStreak = 1;
      } else {
        final expectedPreviousDay = day.subtract(const Duration(days: 1));
        if (lastDay.isAtSameMomentAs(expectedPreviousDay)) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }

      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }

      lastDay = day;
    }

    return bestStreak;
  }

  /// Obtiene las completiones de la semana actual agrupadas por día
  static Map<int, int> getWeeklyCompletions(
    List<HabitCompletionModel> completions,
  ) {
    final Map<int, int> weeklyCompletions = {};

    for (final completion in completions) {
      if (completion.isThisWeek()) {
        final dayIndex = completion.weekdayIndex;
        weeklyCompletions[dayIndex] = (weeklyCompletions[dayIndex] ?? 0) + 1;
      }
    }

    return weeklyCompletions;
  }

  /// Verifica si un hábito fue completado hoy
  static bool isCompletedToday(
    List<HabitCompletionModel> completions,
    String habitId,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return completions.any(
      (completion) =>
          completion.habitId == habitId && completion.isForDate(today),
    );
  }

  /// Obtiene el número de hábitos completados hoy
  static int getCompletedTodayCount(List<HabitCompletionModel> completions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayCompletions = completions
        .where((completion) => completion.isForDate(today))
        .toList();

    // Contar hábitos únicos (no completiones múltiples del mismo hábito)
    final uniqueHabitIds = todayCompletions.map((c) => c.habitId).toSet();
    return uniqueHabitIds.length;
  }

  /// Compara el progreso con la semana anterior
  static double getWeeklyProgressComparison(
    List<HabitCompletionModel> allCompletions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Esta semana (lunes a domingo actual)
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final thisWeekCompletions = allCompletions.where((c) {
      final completionDate = DateTime(
        c.completedAt.year,
        c.completedAt.month,
        c.completedAt.day,
      );
      return !completionDate.isBefore(thisMonday) &&
          !completionDate.isAfter(today);
    }).length;

    // Semana pasada (lunes a domingo anterior)
    final lastMonday = thisMonday.subtract(const Duration(days: 7));
    final lastSunday = thisMonday.subtract(const Duration(days: 1));
    final lastWeekCompletions = allCompletions.where((c) {
      final completionDate = DateTime(
        c.completedAt.year,
        c.completedAt.month,
        c.completedAt.day,
      );
      return !completionDate.isBefore(lastMonday) &&
          !completionDate.isAfter(lastSunday);
    }).length;

    if (lastWeekCompletions == 0) return thisWeekCompletions > 0 ? 100.0 : 0.0;

    return ((thisWeekCompletions - lastWeekCompletions) / lastWeekCompletions) *
        100;
  }
}
