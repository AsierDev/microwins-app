import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
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

          // Settings Section
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                settingsAsync.when(
                  data: (settings) => SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive daily habit reminders'),
                    value: settings.notificationsEnabled,
                    onChanged: (value) async {
                      if (value) {
                        final status = await Permission.notification.request();
                        if (status.isGranted) {
                          await ref
                              .read(settingsNotifierProvider.notifier)
                              .setNotificationsEnabled(true);
                        }
                      } else {
                        await ref
                            .read(settingsNotifierProvider.notifier)
                            .setNotificationsEnabled(false);
                      }
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
                  leading: const Icon(Icons.access_time, color: Colors.blue),
                  title: const Text('Notification System'),
                  subtitle: const Text(
                    'Using WorkManager for 100% reliable notifications.\n'
                    'May arrive within 15 minutes of scheduled time.',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('How Notifications Work'),
                          content: const Text(
                            'MicroWins uses WorkManager to check for pending '
                            'notifications every 15 minutes. This ensures notifications '
                            'ALWAYS arrive, but may be delayed up to 15 minutes.\n\n'
                            'This is the same approach used by apps like Todoist, '
                            'Microsoft To-Do, and Google Keep.\n\n'
                            'Why? Android 12+ blocks exact alarms for battery '
                            'optimization, making them unreliable.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Got it'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Learn more'),
                  ),
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
