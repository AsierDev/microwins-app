import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../habits/presentation/habit_view_model.dart';
import '../data/completion_provider.dart';
import '../domain/services/gamification_service.dart';
import '../../../l10n/app_localizations.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitViewModelProvider);
    final completionsAsync = ref.watch(completionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.progressTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: AppLocalizations.of(context)!.gamificationViewAchievements,
            onPressed: () {
              context.push('/badges');
            },
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          return completionsAsync.when(
            data: (completions) {
              final totalHabits = habits.length;

              // Usar el nuevo sistema de historial para cálculos precisos
              final completedToday = GamificationService.getCompletedTodayCount(
                completions,
              );
              final weeklyCompletions =
                  GamificationService.getWeeklyCompletions(completions);

              // Calcular estadísticas comparativas
              final weeklyProgress =
                  GamificationService.getWeeklyProgressComparison(completions);
              final isPositiveProgress = weeklyProgress >= 0;

              return RefreshIndicator(
                onRefresh: () async {
                  // Refrescar los datos al hacer pull-to-refresh
                  ref.invalidate(completionsStreamProvider);
                  ref.invalidate(habitViewModelProvider);
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Optimizar para diferentes tamaños de pantalla
                    final isSmallScreen = constraints.maxWidth < 600;
                    final cardCrossAxisCount = isSmallScreen ? 1 : 2;

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Grid de tarjetas de resumen
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: cardCrossAxisCount,
                            childAspectRatio: isSmallScreen ? 1.2 : 1.5,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                              // Tarjeta de hábitos totales
                              _buildSummaryCard(
                                context,
                                AppLocalizations.of(context)!.totalHabits,
                                totalHabits.toString(),
                                Icons.list,
                                subtitle: AppLocalizations.of(
                                  context,
                                )!.gamificationActiveHabits,
                              ),
                              // Tarjeta de progreso diario
                              _buildProgressCard(
                                context,
                                AppLocalizations.of(context)!.completedToday,
                                '$completedToday / $totalHabits',
                                Icons.check_circle,
                                progress: totalHabits > 0
                                    ? completedToday / totalHabits
                                    : 0.0,
                                color: completedToday == totalHabits
                                    ? Colors.green
                                    : completedToday > 0
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tarjeta de comparación semanal
                          _buildComparisonCard(
                            context,
                            AppLocalizations.of(
                              context,
                            )!.gamificationWeeklyProgress,
                            weeklyProgress,
                            isPositiveProgress,
                          ),
                          const SizedBox(height: 24),

                          // Título de gráfico semanal con indicador de tendencia
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.weeklyCompletion,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              if (weeklyProgress != 0)
                                _buildTrendIndicator(
                                  weeklyProgress,
                                  isPositiveProgress,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Gráfico de barras optimizado con altura responsiva
                          SizedBox(
                            height: isSmallScreen ? 180 : 220,
                            child: _buildWeeklyChart(
                              context,
                              weeklyCompletions,
                              totalHabits,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sección de motivación
                          _buildMotivationSection(
                            context,
                            completedToday,
                            totalHabits,
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
            loading: () => _buildLoadingState(context),
            error: (err, stack) => _buildErrorState(context, err, () {
              ref.invalidate(completionsStreamProvider);
              ref.invalidate(habitViewModelProvider);
            }),
          );
        },
        loading: () => _buildLoadingState(context),
        error: (err, stack) => _buildErrorState(context, err, () {
          ref.invalidate(habitViewModelProvider);
        }),
      ),
    );
  }

  /// Construye el gráfico semanal optimizado
  Widget _buildWeeklyChart(
    BuildContext context,
    Map<int, int> weeklyCompletions,
    int totalHabits,
  ) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = [
                  AppLocalizations.of(
                    context,
                  )!.gamificationMonday.substring(0, 1),
                  AppLocalizations.of(
                    context,
                  )!.gamificationTuesday.substring(0, 1),
                  AppLocalizations.of(
                    context,
                  )!.gamificationWednesday.substring(0, 1),
                  AppLocalizations.of(
                    context,
                  )!.gamificationThursday.substring(0, 1),
                  AppLocalizations.of(
                    context,
                  )!.gamificationFriday.substring(0, 1),
                  AppLocalizations.of(
                    context,
                  )!.gamificationSaturday.substring(0, 1),
                  AppLocalizations.of(
                    context,
                  )!.gamificationSunday.substring(0, 1),
                ];
                if (value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          final count = weeklyCompletions[index] ?? 0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: count > 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) =>
                Theme.of(context).colorScheme.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dayNames = [
                AppLocalizations.of(context)!.gamificationMonday,
                AppLocalizations.of(context)!.gamificationTuesday,
                AppLocalizations.of(context)!.gamificationWednesday,
                AppLocalizations.of(context)!.gamificationThursday,
                AppLocalizations.of(context)!.gamificationFriday,
                AppLocalizations.of(context)!.gamificationSaturday,
                AppLocalizations.of(context)!.gamificationSunday,
              ];
              final count = weeklyCompletions[group.x.toInt()] ?? 0;
              final percentage = totalHabits > 0
                  ? ((count / totalHabits) * 100).round()
                  : 0;
              return BarTooltipItem(
                '${dayNames[group.x.toInt()]}\n${AppLocalizations.of(context)!.gamificationCompletedCount(count, count == 1 ? '' : 's')}\n$percentage% del total',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Añadir feedback táctil
          HapticFeedback.lightImpact();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    required double progress,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(
    BuildContext context,
    String title,
    double progress,
    bool isPositive,
  ) {
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    final color = isPositive ? Colors.green : Colors.red;
    final progressText = progress.abs().toInt();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    progress == 0
                        ? AppLocalizations.of(
                            context,
                          )!.gamificationNoChangeFromLastWeek
                        : isPositive
                        ? AppLocalizations.of(
                            context,
                          )!.gamificationBetterThanLastWeek(progressText)
                        : AppLocalizations.of(
                            context,
                          )!.gamificationWorseThanLastWeek(progressText),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(double progress, bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: isPositive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            '${progress.abs().toInt()}%',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationSection(
    BuildContext context,
    int completedToday,
    int totalHabits,
  ) {
    String message;
    IconData icon;
    Color color;

    if (completedToday == 0 && totalHabits > 0) {
      message = AppLocalizations.of(
        context,
      )!.gamificationStartJourney(totalHabits);
      icon = Icons.emoji_events_outlined;
      color = Colors.orange;
    } else if (completedToday < totalHabits) {
      final remaining = totalHabits - completedToday;
      message = AppLocalizations.of(
        context,
      )!.gamificationDoingWell(remaining, remaining == 1 ? '' : 's');
      icon = Icons.directions_run;
      color = Colors.blue;
    } else if (completedToday == totalHabits && totalHabits > 0) {
      message = AppLocalizations.of(context)!.gamificationPerfectDay;
      icon = Icons.celebration;
      color = Colors.green;
    } else {
      message = AppLocalizations.of(context)!.gamificationCreateFirstHabit;
      icon = Icons.lightbulb_outline;
      color = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de estado de carga optimizado con animación
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
            AppLocalizations.of(context)!.gamificationLoadingProgress,
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
              AppLocalizations.of(context)!.gamificationErrorOccurred,
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
