import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../habits/presentation/habit_view_model.dart';
import 'ai_view_model.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _goalController = TextEditingController();

  // Quick start suggestions
  final List<String> _quickStarts = [
    'Sleep Better',
    'Reduce Stress',
    'Learn a Skill',
    'Stay Hydrated',
  ];

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_goalController.text.isNotEmpty) {
      ref.read(aiViewModelProvider.notifier).generateHabits(_goalController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiViewModelProvider);
    final habitState = ref.watch(habitViewModelProvider);
    final existingHabitNames =
        habitState.valueOrNull?.map((h) => h.name.toLowerCase()).toSet() ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Habits')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _goalController,
              decoration: InputDecoration(
                labelText: 'What is your goal?',
                hintText: 'e.g., Sleep better, Learn Spanish',
                suffixIcon: IconButton(onPressed: _generate, icon: const Icon(Icons.auto_awesome)),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _generate(),
            ),
            const SizedBox(height: 12),
            // Quick Start chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickStarts.map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    _goalController.text = suggestion;
                    _generate();
                  },
                  avatar: const Icon(Icons.lightbulb_outline, size: 18),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: aiState.when(
                data: (habits) {
                  if (habits.isEmpty) {
                    return const Center(child: Text('Enter a goal to generate micro-habits!'));
                  }
                  return ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      final isAdded = existingHabitNames.contains(habit.name.toLowerCase());

                      return Card(
                        child: ListTile(
                          leading: Text(habit.icon, style: const TextStyle(fontSize: 24)),
                          title: Text(habit.name),
                          subtitle: Text('${habit.durationMinutes} min • ${habit.category}'),
                          trailing: isAdded
                              ? const IconButton(
                                  icon: Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: null,
                                )
                              : IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    ref
                                        .read(habitViewModelProvider.notifier)
                                        .addHabit(
                                          name: habit.name,
                                          icon: habit.icon,
                                          category: habit.category,
                                          durationMinutes: habit.durationMinutes,
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added "${habit.name}" to your habits!'),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: $err\n\nMake sure OPENROUTER_API_KEY is set in .env',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
