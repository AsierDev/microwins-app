import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

const String _themeModeKey = 'theme_mode';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    // Initialize with system theme brightness
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    state = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

    // Load saved theme asynchronously
    _loadThemeMode();
    return state;
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () =>
            state, // Keep current state (system-based) if parsing fails
      );
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Toggle between light and dark (skip system for now)
    if (state == ThemeMode.dark || state == ThemeMode.system) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }

    await prefs.setString(_themeModeKey, state.toString());
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    state = mode;
    await prefs.setString(_themeModeKey, mode.toString());
  }
}
