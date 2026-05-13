import '../models/task_model.dart';

/// Esta é uma classe abstrata que define o "contrato" para o gerenciamento de tarefas.
/// Ela permite que o resto do app não dependa de um banco de dados específico.
abstract class TaskRepository {
  
  // Busca todas as tarefas salvas
  Future<List<Task>> getAllTasks();
  
  // Busca uma tarefa específica pelo ID
  Future<Task?> getTaskById(String id);
  
  // Insere uma nova tarefa
  Future<void> insertTask(Task task);
  
  // Atualiza uma tarefa existente
  Future<void> updateTask(Task task);
  
  // Remove uma tarefa do banco
  Future<void> deleteTask(String id);
}