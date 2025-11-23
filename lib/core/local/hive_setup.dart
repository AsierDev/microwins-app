import 'package:hive_flutter/hive_flutter.dart';

import '../../features/habits/data/models/habit_model.dart';
import '../notifications/habit_reminder_model.dart';

class HiveSetup {
  static const String habitsBoxName = 'habits';
  static const String syncQueueBoxName = 'syncQueue';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(HabitReminderModelAdapter());

    // Open Boxes
    await Hive.openBox<HabitModel>(habitsBoxName);
    await Hive.openBox(syncQueueBoxName);
    await Hive.openBox(settingsBoxName);
  }
}
