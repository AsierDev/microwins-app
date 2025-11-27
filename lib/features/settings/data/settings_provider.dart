import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

const String _notificationsEnabledKey = 'notifications_enabled';
const String _dailyReminderTimeKey = 'daily_reminder_time';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    final dailyReminderTime = prefs.getString(_dailyReminderTimeKey) ?? '20:00';

    return SettingsState(
      notificationsEnabled: notificationsEnabled,
      dailyReminderTime: dailyReminderTime,
    );
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    final current = await future;
    state = AsyncValue.data(current.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setDailyReminderTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyReminderTimeKey, time);
    final current = await future;
    state = AsyncValue.data(current.copyWith(dailyReminderTime: time));
  }
}

class SettingsState {
  final bool notificationsEnabled;
  final String dailyReminderTime;

  SettingsState({required this.notificationsEnabled, required this.dailyReminderTime});

  SettingsState copyWith({bool? notificationsEnabled, String? dailyReminderTime}) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }
}
