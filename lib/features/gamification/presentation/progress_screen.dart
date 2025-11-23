import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../habits/presentation/habit_view_model.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: habitsAsync.when(
        data: (habits) {
          final totalHabits = habits.length;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          int completedToday = 0;
          final Map<int, int> weeklyCompletions = {}; // 0 = Mon, 6 = Sun

          for (var h in habits) {
            if (h.lastCompletedDate != null) {
              final lastDate = h.lastCompletedDate!;
              final lastCompletedDay = DateTime(
                lastDate.year,
                lastDate.month,
                lastDate.day,
              );

              if (lastCompletedDay.isAtSameMomentAs(today)) {
                completedToday++;
              }

              // Very basic weekly tracking based on last completion only (Limitation of MVP model)
              // If we had full history, we'd iterate that.
              // For now, we only show the bar for the day it was last completed if it falls in current week.
              final difference = today.difference(lastCompletedDay).inDays;
              if (difference < 7) {
                // weekday is 1 (Mon) to 7 (Sun). We want 0-6 index.
                // We want to map this to the chart's X axis which is 0..6
                // Let's assume chart X=0 is Today - 6 days, X=6 is Today.
                // OR chart X=0 is Mon, X=6 is Sun. Let's stick to Mon-Sun fixed for simplicity.

                final int weekdayIndex =
                    lastCompletedDay.weekday - 1; // 0=Mon, 6=Sun
                weeklyCompletions[weekdayIndex] =
                    (weeklyCompletions[weekdayIndex] ?? 0) + 1;
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCard(
                context,
                'Total Habits',
                totalHabits.toString(),
                Icons.list,
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                context,
                'Completed Today',
                '$completedToday / $totalHabits',
                Icons.check_circle,
              ),
              const SizedBox(height: 24),
              const Text(
                'Weekly Completion',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
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
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            if (value.toInt() < days.length) {
                              return Text(days[value.toInt()]);
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (index) {
                      // index 0 = Mon, 6 = Sun
                      final count = weeklyCompletions[index] ?? 0;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: count.toDouble(),
                            color: Theme.of(context).colorScheme.primary,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
