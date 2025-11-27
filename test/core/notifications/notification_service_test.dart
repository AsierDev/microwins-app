import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/annotations.dart';
import 'package:microwins/core/notifications/notification_service.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  group('NotificationService', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    test('should be a singleton instance', () {
      final instance1 = NotificationService();
      final instance2 = NotificationService();
      expect(instance1, equals(instance2));
    });

    test('should initialize correctly', () {
      expect(notificationService, isNotNull);
    });

    test('cancelAllNotifications should complete without errors', () async {
      expect(() async {
        await notificationService.cancelAllNotifications();
      }, returnsNormally);
    });
  });
}
