import 'package:flutter/material.dart';
import 'package:focus/data/repositories/task_repository.dart';
import 'package:focus/features/tasks/models/task_model.dart';

void testeRepository(TaskRepository repo) {
  repo.getAllTasks();
}

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository;

  List<Task> _tasks = [];
  bool _isLoading = false;

  TaskViewModel(this._repository);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Carrega as tarefas do banco de dados
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks();

      // DEBUG
      debugPrint("--- DEBUG BANCO DE DADOS ---");
      for (var task in _tasks) {
        print("Tarefa Salva: ${task.title} | Status: ${task.status}");
      }
      debugPrint("----------------------------");

    } catch (e) {
      debugPrint("Erro ao buscar tarefas: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adiciona uma nova tarefa
  Future<void> addTask(Task task) async {
    await _repository.insertTask(task);
    await fetchTasks();
  }

  // Deleta uma tarefa
  Future<void> removeTask(String id) async {
    await _repository.deleteTask(id);
    await fetchTasks();
  }

  // Alterna status da tarefa
  Future<void> toggleTaskStatus(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      status: task.status == TaskStatus.done
          ? TaskStatus.pending
          : TaskStatus.done,
      categoryId: task.categoryId,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
    );

    await _repository.updateTask(updatedTask);
    await fetchTasks();
  }
}