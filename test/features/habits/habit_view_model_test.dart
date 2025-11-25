import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:microwins/features/habits/domain/entities/habit.dart';
import 'package:microwins/features/habits/domain/habit_repository.dart';
import 'package:microwins/features/habits/data/habit_provider.dart';
import 'package:microwins/features/habits/presentation/habit_view_model.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([HabitRepository])
import 'habit_view_model_test.mocks.dart';

void main() {
  group('HabitViewModel', () {
    late MockHabitRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockHabitRepository();
      container = ProviderContainer(
        overrides: [habitRepositoryProvider.overrideWithValue(mockRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('addHabit should create habit with correct sortOrder', () async {
      final existingHabits = [
        Habit(
          id: '1',
          name: 'Meditate',
          icon: '🧘',
          category: 'Wellness',
          durationMinutes: 10,
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: '2',
          name: 'Exercise',
          icon: '🏃',
          category: 'Fitness',
          durationMinutes: 30,
          sortOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getHabits()).thenAnswer((_) async => existingHabits);
      when(
        mockRepository.createHabit(any),
      ).thenAnswer((_) async => Future.value());

      final notifier = container.read(habitViewModelProvider.notifier);

      await notifier.addHabit(
        name: 'Read',
        icon: '📚',
        category: 'Learning',
        durationMinutes: 20,
      );

      verify(mockRepository.getHabits()).called(1);
      verify(mockRepository.createHabit(any)).called(1);
    });

    test('reorderHabits should update sortOrder correctly', () async {
      final habits = [
        Habit(
          id: '1',
          name: 'Habit 1',
          icon: '🎯',
          category: 'Wellness',
          durationMinutes: 10,
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: '2',
          name: 'Habit 2',
          icon: '🎯',
          category: 'Wellness',
          durationMinutes: 10,
          sortOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: '3',
          name: 'Habit 3',
          icon: '🎯',
          category: 'Wellness',
          durationMinutes: 10,
          sortOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getHabits()).thenAnswer((_) async => habits);
      when(
        mockRepository.updateHabitsOrder(any),
      ).thenAnswer((_) async => Future.value());

      final notifier = container.read(habitViewModelProvider.notifier);

      // Move item from index 0 to index 2
      await notifier.reorderHabits(0, 2);

      verify(mockRepository.getHabits()).called(1);
      verify(mockRepository.updateHabitsOrder(any)).called(1);
    });

    test('completeHabit should update streak correctly', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final habit = Habit(
        id: '1',
        name: 'Meditate',
        icon: '🧘',
        category: 'Wellness',
        durationMinutes: 10,
        currentStreak: 5,
        bestStreak: 10,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
        lastCompletedDate: yesterday,
      );

      when(mockRepository.getHabits()).thenAnswer((_) async => [habit]);
      when(
        mockRepository.updateHabit(any),
      ).thenAnswer((_) async => Future.value());

      final notifier = container.read(habitViewModelProvider.notifier);

      await notifier.completeHabit('1');

      verify(mockRepository.getHabits()).called(1);
      verify(mockRepository.updateHabit(any)).called(1);
    });

    test('deleteHabit should remove habit and cancel notification', () async {
      when(
        mockRepository.deleteHabit('1'),
      ).thenAnswer((_) async => Future.value());

      final notifier = container.read(habitViewModelProvider.notifier);

      await notifier.deleteHabit('1');

      verify(mockRepository.deleteHabit('1')).called(1);
    });
  });
}
