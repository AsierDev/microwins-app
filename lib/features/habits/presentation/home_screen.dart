import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/ads/ad_helper.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/logger.dart';
import '../../auth/data/auth_provider.dart';
import '../domain/entities/habit.dart';
import 'habit_view_model.dart';
import 'widgets/habit_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Request notification permissions on first app access
    _requestNotificationPermissionsIfNeeded();
  }

  Future<void> _requestNotificationPermissionsIfNeeded() async {
    if (kIsWeb) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRequestedBefore = prefs.getBool('has_requested_notification_permission') ?? false;

      if (!hasRequestedBefore) {
        AppLogger.info('First app access - requesting notification permissions', tag: 'HomeScreen');

        // Request permissions
        final granted = await NotificationService().requestPermissions();

        // Sync with app settings
        await prefs.setBool('notifications_enabled', granted);
        await prefs.setBool('has_requested_notification_permission', true);

        AppLogger.info(
          'Notification permissions ${granted ? "granted" : "denied"}',
          tag: 'HomeScreen',
        );
      } else {
        // Already requested before - sync current status with settings
        final currentStatus = await NotificationService().checkPermissionStatus();
        await prefs.setBool('notifications_enabled', currentStatus);

        AppLogger.debug('Synced notification permission status: $currentStatus', tag: 'HomeScreen');
      }
    } catch (e) {
      AppLogger.error('Error requesting notification permissions', tag: 'HomeScreen', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MicroWins'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.eco_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No habits yet. Start small!'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/create-habit'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Habit'),
                  ),
                ],
              ),
            );
          }
          final sortedHabits = List<Habit>.from(habits)
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          return ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            buildDefaultDragHandles: false,
            itemCount: sortedHabits.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(habitViewModelProvider.notifier).reorderHabits(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final habit = sortedHabits[index];
              return Dismissible(
                key: ValueKey(habit.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm'),
                        content: const Text('Are you sure you want to delete this habit?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('DELETE'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  ref.read(habitViewModelProvider.notifier).deleteHabit(habit.id);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('${habit.name} deleted')));
                },
                child: GestureDetector(
                  onLongPress: () {
                    context.push('/create-habit', extra: habit);
                  },
                  child: HabitCard(
                    habit: habit,
                    showDragHandle: true,
                    index: index,
                    onComplete: () {
                      ref.read(habitViewModelProvider.notifier).completeHabit(habit.id);
                    },
                    onTap: () {
                      // Navigate to details
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: habitsAsync.hasValue && habitsAsync.value!.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => context.push('/create-habit'),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: const SafeArea(child: kIsWeb ? SizedBox.shrink() : BannerAdWidget()),
    );
  }
}
