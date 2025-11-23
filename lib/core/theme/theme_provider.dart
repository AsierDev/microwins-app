import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

const String _themeModeKey = 'theme_mode';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    // Load theme synchronously by checking SharedPreferences
    // This prevents the toggle from showing wrong state on startup
    _loadThemeModeSync();
    return state;
  }

  void _loadThemeModeSync() {
    // We need to handle this asynchronously but update state when ready
    SharedPreferences.getInstance().then((prefs) {
      final themeModeString = prefs.getString(_themeModeKey);
      if (themeModeString != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      } else {
        state = ThemeMode.system;
      }
    });
    // Return system as default immediately
    state = ThemeMode.system;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Toggle between light and dark (skip system for now)
    if (state == ThemeMode.dark) {
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
