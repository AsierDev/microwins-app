import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

const String _notificationsEnabledKey = 'notifications_enabled';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled =
        prefs.getBool(_notificationsEnabledKey) ?? true;

    return SettingsState(notificationsEnabled: notificationsEnabled);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    state = AsyncValue.data(SettingsState(notificationsEnabled: enabled));
  }
}

class SettingsState {
  final bool notificationsEnabled;

  SettingsState({required this.notificationsEnabled});
}
