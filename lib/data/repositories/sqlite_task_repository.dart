import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/data/repositories/task_repository.dart';
import 'package:focus/data/database_helper.dart';

class SQLiteTaskRepository implements TaskRepository {
  // Acessa a instância única do banco de dados [cite: 37, 44]
  final _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insertTask(Task task) async {
    final db = await _dbHelper.database;
    // O toMap() converte DateTime e Enums para tipos que o SQLite aceita [cite: 92, 116]
    await db.insert(
      'tasks',
      task.toMap(),
    );
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final db = await _dbHelper.database;
    // Busca todas as tarefas ordenadas por data de vencimento [cite: 104, 116]
    final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'due_date ASC');

    // Transforma a lista de Maps vinda do banco em uma lista de objetos Task [cite: 37, 44]
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  @override
  Future<void> updateTask(Task task) async {
    final db = await _dbHelper.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }
}