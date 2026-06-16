import 'package:flutter/material.dart';
import 'package:focus/core/constants/trash_policy.dart';
import 'package:focus/data/repositories/task_repository.dart';
import 'package:focus/features/tasks/models/task_model.dart';

/// Exercita o repositório de tarefas em chamadas pontuais de diagnóstico.
void testeRepository(TaskRepository repo) {
  repo.getAllTasks();
}

/// Controla o estado e as operações de tarefas.
class TaskViewModel extends ChangeNotifier {
  /// Repositório usado para persistência de tarefas.
  final TaskRepository _repository;

  List<Task> _tasks = [];
  List<Task> _trashedTasks = [];
  bool _isLoading = false;
  String? _activeUserId;
  int _sessionVersion = 0;

  TaskViewModel(this._repository);

  /// Tarefas ativas exibidas no app.
  List<Task> get tasks => _tasks;

  /// Tarefas enviadas para a lixeira.
  List<Task> get trashedTasks => _trashedTasks;

  /// Indica se há carregamento em andamento.
  bool get isLoading => _isLoading;

  /// Sincroniza o viewmodel com o usuário autenticado.
  void syncUser(String? userId) {
    if (_activeUserId == userId) return;

    _activeUserId = userId;
    _sessionVersion++;
    _tasks = [];
    _trashedTasks = [];

    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    Future.microtask(fetchTasks);
  }

  /// Busca tarefas, limpa itens expirados e separa ativos/lixeira.
  Future<void> fetchTasks() async {
    final sessionVersion = _sessionVersion;

    _isLoading = true;
    notifyListeners();

    try {
      final tasks = await _repository.getAllTasks();
      if (_sessionVersion != sessionVersion) return;
      final now = DateTime.now();
      final expiredTasks = tasks.where((task) => _isExpired(task, now));
      for (final task in expiredTasks) {
        if (_sessionVersion != sessionVersion) return;
        await _repository.deleteTask(task.id);
      }
      if (_sessionVersion != sessionVersion) return;

      final retainedTasks = tasks.where((task) => !_isExpired(task, now));
      _tasks = retainedTasks.where((task) => task.deletedAt == null).toList();
      _trashedTasks = retainedTasks
          .where((task) => task.deletedAt != null)
          .toList();
    } catch (e) {
      debugPrint("Erro ao buscar tarefas: $e");
    } finally {
      if (_sessionVersion == sessionVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Adiciona uma nova tarefa.
  Future<void> addTask(Task task) async {
    await _repository.insertTask(task);
    await fetchTasks();
  }

  /// Atualiza uma tarefa existente.
  Future<void> editTask(Task task) async {
    await _repository.updateTask(task.copyWith(updatedAt: DateTime.now()));
    await fetchTasks();
  }

  /// Move uma tarefa para a lixeira.
  Future<void> removeTask(String id) async {
    final task = _tasks.where((task) => task.id == id).firstOrNull;
    if (task == null) return;

    await _repository.updateTask(
      task.copyWith(deletedAt: DateTime.now(), updatedAt: DateTime.now()),
    );
    await fetchTasks();
  }

  /// Restaura uma tarefa da lixeira.
  Future<void> restoreTask(String id) async {
    final task = _trashedTasks.where((task) => task.id == id).firstOrNull;
    if (task == null) return;

    await _repository.updateTask(
      task.copyWith(restore: true, updatedAt: DateTime.now()),
    );
    await fetchTasks();
  }

  /// Alterna o status entre pendente e concluída.
  Future<void> toggleTaskStatus(Task task) async {
    final updatedTask = task.copyWith(
      status: task.status == TaskStatus.done
          ? TaskStatus.pending
          : TaskStatus.done,
      updatedAt: DateTime.now(),
    );

    await _repository.updateTask(updatedTask);
    await fetchTasks();
  }

  /// Verifica se uma tarefa na lixeira já venceu.
  bool _isExpired(Task task, DateTime now) {
    final deletedAt = task.deletedAt;
    return deletedAt != null && TrashPolicy.isExpired(deletedAt, now);
  }
}
