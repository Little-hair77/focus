import 'package:flutter/material.dart';
import 'package:focus/core/constants/trash_policy.dart';
import 'package:focus/data/repositories/category_repository.dart';
import 'package:focus/features/categories/models/category_model.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repository;

  List<Category> _categories = [];
  List<Category> _trashedCategories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _activeUserId;
  int _sessionVersion = 0;

  CategoryViewModel(this._repository);

  List<Category> get categories => _categories;
  List<Category> get trashedCategories => _trashedCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void syncUser(String? userId) {
    if (_activeUserId == userId) return;

    _activeUserId = userId;
    _sessionVersion++;
    _categories = [];
    _trashedCategories = [];

    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    Future.microtask(fetchCategories);
  }

  Future<void> fetchCategories() async {
    final sessionVersion = _sessionVersion;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final categories = await _repository.getAllCategories();
      if (_sessionVersion != sessionVersion) return;
      final now = DateTime.now();
      final expiredCategories = categories.where(
        (category) => _isExpired(category, now),
      );
      for (final category in expiredCategories) {
        if (_sessionVersion != sessionVersion) return;
        await _repository.deleteCategory(category.id);
      }
      if (_sessionVersion != sessionVersion) return;

      final retainedCategories = categories.where(
        (category) => !_isExpired(category, now),
      );
      _categories = retainedCategories
          .where((category) => category.deletedAt == null)
          .toList();
      _trashedCategories = retainedCategories
          .where((category) => category.deletedAt != null)
          .toList();
    } catch (e) {
      _errorMessage = 'Não foi possível carregar as categorias.';
      debugPrint('Erro ao buscar categorias: $e');
    } finally {
      if (_sessionVersion == sessionVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> addCategory(Category category) async {
    return _runAndRefresh(() => _repository.insertCategory(category));
  }

  Future<bool> editCategory(Category category) async {
    return _runAndRefresh(() => _repository.updateCategory(category));
  }

  Future<bool> removeCategory(String id) async {
    final category = _categories
        .where((category) => category.id == id)
        .firstOrNull;
    if (category == null) return false;

    return _runAndRefresh(
      () => _repository.updateCategory(
        category.copyWith(deletedAt: DateTime.now()),
      ),
    );
  }

  Future<bool> restoreCategory(String id) async {
    final category = _trashedCategories
        .where((category) => category.id == id)
        .firstOrNull;
    if (category == null) return false;

    return _runAndRefresh(
      () => _repository.updateCategory(category.copyWith(restore: true)),
    );
  }

  Future<bool> _runAndRefresh(Future<void> Function() action) async {
    _errorMessage = null;

    try {
      await action();
      await fetchCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Não foi possível salvar a alteração.';
      debugPrint('Erro ao alterar categoria: $e');
      notifyListeners();
      return false;
    }
  }

  bool _isExpired(Category category, DateTime now) {
    final deletedAt = category.deletedAt;
    return deletedAt != null && TrashPolicy.isExpired(deletedAt, now);
  }
}
