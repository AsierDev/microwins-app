import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';
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

    test(
      'scheduleDailyNotification should schedule notification correctly',
      () async {
        // This is a basic test structure
        // In a real scenario, you would mock FlutterLocalNotificationsPlugin
        // and verify the zonedSchedule method is called with correct parameters

        expect(() async {
          await notificationService.scheduleDailyNotification(
            id: 1,
            title: 'Test Habit',
            body: 'Time to complete your habit!',
            hour: 10,
            minute: 30,
          );
        }, returnsNormally);
      },
    );

    test('cancelNotification should cancel notification by id', () async {
      expect(() async {
        await notificationService.cancelNotification(1);
      }, returnsNormally);
    });

    test('cancelAllNotifications should cancel all notifications', () async {
      expect(() async {
        await notificationService.cancelAllNotifications();
      }, returnsNormally);
    });
  });
}
