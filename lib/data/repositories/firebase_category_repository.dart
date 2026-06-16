import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus/data/repositories/category_repository.dart';
import 'package:focus/features/categories/models/category_model.dart';

/// Repositório de categorias persistido no Firestore.
class FirebaseCategoryRepository implements CategoryRepository {
  /// Instância do Firestore usada nas operações remotas.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Coleção de categorias do usuário autenticado.
  CollectionReference<Map<String, dynamic>> get _categoriesCollection {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('categories');
  }

  /// Insere uma categoria na coleção do usuário ativo.
  @override
  Future<void> insertCategory(Category category) async {
    await _categoriesCollection.doc(category.id).set(category.toMap());
  }

  /// Busca todas as categorias da coleção do usuário ativo.
  @override
  Future<List<Category>> getAllCategories() async {
    final snapshot = await _categoriesCollection.orderBy('name').get();

    return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  /// Atualiza uma categoria existente no Firestore.
  @override
  Future<void> updateCategory(Category category) async {
    await _categoriesCollection.doc(category.id).update(category.toMap());
  }

  /// Remove definitivamente uma categoria no Firestore.
  @override
  Future<void> deleteCategory(String id) async {
    await _categoriesCollection.doc(id).delete();
  }
}
