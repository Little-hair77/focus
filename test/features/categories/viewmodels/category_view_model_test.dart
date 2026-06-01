import 'package:flutter_test/flutter_test.dart';
import 'package:focus/data/repositories/category_repository.dart';
import 'package:focus/features/categories/models/category_model.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late CategoryViewModel viewModel;
  late MockCategoryRepository mockRepository;

  final category = Category(
    id: '1',
    name: 'Estudos',
    color: '#6366F1',
    createdAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(category);
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
    viewModel = CategoryViewModel(mockRepository);
  });

  group('CategoryViewModel', () {
    test('carrega categorias do repositório', () async {
      when(
        () => mockRepository.getAllCategories(),
      ).thenAnswer((_) async => [category]);

      await viewModel.fetchCategories();

      expect(viewModel.categories, [category]);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('adiciona uma categoria e atualiza a lista', () async {
      when(
        () => mockRepository.insertCategory(category),
      ).thenAnswer((_) async {});
      when(
        () => mockRepository.getAllCategories(),
      ).thenAnswer((_) async => [category]);

      final success = await viewModel.addCategory(category);

      expect(success, isTrue);
      expect(viewModel.categories, [category]);
      verify(() => mockRepository.insertCategory(category)).called(1);
    });

    test('expõe mensagem quando o repositório falha', () async {
      when(
        () => mockRepository.getAllCategories(),
      ).thenThrow(Exception('Erro de conexão'));

      await viewModel.fetchCategories();

      expect(viewModel.categories, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('move categoria para a lixeira e permite restaurar', () async {
      var fetchCount = 0;
      when(() => mockRepository.getAllCategories()).thenAnswer((_) async {
        fetchCount++;
        if (fetchCount == 1) return [category];
        if (fetchCount == 2) {
          return [category.copyWith(deletedAt: DateTime.now())];
        }
        return [category];
      });
      when(() => mockRepository.updateCategory(any())).thenAnswer((_) async {});

      await viewModel.fetchCategories();
      expect(await viewModel.removeCategory(category.id), isTrue);
      expect(viewModel.categories, isEmpty);
      expect(viewModel.trashedCategories, hasLength(1));

      expect(await viewModel.restoreCategory(category.id), isTrue);
      expect(viewModel.categories, hasLength(1));
      expect(viewModel.trashedCategories, isEmpty);
    });

    test('exclui definitivamente categorias na lixeira há 15 dias', () async {
      final expiredCategory = category.copyWith(
        id: 'expired',
        deletedAt: DateTime.now().subtract(const Duration(days: 15)),
      );
      when(
        () => mockRepository.getAllCategories(),
      ).thenAnswer((_) async => [category, expiredCategory]);
      when(
        () => mockRepository.deleteCategory(expiredCategory.id),
      ).thenAnswer((_) async {});

      await viewModel.fetchCategories();

      expect(viewModel.categories, [category]);
      expect(viewModel.trashedCategories, isEmpty);
      verify(() => mockRepository.deleteCategory(expiredCategory.id)).called(1);
    });
  });
}
