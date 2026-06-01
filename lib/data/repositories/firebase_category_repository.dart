import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus/data/repositories/category_repository.dart';
import 'package:focus/features/categories/models/category_model.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  @override
  Future<void> insertCategory(Category category) async {
    await _categoriesCollection.doc(category.id).set(category.toMap());
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final snapshot = await _categoriesCollection.orderBy('name').get();

    return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _categoriesCollection.doc(category.id).update(category.toMap());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _categoriesCollection.doc(id).delete();
  }
}
