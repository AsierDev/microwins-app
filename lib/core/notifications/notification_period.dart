/// Notification periods for habit reminders
/// Replaces exact time selection with user-friendly time periods
enum NotificationPeriod {
  morning('morning', 'Morning', '🌅', 7, 0, 11, 59),
  midday('midday', 'Midday', '☀️', 12, 0, 16, 59),
  evening('evening', 'Evening', '🌇', 17, 0, 20, 59),
  night('night', 'Night', '🌙', 21, 0, 23, 59);

  const NotificationPeriod(
    this.value,
    this.label,
    this.icon,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
  );

  final String value;
  final String label;
  final String icon;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  /// Get the target time to show notifications (start of period)
  String toTimeString() {
    return '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  }

  /// Check if current time is within this period
  bool isWithinPeriod(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final currentMinutes = hour * 60 + minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  /// Parse a time string or period value to NotificationPeriod
  /// Supports both period values ('morning') and time strings ('09:00')
  static NotificationPeriod fromString(String value) {
    // Try to parse as period value first
    try {
      return NotificationPeriod.values.firstWhere(
        (period) => period.value == value.toLowerCase(),
      );
    } catch (_) {
      // If not a period value, try to parse as time string and map to closest period
      return fromTimeString(value);
    }
  }

  /// Map a time string (HH:mm) to the closest notification period
  /// Used for migrating existing habits with exact times
  static NotificationPeriod fromTimeString(String timeString) {
    if (timeString.isEmpty) return NotificationPeriod.morning;

    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return NotificationPeriod.morning;

      final hour = int.parse(parts[0]);

      // Map to period based on hour (matches period ranges)
      if (hour < 12) {
        return NotificationPeriod.morning; // 7:00-11:59
      } else if (hour < 17) {
        return NotificationPeriod.midday; // 12:00-16:59
      } else if (hour < 21) {
        return NotificationPeriod.evening; // 17:00-20:59
      } else {
        return NotificationPeriod.night; // 21:00-23:59
      }
    } catch (_) {
      return NotificationPeriod.morning; // Default fallback
    }
  }

  /// Get display text for the period
  String get displayName => '$icon $label';
}
