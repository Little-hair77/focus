import 'package:focus/features/tasks/models/task_model.dart';

/// Contrato de persistência para tarefas.
abstract class TaskRepository {
  /// Insere uma nova tarefa.
  Future<void> insertTask(Task task);

  /// Retorna todas as tarefas disponíveis.
  Future<List<Task>> getAllTasks();

  /// Atualiza os dados de uma tarefa existente.
  Future<void> updateTask(Task task);

  /// Remove definitivamente uma tarefa.
  Future<void> deleteTask(String id);

  /// Busca uma tarefa pelo identificador.
  Future<Task?> getTaskById(String id);
}
