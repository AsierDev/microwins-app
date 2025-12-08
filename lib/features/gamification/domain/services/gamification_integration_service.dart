import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/completion_provider.dart';
import '../../data/models/habit_completion_model.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'gamification_service.dart';
import 'achievement_service.dart' as achievement;

/// Servicio de integración que conecta el sistema de gamificación
/// con el resto de la aplicación de forma coherente
class GamificationIntegrationService {
  static final GamificationIntegrationService _instance =
      GamificationIntegrationService._internal();
  factory GamificationIntegrationService() => _instance;
  GamificationIntegrationService._internal();

  /// Procesa la completación de un hábito y actualiza el sistema de gamificación
  static Future<void> processHabitCompletion({
    required String habitId,
    required String habitName,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    try {
      // Registrar la completación
      final completion = GamificationService.recordCompletion(
        habitId: habitId,
        completedAt: DateTime.now(),
      );

      // Guardar en el repositorio
      final repository = ref.read(completionRepositoryProvider);
      await repository.createCompletion(completion);

      // Calcular experiencia ganada
      final streak = GamificationService.calculateCurrentStreak([completion]);
      final isFirstToday =
          GamificationService.getCompletedTodayCount([completion]) == 1;
      const isPerfectWeek =
          false; // TODO: Implementar lógica de semana perfecta

      // Se calcula la experiencia ganada pero no se utiliza directamente en este momento
      // Podría ser utilizada en el futuro para mostrar notificaciones de XP
      achievement.AchievementService.calculateExpGained(
        streak: streak,
        isFirstCompletionToday: isFirstToday,
        isPerfectWeek: isPerfectWeek,
      );

      // Verificar nuevos logros desbloqueados
      final allCompletions = await repository.getCompletions();
      final weeklyCompletions = GamificationService.getWeeklyCompletions(
        allCompletions,
      );
      final monthlyCompletions = _getMonthlyCompletions(allCompletions);

      final currentStreak = GamificationService.calculateCurrentStreak(
        allCompletions,
      );
      final bestStreak = GamificationService.calculateBestStreak(
        allCompletions,
      );
      final totalCompletions = allCompletions.length;
      const totalHabits = 1; // TODO: Obtener del repositorio de hábitos

      final newBadges = achievement.AchievementService.checkUnlockedBadges(
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        totalCompletions: totalCompletions,
        weeklyCompletions: weeklyCompletions.values.fold(0, (a, b) => a + b),
        monthlyCompletions: monthlyCompletions,
        totalHabits: totalHabits,
        hasPerfectWeek: isPerfectWeek,
      );

      // Mostrar notificaciones para logros importantes
      if (newBadges.isNotEmpty) {
        final notificationService = NotificationService();

        for (final badge in newBadges) {
          if (badge.rarity.index >= achievement.BadgeRarity.rare.index) {
            await notificationService.showImmediateNotification(
              id: DateTime.now().millisecondsSinceEpoch % 100000,
              title: AppLocalizations.of(
                context,
              )!.gamificationNewAchievementUnlocked,
              body: '${badge.name} - ${badge.description}',
            );
          }
        }
      }

      // Invalidar providers para actualizar la UI
      ref.invalidate(completionsStreamProvider);
    } catch (e) {
      // Manejo de errores silencioso para no interrumpir la experiencia del usuario
      print('Error en procesamiento de gamificación: $e');
    }
  }

  /// Obtiene las completiones del mes actual
  static int _getMonthlyCompletions(List<HabitCompletionModel> completions) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    return completions.where((completion) {
      return !completion.completedAt.isBefore(currentMonth) &&
          completion.completedAt.isBefore(nextMonth);
    }).length;
  }

  /// Verifica si hay logros nuevos para mostrar
  static Future<List<achievement.Badge>> checkForNewBadges(
    WidgetRef ref,
  ) async {
    try {
      final repository = ref.read(completionRepositoryProvider);
      final allCompletions = await repository.getCompletions();

      final currentStreak = GamificationService.calculateCurrentStreak(
        allCompletions,
      );
      final bestStreak = GamificationService.calculateBestStreak(
        allCompletions,
      );
      final totalCompletions = allCompletions.length;
      final weeklyCompletions = GamificationService.getWeeklyCompletions(
        allCompletions,
      );
      final monthlyCompletions = _getMonthlyCompletions(allCompletions);
      const totalHabits = 1; // TODO: Obtener del repositorio

      return achievement.AchievementService.checkUnlockedBadges(
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        totalCompletions: totalCompletions,
        weeklyCompletions: weeklyCompletions.values.fold(0, (a, b) => a + b),
        monthlyCompletions: monthlyCompletions,
        totalHabits: totalHabits,
        hasPerfectWeek: false, // TODO: Implementar lógica
      );
    } catch (e) {
      print('Error verificando nuevos logros: $e');
      return [];
    }
  }

  /// Sincroniza el estado de gamificación entre sesiones
  static Future<void> syncGamificationState(WidgetRef ref) async {
    try {
      // Invalidar todos los providers relacionados para forzar recarga
      ref.invalidate(completionsStreamProvider);

      // Pequeña espera para asegurar que los datos se actualicen
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      print('Error en sincronización de gamificación: $e');
    }
  }
}
