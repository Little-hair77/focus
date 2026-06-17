import 'package:focus/features/categories/models/category_model.dart';

/// Contrato de persistência para categorias.
abstract class CategoryRepository {
  /// Insere uma nova categoria.
  Future<void> insertCategory(Category category);

  /// Retorna todas as categorias disponíveis.
  Future<List<Category>> getAllCategories();

  /// Atualiza os dados de uma categoria existente.
  Future<void> updateCategory(Category category);

  /// Remove definitivamente uma categoria.
  Future<void> deleteCategory(String id);
}
