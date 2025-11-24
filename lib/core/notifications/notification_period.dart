/// Notification periods for habit reminders
/// Replaces exact time selection with user-friendly time periods
enum NotificationPeriod {
  morning('morning', 'Morning', '🌅', 9, 0),
  midday('midday', 'Midday', '☀️', 13, 0),
  evening('evening', 'Evening', '🌇', 18, 0),
  night('night', 'Night', '🌙', 21, 0);

  const NotificationPeriod(
    this.value,
    this.label,
    this.icon,
    this.targetHour,
    this.targetMinute,
  );

  final String value;
  final String label;
  final String icon;
  final int targetHour;
  final int targetMinute;

  /// Convert period to time string (HH:mm format)
  String toTimeString() {
    return '${targetHour.toString().padLeft(2, '0')}:${targetMinute.toString().padLeft(2, '0')}';
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

      // Map to closest period based on hour
      if (hour < 11) {
        return NotificationPeriod.morning; // Before 11:00 → Morning
      } else if (hour < 16) {
        return NotificationPeriod.midday; // 11:00-15:59 → Midday
      } else if (hour < 20) {
        return NotificationPeriod.evening; // 16:00-19:59 → Evening
      } else {
        return NotificationPeriod.night; // 20:00+ → Night
      }
    } catch (_) {
      return NotificationPeriod.morning; // Default fallback
    }
  }

  /// Get display text for the period
  String get displayName => '$icon $label';
}
