import 'package:focus/data/database_helper.dart';
import 'package:focus/data/repositories/category_repository.dart';
import 'package:focus/features/categories/models/category_model.dart';

/// Repositório local de categorias usando SQLite.
class SQLiteCategoryRepository implements CategoryRepository {
  /// Instância única do helper do banco local.
  final _dbHelper = DatabaseHelper.instance;

  /// Insere uma categoria no banco local.
  @override
  Future<void> insertCategory(Category category) async {
    final db = await _dbHelper.database;
    await db.insert('categories', category.toMap());
  }

  /// Busca todas as categorias locais ordenadas por nome.
  @override
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map(Category.fromMap).toList();
  }

  /// Atualiza uma categoria no banco local.
  @override
  Future<void> updateCategory(Category category) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Remove definitivamente uma categoria do banco local.
  @override
  Future<void> deleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
