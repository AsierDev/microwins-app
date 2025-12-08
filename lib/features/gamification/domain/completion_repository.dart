import '../data/models/habit_completion_model.dart';

/// Interfaz para el repositorio de completiones de hábitos
abstract class CompletionRepository {
  /// Crea una nueva completación de hábito
  Future<void> createCompletion(HabitCompletionModel completion);

  /// Actualiza una completación existente
  Future<void> updateCompletion(HabitCompletionModel completion);

  /// Elimina una completación
  Future<void> deleteCompletion(String id);

  /// Obtiene todas las completiones
  Future<List<HabitCompletionModel>> getCompletions();

  /// Obtiene las completiones para un hábito específico
  Future<List<HabitCompletionModel>> getCompletionsForHabit(String habitId);

  /// Obtiene las completiones en un rango de fechas
  Future<List<HabitCompletionModel>> getCompletionsForDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Observa cambios en todas las completiones
  Stream<List<HabitCompletionModel>> watchCompletions();

  /// Observa cambios en las completiones de un hábito específico
  Stream<List<HabitCompletionModel>> watchCompletionsForHabit(String habitId);

  /// Sincroniza datos desde la nube
  Future<void> syncFromCloud();

  /// Marca una completación como sincronizada
  Future<void> markAsSynced(String id);

  /// Obtiene completiones no sincronizadas
  Future<List<HabitCompletionModel>> getUnsyncedCompletions();

  /// Elimina todas las completiones de un hábito
  Future<void> deleteCompletionsForHabit(String habitId);
}
