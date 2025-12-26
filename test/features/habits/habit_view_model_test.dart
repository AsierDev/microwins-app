import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:microwins/features/habits/domain/entities/habit.dart';
import 'package:microwins/features/habits/domain/habit_repository.dart';
import 'package:microwins/features/habits/data/habit_provider.dart';
import 'package:microwins/features/habits/presentation/habit_view_model.dart';
import 'package:microwins/features/gamification/domain/completion_repository.dart';
import 'package:microwins/features/gamification/data/completion_provider.dart';
import 'package:microwins/features/gamification/data/models/habit_completion_model.dart';
import 'package:microwins/features/habits/data/models/habit_model.dart';
import 'package:microwins/core/local/hive_setup.dart';
import 'package:microwins/core/sync/sync_manager.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([HabitRepository, CompletionRepository, SyncManager])
import 'habit_view_model_test.mocks.dart';

void main() {
  group('HabitViewModel', () {
    late MockHabitRepository mockRepository;
    late MockCompletionRepository mockCompletionRepository;
    late MockSyncManager mockSyncManager;
    late ProviderContainer container;
    late Directory tempDir;

    setUpAll(() async {
      // Initialize Hive for testing with a temporary directory
      tempDir = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(tempDir.path);

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HabitModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HabitCompletionModelAdapter());
      }
    });

    setUp(() async {
      // Open boxes for testing (reopen if already open)
      if (!Hive.isBoxOpen(HiveSetup.syncQueueBoxName)) {
        await Hive.openBox<dynamic>(HiveSetup.syncQueueBoxName);
      }
      if (!Hive.isBoxOpen(HiveSetup.completionsBoxName)) {
        await Hive.openBox<HabitCompletionModel>(HiveSetup.completionsBoxName);
      }
      if (!Hive.isBoxOpen(HiveSetup.habitsBoxName)) {
        await Hive.openBox<HabitModel>(HiveSetup.habitsBoxName);
      }

      mockRepository = MockHabitRepository();
      mockCompletionRepository = MockCompletionRepository();
      mockSyncManager = MockSyncManager();

      container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepository),
          completionRepositoryProvider.overrideWithValue(
            mockCompletionRepository,
          ),
          syncManagerProvider.overrideWithValue(mockSyncManager),
        ],
      );
    });

    tearDown(() async {
      container.dispose();

      // Clear all boxes after each test
      if (Hive.isBoxOpen(HiveSetup.syncQueueBoxName)) {
        await Hive.box<dynamic>(HiveSetup.syncQueueBoxName).clear();
      }
      if (Hive.isBoxOpen(HiveSetup.completionsBoxName)) {
        await Hive.box<HabitCompletionModel>(
          HiveSetup.completionsBoxName,
        ).clear();
      }
      if (Hive.isBoxOpen(HiveSetup.habitsBoxName)) {
        await Hive.box<HabitModel>(HiveSetup.habitsBoxName).clear();
      }
    });

    tearDownAll(() async {
      // Close all boxes and delete from disk
      if (Hive.isBoxOpen(HiveSetup.syncQueueBoxName)) {
        await Hive.box<dynamic>(HiveSetup.syncQueueBoxName).close();
      }
      if (Hive.isBoxOpen(HiveSetup.completionsBoxName)) {
        await Hive.box<HabitCompletionModel>(
          HiveSetup.completionsBoxName,
        ).close();
      }
      if (Hive.isBoxOpen(HiveSetup.habitsBoxName)) {
        await Hive.box<HabitModel>(HiveSetup.habitsBoxName).close();
      }

      await Hive.deleteFromDisk();

      // Clean up temporary directory
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
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

      // Mock completion repository methods
      when(
        mockCompletionRepository.createCompletion(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockCompletionRepository.getCompletionsForHabit('1'),
      ).thenAnswer((_) async => []);

      final notifier = container.read(habitViewModelProvider.notifier);

      await notifier.completeHabit('1');

      verify(mockRepository.getHabits()).called(1);
      verify(mockRepository.updateHabit(any)).called(1);
      verify(mockCompletionRepository.createCompletion(any)).called(1);
      verify(mockCompletionRepository.getCompletionsForHabit('1')).called(1);
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
