import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:focus/features/categories/views/category_form_screen.dart';
import 'package:focus/features/categories/widgets/category_card.dart';
import 'package:focus/features/categories/widgets/category_empty_state.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_drawer.dart';
import 'package:focus/shared/widgets/bottom_navigation_bar.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:focus/shared/models/trash_drag_data.dart';
import 'package:provider/provider.dart';

/// Tela de listagem e criação de categorias.
class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryVM = context.watch<CategoryViewModel>();
    final theme = Theme.of(context);

    return AppGestureNavigation(
      tabIndex: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: const AppDrawer(),
        appBar: const AppBarWidget(),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: 2,
          onTrashDrop: (data) => _moveToTrash(context, data, categoryVM),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Categorias',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: categoryVM.isLoading
                    ? Semantics(
                        label: 'Carregando categorias',
                        liveRegion: true,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : categoryVM.categories.isEmpty
                    ? const CategoryEmptyState()
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: categoryVM.categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final category = categoryVM.categories[index];
                              return CategoryCard(category: category);
                            },
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          tooltip: 'Adicionar nova categoria',
          backgroundColor: theme.colorScheme.primary,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryFormScreen()),
          ),
          icon: const Icon(Icons.add, color: AppColors.onPrimary),
          label: const Text(
            'Nova Categoria',
            style: TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Move uma categoria arrastada para a lixeira.
  Future<void> _moveToTrash(
    BuildContext context,
    TrashDragData data,
    CategoryViewModel categoryVM,
  ) async {
    if (data.type != TrashItemType.category) return;
    final success = await categoryVM.removeCategory(data.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Categoria movida para a lixeira.'
              : categoryVM.errorMessage ?? 'Erro ao mover categoria.',
        ),
      ),
    );
  }
}
