import 'package:flutter/material.dart';

/// Enum for different badge types
enum BadgeType {
  streak('Streak Master', Icons.local_fire_department, Colors.orange),
  consistency('Consistency Champion', Icons.calendar_today, Colors.blue),
  weekly('Weekly Warrior', Icons.trending_up, Colors.green),
  milestone('Milestone Master', Icons.emoji_events, Colors.purple),
  perfect('Perfect Week', Icons.star, Colors.amber);

  const BadgeType(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

/// Enum for badge rarity
enum BadgeRarity {
  common('Común', Colors.grey, 1.0),
  uncommon('Poco Común', Colors.green, 1.2),
  rare('Raro', Colors.blue, 1.5),
  epic('Épico', Colors.purple, 2.0),
  legendary('Legendario', Colors.orange, 3.0);

  const BadgeRarity(this.displayName, this.color, this.multiplier);
  final String displayName;
  final Color color;
  final double multiplier;
}

/// Model representing a badge/achievement
class Badge {
  final String id;
  final String name;
  final String description;
  final BadgeType type;
  final BadgeRarity rarity;
  final String? iconPath;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    this.iconPath,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    BadgeType? type,
    BadgeRarity? rarity,
    String? iconPath,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      iconPath: iconPath ?? this.iconPath,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

/// Model representing user level
class UserLevel {
  final int level;
  final int currentExp;
  final int expToNextLevel;
  final int totalExp;
  final String title;

  const UserLevel({
    required this.level,
    required this.currentExp,
    required this.expToNextLevel,
    required this.totalExp,
    required this.title,
  });

  double get progress => expToNextLevel > 0 ? currentExp / expToNextLevel : 1.0;

  UserLevel copyWith({
    int? level,
    int? currentExp,
    int? expToNextLevel,
    int? totalExp,
    String? title,
  }) {
    return UserLevel(
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      expToNextLevel: expToNextLevel ?? this.expToNextLevel,
      totalExp: totalExp ?? this.totalExp,
      title: title ?? this.title,
    );
  }
}

/// Service that handles logic for achievements, levels and badges
class AchievementService {
  static const List<String> _levelTitles = [
    'Principiante',
    'Novato',
    'Aprendiz',
    'Practicante',
    'Dedicado',
    'Comprometido',
    'Experto',
    'Maestro',
    'Gran Maestro',
    'Leyenda',
  ];

  /// Gets all available badges
  static List<Badge> getAllBadges() {
    return [
      // Badges de Streak
      const Badge(
        id: 'streak_3',
        name: 'En Caliente',
        description: 'Completa hábitos 3 días seguidos',
        type: BadgeType.streak,
        rarity: BadgeRarity.common,
      ),
      const Badge(
        id: 'streak_7',
        name: 'Semana Perfecta',
        description: 'Completa hábitos 7 días seguidos',
        type: BadgeType.streak,
        rarity: BadgeRarity.uncommon,
      ),
      const Badge(
        id: 'streak_30',
        name: 'Mes de Leyenda',
        description: 'Completa hábitos 30 días seguidos',
        type: BadgeType.streak,
        rarity: BadgeRarity.rare,
      ),
      const Badge(
        id: 'streak_100',
        name: 'Centuria',
        description: 'Completa hábitos 100 días seguidos',
        type: BadgeType.streak,
        rarity: BadgeRarity.epic,
      ),

      // Badges de Consistencia
      const Badge(
        id: 'consistency_7_days',
        name: 'Constante',
        description: 'Completa hábitos al menos 7 días en un mes',
        type: BadgeType.consistency,
        rarity: BadgeRarity.common,
      ),
      const Badge(
        id: 'consistency_20_days',
        name: 'Muy Constante',
        description: 'Completa hábitos al menos 20 días en un mes',
        type: BadgeType.consistency,
        rarity: BadgeRarity.uncommon,
      ),
      const Badge(
        id: 'consistency_month',
        name: 'Inquebrantable',
        description: 'Completa hábitos todos los días de un mes',
        type: BadgeType.consistency,
        rarity: BadgeRarity.rare,
      ),

      // Badges Semanales
      const Badge(
        id: 'weekly_5',
        name: 'Semana Productiva',
        description: 'Completa 5 hábitos en una semana',
        type: BadgeType.weekly,
        rarity: BadgeRarity.common,
      ),
      const Badge(
        id: 'weekly_10',
        name: 'Semana Intensa',
        description: 'Completa 10 hábitos en una semana',
        type: BadgeType.weekly,
        rarity: BadgeRarity.uncommon,
      ),
      const Badge(
        id: 'weekly_20',
        name: 'Semana Épica',
        description: 'Completa 20 hábitos en una semana',
        type: BadgeType.weekly,
        rarity: BadgeRarity.rare,
      ),

      // Badges de Hitos
      const Badge(
        id: 'milestone_10',
        name: 'Primeros Pasos',
        description: 'Completa 10 hábitos en total',
        type: BadgeType.milestone,
        rarity: BadgeRarity.common,
      ),
      const Badge(
        id: 'milestone_50',
        name: 'Medio Camino',
        description: 'Completa 50 hábitos en total',
        type: BadgeType.milestone,
        rarity: BadgeRarity.uncommon,
      ),
      const Badge(
        id: 'milestone_100',
        name: 'Centurión',
        description: 'Completa 100 hábitos en total',
        type: BadgeType.milestone,
        rarity: BadgeRarity.rare,
      ),
      const Badge(
        id: 'milestone_500',
        name: 'Maestro de Hábitos',
        description: 'Completa 500 hábitos en total',
        type: BadgeType.milestone,
        rarity: BadgeRarity.epic,
      ),

      // Badges de Semana Perfecta
      const Badge(
        id: 'perfect_week_3',
        name: 'Semana Perfecta (3)',
        description:
            'Completa todos tus hábitos durante una semana (3+ hábitos)',
        type: BadgeType.perfect,
        rarity: BadgeRarity.uncommon,
      ),
      const Badge(
        id: 'perfect_week_5',
        name: 'Semana Perfecta (5)',
        description:
            'Completa todos tus hábitos durante una semana (5+ hábitos)',
        type: BadgeType.perfect,
        rarity: BadgeRarity.rare,
      ),
    ];
  }

  /// Calculates user level based on total experience
  static UserLevel calculateLevel(int totalExp) {
    // Formula: each level requires 100 * level EXP
    // Level 1: 0-99 EXP
    // Level 2: 100-299 EXP
    // Level 3: 300-599 EXP
    // etc.

    int level = 1;
    int expForCurrentLevel = 0;
    int expForNextLevel = 100;

    while (totalExp >= expForNextLevel) {
      level++;
      expForCurrentLevel = expForNextLevel;
      expForNextLevel += 100 * level;

      if (level > 10) break; // Max level
    }

    final currentExpInLevel = totalExp - expForCurrentLevel;
    final expNeededForNext = expForNextLevel - expForCurrentLevel;

    final title = level <= _levelTitles.length
        ? _levelTitles[level - 1]
        : 'Leyenda Suprema';

    return UserLevel(
      level: level,
      currentExp: currentExpInLevel,
      expToNextLevel: expNeededForNext,
      totalExp: totalExp,
      title: title,
    );
  }

  /// Calculates experience gained by completing a habit
  static int calculateExpGained({
    required int streak,
    required bool isFirstCompletionToday,
    required bool isPerfectWeek,
  }) {
    int baseExp = 10; // Base EXP for completing a habit

    // Streak bonus
    if (streak >= 30) {
      baseExp += 20; // +20 EXP for streak of 30+
    } else if (streak >= 7) {
      baseExp += 10; // +10 EXP for streak of 7+
    } else if (streak >= 3) {
      baseExp += 5; // +5 EXP for streak of 3+
    }

    // Bonus for first completion of the day
    if (isFirstCompletionToday) {
      baseExp += 5;
    }

    // Bonus for perfect week
    if (isPerfectWeek) {
      baseExp += 15;
    }

    return baseExp;
  }

  /// Checks which badges have been unlocked
  static List<Badge> checkUnlockedBadges({
    required int currentStreak,
    required int bestStreak,
    required int totalCompletions,
    required int weeklyCompletions,
    required int monthlyCompletions,
    required int totalHabits,
    required bool hasPerfectWeek,
  }) {
    final allBadges = getAllBadges();
    final unlockedBadges = <Badge>[];

    for (final badge in allBadges) {
      bool isUnlocked = false;

      switch (badge.id) {
        // Streak badges
        case 'streak_3':
          isUnlocked = currentStreak >= 3 || bestStreak >= 3;
          break;
        case 'streak_7':
          isUnlocked = currentStreak >= 7 || bestStreak >= 7;
          break;
        case 'streak_30':
          isUnlocked = currentStreak >= 30 || bestStreak >= 30;
          break;
        case 'streak_100':
          isUnlocked = currentStreak >= 100 || bestStreak >= 100;
          break;

        // Consistency badges
        case 'consistency_7_days':
          isUnlocked = monthlyCompletions >= 7;
          break;
        case 'consistency_20_days':
          isUnlocked = monthlyCompletions >= 20;
          break;
        case 'consistency_month':
          isUnlocked =
              monthlyCompletions >= 28; // Assuming month of at least 28 days
          break;

        // Weekly badges
        case 'weekly_5':
          isUnlocked = weeklyCompletions >= 5;
          break;
        case 'weekly_10':
          isUnlocked = weeklyCompletions >= 10;
          break;
        case 'weekly_20':
          isUnlocked = weeklyCompletions >= 20;
          break;

        // Milestone badges
        case 'milestone_10':
          isUnlocked = totalCompletions >= 10;
          break;
        case 'milestone_50':
          isUnlocked = totalCompletions >= 50;
          break;
        case 'milestone_100':
          isUnlocked = totalCompletions >= 100;
          break;
        case 'milestone_500':
          isUnlocked = totalCompletions >= 500;
          break;

        // Perfect week badges
        case 'perfect_week_3':
          isUnlocked = hasPerfectWeek && totalHabits >= 3;
          break;
        case 'perfect_week_5':
          isUnlocked = hasPerfectWeek && totalHabits >= 5;
          break;
      }

      if (isUnlocked) {
        unlockedBadges.add(
          badge.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
        );
      }
    }

    return unlockedBadges;
  }

  /// Gets new badges (not previously unlocked)
  static List<Badge> getNewBadges(
    List<Badge> allBadges,
    List<Badge> previouslyUnlocked,
  ) {
    final previousIds = previouslyUnlocked.map((b) => b.id).toSet();
    return allBadges
        .where((b) => b.isUnlocked && !previousIds.contains(b.id))
        .toList();
  }
}
