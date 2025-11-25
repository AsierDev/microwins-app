import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import '../../auth/data/auth_provider.dart';
import '../../habits/presentation/habit_view_model.dart';
import '../../settings/data/settings_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/notifications/notification_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final habitsAsync = ref.watch(habitViewModelProvider);
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Text(
                            _getInitial(user),
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stats Summary
          Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: habitsAsync.when(
                data: (habits) {
                  final totalHabits = habits.length;
                  final bestStreak = habits.isNotEmpty
                      ? habits
                            .map((h) => h.bestStreak)
                            .reduce((a, b) => a > b ? a : b)
                      : 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Total Habits',
                        value: totalHabits.toString(),
                        icon: Icons.eco,
                      ),
                      _StatItem(
                        label: 'Best Streak',
                        value: bestStreak.toString(),
                        icon: Icons.local_fire_department,
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Unable to load stats'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Debug Section
          Text('Debug Tools', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.orange),
              title: const Text('🧪 Test Worker Now'),
              subtitle: const Text('Trigger notification check in 10 seconds'),
              onTap: () async {
                await Workmanager().registerOneOffTask(
                  'debug_test',
                  'habitCheck',
                  initialDelay: const Duration(seconds: 10),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '⏱️ Worker will fire in 10s. Check logs with:\n'
                        'adb logcat | grep -E "(HabitCheckWorker|Flutter)"',
                      ),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Settings Section
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                settingsAsync.when(
                  data: (settings) => FutureBuilder<bool>(
                    // Check actual permission status from system
                    future: NotificationService().checkPermissionStatus(),
                    builder: (context, snapshot) {
                      final actualStatus =
                          snapshot.data ?? settings.notificationsEnabled;
                      return SwitchListTile(
                        title: const Text('Enable Notifications'),
                        subtitle: const Text('Receive daily habit reminders'),
                        value: actualStatus,
                        onChanged: (value) async {
                          if (value) {
                            final status = await Permission.notification
                                .request();
                            if (status.isGranted) {
                              await ref
                                  .read(settingsNotifierProvider.notifier)
                                  .setNotificationsEnabled(true);
                            } else {
                              // Permission denied - show message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Notification permission denied. Please enable in system settings.',
                                    ),
                                  ),
                                );
                              }
                            }
                          } else {
                            await ref
                                .read(settingsNotifierProvider.notifier)
                                .setNotificationsEnabled(false);
                          }
                        },
                      );
                    },
                  ),
                  loading: () => const SwitchListTile(
                    title: Text('Enable Notifications'),
                    subtitle: Text('Receive daily habit reminders'),
                    value: true,
                    onChanged: null,
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const Divider(height: 1),
                settingsAsync.when(
                  data: (settings) => ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Daily Reminder Time'),
                    subtitle: Text(
                      _formatTime(settings.dailyReminderTime),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.edit, size: 16),
                    onTap: () async {
                      final timeParts = settings.dailyReminderTime.split(':');
                      final initialTime = TimeOfDay(
                        hour: int.parse(timeParts[0]),
                        minute: int.parse(timeParts[1]),
                      );

                      final picked = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                      );

                      if (picked != null) {
                        final timeString =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        await ref
                            .read(settingsNotifierProvider.notifier)
                            .setDailyReminderTime(timeString);
                      }
                    },
                  ),
                  loading: () => const ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text('Daily Reminder Time'),
                    subtitle: Text('Loading...'),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(themeModeNotifierProvider.notifier).toggleTheme();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.battery_alert),
                  title: const Text('Optimize Notifications'),
                  subtitle: const Text(
                    'Disable battery restrictions for accurate reminders',
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Enable Unrestricted Battery'),
                        content: const Text(
                          'To ensure reminders arrive on time, please disable battery restrictions for MicroWins.\n\n'
                          '1. Tap "Go to Settings"\n'
                          '2. Tap "App battery usage" or "Battery"\n'
                          '3. Select "Unrestricted" or "No restrictions"',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              openAppSettings();
                            },
                            child: const Text('Go to Settings'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/privacy-policy');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          FilledButton.tonal(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade900,
            ),
            child: const Text('Log Out'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getInitial(User? user) {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.substring(0, 1).toUpperCase();
    }
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  String _formatTime(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
