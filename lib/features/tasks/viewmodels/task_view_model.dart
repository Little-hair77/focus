import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  // O ViewModel usa o repositório para buscar dados 
  final TaskRepository _repository;
  
  List<Task> _tasks = [];
  bool _isLoading = false;

  TaskViewModel(this._repository);

  // Getters para a UI consumir os dados 
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Carrega as tarefas do banco de dados 
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners(); // Avisa a UI para mostrar um Spinner 

    try {
      _tasks = await _repository.getAllTasks();
    } catch (e) {
      debugPrint("Erro ao buscar tarefas: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisa a UI para renderizar a lista 
    }
  }

  // Adiciona uma nova tarefa 
  Future<void> addTask(Task task) async {
    await _repository.insertTask(task);
    await fetchTasks(); // Atualiza a lista local após salvar
  }

  // Deleta uma tarefa [
  Future<void> removeTask(String id) async {
    await _repository.deleteTask(id);
    await fetchTasks();
  }

  // Alterna o status da tarefa (Check/Uncheck) 
  Future<void> toggleTaskStatus(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      status: task.status == TaskStatus.done ? TaskStatus.pending : TaskStatus.done,
      categoryId: task.categoryId,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(), // Atualiza a data de modificação 
    );
    
    await _repository.updateTask(updatedTask);
    await fetchTasks();
  }
}