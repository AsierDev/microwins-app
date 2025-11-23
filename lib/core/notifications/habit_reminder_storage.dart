import 'package:hive_flutter/hive_flutter.dart';
import 'habit_reminder_model.dart';

class HabitReminderStorage {
  static const String _boxName = 'habitReminders';
  static Box<HabitReminderModel>? _box;

  /// Initialize the storage
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HabitReminderModelAdapter());
    }
    _box = await Hive.openBox<HabitReminderModel>(_boxName);
  }

  /// Get the box instance
  static Box<HabitReminderModel> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
        'HabitReminderStorage not initialized. Call init() first.',
      );
    }
    return _box!;
  }

  /// Store or update a habit reminder
  static Future<void> saveReminder(HabitReminderModel reminder) async {
    await box.put(reminder.habitId, reminder);
  }

  /// Get a specific reminder by habit ID
  static HabitReminderModel? getReminder(String habitId) {
    return box.get(habitId);
  }

  /// Get all pending reminders
  static List<HabitReminderModel> getAllReminders() {
    return box.values.toList();
  }

  /// Delete a reminder
  static Future<void> deleteReminder(String habitId) async {
    await box.delete(habitId);
  }

  /// Update last notified timestamp
  static Future<void> updateLastNotified(
    String habitId,
    DateTime timestamp,
  ) async {
    final reminder = box.get(habitId);
    if (reminder != null) {
      final updated = reminder.copyWith(lastNotifiedDate: timestamp);
      await box.put(habitId, updated);
    }
  }

  /// Clear all reminders (for testing/debugging)
  static Future<void> clearAll() async {
    await box.clear();
  }
}
