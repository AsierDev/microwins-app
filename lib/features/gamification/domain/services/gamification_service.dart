import 'package:uuid/uuid.dart';
import '../../../gamification/data/models/habit_completion_model.dart';

/// Service that handles gamification logic and progress tracking
class GamificationService {
  static const Uuid _uuid = Uuid();

  /// Records a new habit completion
  static HabitCompletionModel recordCompletion({
    required String habitId,
    required DateTime completedAt,
  }) {
    return HabitCompletionModel.create(
      habitId: habitId,
      completedAt: completedAt,
    );
  }

  /// Calculates current streak based on completion history
  static int calculateCurrentStreak(List<HabitCompletionModel> completions) {
    if (completions.isEmpty) return 0;

    // Sort completions by date (most recent first)
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
        // First completion, check if it's today or yesterday
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));

        if (completionDate.isAtSameMomentAs(today) ||
            completionDate.isAtSameMomentAs(yesterday)) {
          streak = 1;
          currentDate = completionDate;
        } else {
          break; // No active streak
        }
      } else {
        // Check if it's the day before the current one
        final expectedPreviousDay = currentDate.subtract(
          const Duration(days: 1),
        );

        if (completionDate.isAtSameMomentAs(expectedPreviousDay)) {
          streak++;
          currentDate = completionDate;
        } else if (completionDate.isBefore(expectedPreviousDay)) {
          break; // Streak broken
        }
        // If newer (same day), continue (multiple completions on the same day)
      }
    }

    return streak;
  }

  /// Calculates the best historical streak
  static int calculateBestStreak(List<HabitCompletionModel> completions) {
    if (completions.isEmpty) return 0;

    // Group completions by day
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

    // Sort days
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

  /// Gets current week completions grouped by day
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

  /// Checks if a habit was completed today
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

  /// Gets the count of habits completed today
  static int getCompletedTodayCount(List<HabitCompletionModel> completions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayCompletions = completions
        .where((completion) => completion.isForDate(today))
        .toList();

    // Count unique habits (ignore multiple completions of the same habit)
    final uniqueHabitIds = todayCompletions.map((c) => c.habitId).toSet();
    return uniqueHabitIds.length;
  }

  /// Compares progress with the previous week (same elapsed days)
  /// For example, if today is Wednesday, compare M-T-W of this week
  /// with M-T-W of last week for a fair comparison.
  static double getWeeklyProgressComparison(
    List<HabitCompletionModel> allCompletions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // This week (Monday to today)
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

    // Last week: same period (from Monday to the same day of the week)
    final lastMonday = thisMonday.subtract(const Duration(days: 7));
    final lastWeekSameDay = today.subtract(const Duration(days: 7));
    final lastWeekCompletions = allCompletions.where((c) {
      final completionDate = DateTime(
        c.completedAt.year,
        c.completedAt.month,
        c.completedAt.day,
      );
      return !completionDate.isBefore(lastMonday) &&
          !completionDate.isAfter(lastWeekSameDay);
    }).length;

    if (lastWeekCompletions == 0) return thisWeekCompletions > 0 ? 100.0 : 0.0;

    return ((thisWeekCompletions - lastWeekCompletions) / lastWeekCompletions) *
        100;
  }
}
