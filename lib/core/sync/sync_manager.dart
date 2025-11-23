import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../local/hive_setup.dart';

class SyncManager {
  final Box _syncQueueBox = Hive.box(HiveSetup.syncQueueBoxName);
  final Connectivity _connectivity = Connectivity();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SyncManager() {
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet)) {
        _processQueue();
      }
    });
  }

  Future<void> queueOperation(String action, Map<String, dynamic> data) async {
    await _syncQueueBox.add({
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    // Don't await - process queue in background to avoid blocking
    _processQueue().catchError((e) {
      print('Background sync error: $e');
    });
  }

  Future<void> _processQueue() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // User not logged in, skip sync but don't block
        print('Sync skipped: No user logged in');
        return;
      }

      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline =
          connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);

      if (!isOnline) {
        print('Sync skipped: No internet connection');
        return;
      }

      final keysToDelete = <dynamic>[];

      for (var i = 0; i < _syncQueueBox.length; i++) {
        final item = _syncQueueBox.getAt(i) as Map;
        try {
          await _performRemoteOperation(user.uid, item);
          keysToDelete.add(_syncQueueBox.keyAt(i));
        } catch (e) {
          print('Sync error for item $i: $e');
          // Don't stop processing, continue with next items
          // Items that fail will be retried on next sync
        }
      }

      // Remove processed items
      if (keysToDelete.isNotEmpty) {
        await _syncQueueBox.deleteAll(keysToDelete);
        print('Synced ${keysToDelete.length} items to Firestore');
      }
    } catch (e) {
      // Catch any unexpected errors to prevent blocking local operations
      print('Sync queue processing error: $e');
    }
  }

  Future<void> _performRemoteOperation(String userId, Map item) async {
    final action = item['action'] as String;
    final data = item['data'] as Map<String, dynamic>;
    final habitsCollection = _firestore
        .collection('users')
        .doc(userId)
        .collection('habits');

    switch (action) {
      case 'createHabit':
        await habitsCollection.doc(data['id'] as String).set(data);
        break;
      case 'updateHabit':
        await habitsCollection.doc(data['id'] as String).update(data);
        break;
      case 'deleteHabit':
        await habitsCollection.doc(data['id'] as String).delete();
        break;
      default:
        print('Unknown sync action: $action');
    }
  }

  /// Fetch all habits from Firestore for the current user
  Future<List<Map<String, dynamic>>> fetchHabitsFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching habits from Firestore: $e');
      return [];
    }
  }

  /// Listen to Firestore changes for real-time sync
  Stream<List<Map<String, dynamic>>> watchHabitsFromFirestore() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
