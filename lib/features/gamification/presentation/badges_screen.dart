import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/services/achievement_service.dart' as achievement;
import '../data/completion_provider.dart';
import '../data/models/habit_completion_model.dart';
import '../domain/services/gamification_service.dart';
import '../../../l10n/app_localizations.dart';

class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  @override
  Widget build(BuildContext context) {
    final completionRepository = ref.read(completionRepositoryProvider);
    final allBadges = achievement.AchievementService.getAllBadges();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.gamificationBadgesAndLevels),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: FutureBuilder<List<HabitCompletionModel>>(
        future: completionRepository.getCompletions(),
        builder: (context, completionsSnapshot) {
          if (completionsSnapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState(context);
          }

          if (completionsSnapshot.hasError) {
            return _buildErrorState(context, completionsSnapshot.error!, () {
              setState(() {}); // Reintentar la carga
            });
          }

          final completions = completionsSnapshot.data ?? [];

          // Calcular estadísticas del usuario
          final totalCompletions = completions.length;
          final userLevel = achievement.AchievementService.calculateLevel(
            totalCompletions,
          );

          // Calcular streaks por hábito
          final Map<String, int> habitStreaks = {};
          final Map<String, int> habitBestStreaks = {};

          // Agrupar completiones por hábito
          final Map<String, List<HabitCompletionModel>> completionsByHabit = {};
          for (final completion in completions) {
            if (!completionsByHabit.containsKey(completion.habitId)) {
              completionsByHabit[completion.habitId] = [];
            }
            completionsByHabit[completion.habitId]!.add(completion);
          }

          // Calcular streaks para cada hábito
          for (final entry in completionsByHabit.entries) {
            final currentStreak = GamificationService.calculateCurrentStreak(
              entry.value,
            );
            final bestStreak = GamificationService.calculateBestStreak(
              entry.value,
            );
            habitStreaks[entry.key] = currentStreak;
            habitBestStreaks[entry.key] = bestStreak;
          }

          final bestStreak = habitBestStreaks.values.isEmpty
              ? 0
              : habitBestStreaks.values.reduce((a, b) => a > b ? a : b);

          final currentStreak = habitStreaks.values.isEmpty
              ? 0
              : habitStreaks.values.reduce((a, b) => a > b ? a : b);

          // Verificar badges desbloqueados
          final unlockedBadges =
              achievement.AchievementService.checkUnlockedBadges(
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                totalCompletions: totalCompletions,
                weeklyCompletions: GamificationService.getWeeklyCompletions(
                  completions,
                ).values.fold(0, (a, b) => a + b),
                monthlyCompletions: _getMonthlyCompletions(completions),
                totalHabits: completionsByHabit.keys.length,
                hasPerfectWeek: _hasPerfectWeek(completionsByHabit),
              );

          return RefreshIndicator(
            onRefresh: () async {
              // Refrescar datos al hacer pull-to-refresh
              ref.invalidate(completionRepositoryProvider);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                final crossAxisCount = isSmallScreen ? 2 : 3;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección de nivel del usuario optimizada
                      _buildUserLevelCard(context, userLevel, totalCompletions),
                      const SizedBox(height: 24),

                      // Sección de estadísticas con diseño responsivo
                      _buildStatsCard(
                        context,
                        currentStreak,
                        bestStreak,
                        totalCompletions,
                        isSmallScreen,
                      ),
                      const SizedBox(height: 24),

                      // Sección de badges con grid responsivo
                      _buildBadgesSection(
                        context,
                        allBadges,
                        unlockedBadges,
                        crossAxisCount,
                        isSmallScreen,
                      ),

                      // Espacio adicional para scroll en pantallas pequeñas
                      if (isSmallScreen) const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserLevelCard(
    BuildContext context,
    achievement.UserLevel level,
    int totalCompletions,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      level.level.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.gamificationExperience(level.totalExp),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: level.progress,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.gamificationExpToNextLevel(
                          level.expToNextLevel - level.currentExp,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    int currentStreak,
    int bestStreak,
    int totalCompletions,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.gamificationStatistics,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Grid responsivo para estadísticas
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isSmallScreen ? 1 : 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatItem(
                  context,
                  AppLocalizations.of(context)!.gamificationCurrentStreak,
                  currentStreak.toString(),
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  AppLocalizations.of(context)!.gamificationBestStreak,
                  bestStreak.toString(),
                  Icons.emoji_events,
                  Colors.purple,
                ),
                _buildStatItem(
                  context,
                  AppLocalizations.of(context)!.gamificationTotalCompleted,
                  totalCompletions.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(
    BuildContext context,
    List<achievement.Badge> allBadges,
    List<achievement.Badge> unlockedBadges,
    int crossAxisCount,
    bool isSmallScreen,
  ) {
    final unlockedIds = unlockedBadges.map((b) => b.id).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con contador de progreso
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.gamificationAchievementCollection,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                AppLocalizations.of(context)!.gamificationUnlockedCount(
                  allBadges.length,
                  unlockedBadges.length,
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Agrupar badges por tipo con grid responsivo
        ...achievement.BadgeType.values.map((type) {
          final typeBadges = allBadges.where((b) => b.type == type).toList();
          if (typeBadges.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.displayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: type.color,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.0,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: typeBadges
                    .map(
                      (badge) => _buildBadgeCard(
                        context,
                        badge,
                        unlockedIds.contains(badge.id),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBadgeCard(
    BuildContext context,
    achievement.Badge badge,
    bool isUnlocked,
  ) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isUnlocked
            ? badge.rarity.color.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? badge.rarity.color.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: badge.rarity.color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? badge.type.icon : Icons.help_outline,
            size: 32,
            color: isUnlocked ? badge.rarity.color : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isUnlocked ? badge.rarity.color : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badge.rarity.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge.rarity.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getMonthlyCompletions(List<HabitCompletionModel> completions) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    return completions.where((completion) {
      return !completion.completedAt.isBefore(currentMonth) &&
          completion.completedAt.isBefore(nextMonth);
    }).length;
  }

  bool _hasPerfectWeek(
    Map<String, List<HabitCompletionModel>> completionsByHabit,
  ) {
    for (final entry in completionsByHabit.entries) {
      final weeklyCompletions = GamificationService.getWeeklyCompletions(
        entry.value,
      );
      final totalWeekly = weeklyCompletions.values.fold(0, (a, b) => a + b);

      // Si completó hábitos todos los días de la semana (7 días)
      if (totalWeekly >= 7) {
        return true;
      }
    }
    return false;
  }

  /// Widget de estado de carga optimizado
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.gamificationLoadingAchievements,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de estado de error con opción de reintentar
  Widget _buildErrorState(
    BuildContext context,
    Object error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(
                context,
              )!.gamificationErrorLoadingAchievements,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.gamificationRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
