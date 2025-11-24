import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../firebase_options.dart';
import '../utils/logger.dart';

/// Midnight worker that resets lastNotifiedDate for all habits
/// This allows notifications to fire again the next day (Todoist pattern)
/// Runs daily at 00:01
@pragma('vm:entry-point')
void midnightRescheduleWorker() {
  Workmanager().executeTask((task, inputData) async {
    try {
      AppLogger.debug(
        'Midnight Worker: Resetting notification state for all habits...',
        tag: 'MidnightWorker',
      );

      // Initialize Firebase in WorkManager process
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Get current user ID from SharedPreferences (multi-process safe)
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');

      if (userId == null) {
        AppLogger.warning(
          'No user logged in, skipping midnight reschedule',
          tag: 'MidnightWorker',
        );
        return Future.value(true);
      }

      // Get all habits with notifications
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('habits')
          .where('isArchived', isEqualTo: false)
          .get();

      AppLogger.debug(
        'Found ${snapshot.docs.length} habits to reset',
        tag: 'MidnightWorker',
      );

      int resetCount = 0;
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final reminderTime = data['reminderTime'] as String? ?? '';

        // Only reset habits that have notifications enabled
        if (reminderTime.isNotEmpty) {
          batch.update(doc.reference, {'lastNotifiedDate': null});
          resetCount++;
        }
      }

      // Commit all updates in a single batch
      if (resetCount > 0) {
        await batch.commit();
      }

      AppLogger.info(
        'Midnight reschedule complete: reset $resetCount habits',
        tag: 'MidnightWorker',
      );

      return Future.value(true);
    } catch (e) {
      AppLogger.error('Midnight worker error', tag: 'MidnightWorker', error: e);
      return Future.value(false);
    }
  });
}
