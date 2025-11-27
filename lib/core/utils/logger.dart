import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logging service for the application
/// Provides structured logging with different levels
class AppLogger {
  static const String _appName = 'MicroWins';

  /// Log debug information (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? 'Debug';
      developer.log(
        message,
        name: '$_appName:$logTag',
        level: 500, // Debug level
      );
    }
  }

  /// Log informational messages (only in debug mode)
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? 'Info';
      developer.log(
        message,
        name: '$_appName:$logTag',
        level: 800, // Info level
      );
    }
  }

  /// Log warnings (always logged)
  static void warning(String message, {String? tag, Object? error}) {
    final logTag = tag ?? 'Warning';
    developer.log(
      message,
      name: '$_appName:$logTag',
      level: 900, // Warning level
      error: error,
    );
  }

  /// Log errors (always logged)
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final logTag = tag ?? 'Error';
    developer.log(
      message,
      name: '$_appName:$logTag',
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log critical errors that should be reported to crash analytics
  static void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final logTag = tag ?? 'Critical';
    developer.log(
      message,
      name: '$_appName:$logTag',
      level: 1200, // Severe level
      error: error,
      stackTrace: stackTrace,
    );

    // TODO: Send to crash reporting service (Firebase Crashlytics, Sentry, etc.)
    // if (kReleaseMode) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
    // }
  }
}
