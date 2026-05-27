import 'package:focus/features/tasks/models/task_model.dart';

abstract class TaskRepository {
  Future<void> insertTask(Task task);

  Future<List<Task>> getAllTasks();

  Future<void> updateTask(Task task);

  Future<void> deleteTask(String id);

  Future<Task?> getTaskById(String id);
}