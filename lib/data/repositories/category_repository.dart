import 'package:focus/features/categories/models/category_model.dart';

abstract class CategoryRepository {
  Future<void> insertCategory(Category category);

  Future<List<Category>> getAllCategories();

  Future<void> updateCategory(Category category);

  Future<void> deleteCategory(String id);
}
