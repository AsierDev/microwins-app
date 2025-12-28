import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../auth/data/auth_provider.dart';
import '../../habits/presentation/habit_view_model.dart';
import '../../settings/data/settings_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final habitsAsync = ref.watch(habitViewModelProvider);
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.profileTab)),
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
                            style: TextStyle(
                              fontSize: 32,
                              color: Theme.of(context).colorScheme.onPrimary,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stats Summary
          Text(
            AppLocalizations.of(context)!.statistics,
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
                        label: AppLocalizations.of(context)!.totalHabits,
                        value: totalHabits.toString(),
                        icon: Icons.eco,
                      ),
                      _StatItem(
                        label: AppLocalizations.of(context)!.bestStreak,
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
          if (kDebugMode) ...[
            Text('Debug Tools', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bug_report, color: Colors.orange),
                title: const Text('🧪 Test Worker Now'),
                subtitle: const Text(
                  'Trigger notification check in 10 seconds',
                ),
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
          ],

          // Settings Section
          Text(
            AppLocalizations.of(context)!.settingsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
                        title: Text(
                          AppLocalizations.of(context)!.notificationsLabel,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context)!.receiveDailyReminders,
                        ),
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
                  loading: () => SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)!.notificationsLabel,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.receiveDailyReminders,
                    ),
                    value: true,
                    onChanged: null,
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const Divider(height: 1),
                settingsAsync.when(
                  data: (settings) => ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      AppLocalizations.of(context)!.reminderTimeLabel,
                    ),
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
                ListTile(
                  leading: Icon(_getThemeModeIcon(themeMode)),
                  title: Text(AppLocalizations.of(context)!.themeLabel),
                  subtitle: Text(_getThemeModeName(context, themeMode)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showThemeSelector(context, ref, themeMode),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.battery_alert),
                  title: Text(
                    AppLocalizations.of(context)!.optimizeNotifications,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.disableBatteryRestrictions,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) {
                        final l10n = AppLocalizations.of(context)!;
                        return AlertDialog(
                          title: Text(l10n.enableUnrestrictedBattery),
                          content: Text(
                            '${l10n.batteryDialogMessage}\n\n'
                            '${l10n.batteryStep1}\n'
                            '${l10n.batteryStep2}\n'
                            '${l10n.batteryStep3}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(l10n.cancelButton),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                openAppSettings();
                              },
                              child: Text(l10n.goToSettings),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: Text(AppLocalizations.of(context)!.privacyPolicyLabel),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/privacy-policy');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: Text(AppLocalizations.of(context)!.viewTutorialLabel),
                  subtitle: Text(
                    AppLocalizations.of(context)!.viewTutorialSubtitle,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/onboarding?revisit=true'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: Text(AppLocalizations.of(context)!.sendFeedbackLabel),
                  subtitle: Text(
                    AppLocalizations.of(context)!.sendFeedbackSubtitle,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _launchFeedbackEmail(context),
                ),
                // Only show Delete Account for authenticated users (not anonymous)
                if (user != null && !user.isAnonymous) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.delete_forever,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.deleteAccountLabel,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.deleteAccountSubtitle,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onTap: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!.deleteAccountDialogTitle,
                          ),
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.deleteAccountDialogMessage,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                AppLocalizations.of(context)!.cancelButton,
                              ),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                AppLocalizations.of(context)!.confirmButton,
                              ),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true && context.mounted) {
                        try {
                          await ref
                              .read(authRepositoryProvider)
                              .deleteAccount();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            context.go('/login');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
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
                      child: Text(AppLocalizations.of(context)!.logoutButton),
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
            child: Text(AppLocalizations.of(context)!.logoutButton),
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

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  String _getThemeModeName(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeSystem;
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
    }
  }

  void _showThemeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.themeLabel,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: Text(l10n.themeSystem),
              subtitle: Text(l10n.themeSystemSubtitle),
              trailing: currentMode == ThemeMode.system
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                ref
                    .read(themeModeNotifierProvider.notifier)
                    .setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: Text(l10n.themeLight),
              trailing: currentMode == ThemeMode.light
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                ref
                    .read(themeModeNotifierProvider.notifier)
                    .setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: Text(l10n.themeDark),
              trailing: currentMode == ThemeMode.dark
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                ref
                    .read(themeModeNotifierProvider.notifier)
                    .setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _launchFeedbackEmail(BuildContext context) async {
    const email = 'app.microwins@gmail.com';
    const subject = 'MicroWins Feedback';

    // Get dynamic app version
    String version;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      version = packageInfo.version;
    } catch (_) {
      version = 'unknown';
    }

    final body = 'App Version: $version\n\nYour feedback:\n';
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
