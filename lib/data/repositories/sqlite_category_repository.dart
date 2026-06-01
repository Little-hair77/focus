import 'package:focus/data/database_helper.dart';
import 'package:focus/data/repositories/category_repository.dart';
import 'package:focus/features/categories/models/category_model.dart';

class SQLiteCategoryRepository implements CategoryRepository {
  final _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insertCategory(Category category) async {
    final db = await _dbHelper.database;
    await db.insert('categories', category.toMap());
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map(Category.fromMap).toList();
  }

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

  @override
  Future<void> deleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
