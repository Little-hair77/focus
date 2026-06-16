import 'package:flutter/material.dart';
import 'package:focus/core/constants/trash_policy.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/categories/models/category_model.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:focus/features/categories/views/category_form_screen.dart';
import 'package:focus/features/categories/views/category_detail_screen.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_drawer.dart';
import 'package:focus/shared/widgets/bottom_navigation_bar.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:focus/shared/models/trash_drag_data.dart';
import 'package:focus/shared/widgets/app_card.dart';
import 'package:provider/provider.dart';

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
                    ? const _EmptyState()
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
                              return _CategoryCard(category: category);
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

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final card = AppCard(
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(category: category),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: category.displayColor.withValues(alpha: 0.16),
          child: Icon(Icons.category_rounded, color: category.displayColor),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryFormScreen(category: category),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      hint:
          'Toque duas vezes para abrir detalhes. Pressione e segure para mover para a lixeira.',
      child: LongPressDraggable<TrashDragData>(
        data: TrashDragData(id: category.id, type: TrashItemType.category),
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(width: 360, child: card),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: card),
        child: card,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir categoria?'),
        content: Text(
          'A categoria "${category.name}" ficará na lixeira por '
          '${TrashPolicy.retentionDays} dias.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mover para lixeira'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    final categoryVM = context.read<CategoryViewModel>();
    final success = await categoryVM.removeCategory(category.id);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(categoryVM.errorMessage ?? 'Erro ao excluir.')),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Icon(
              Icons.category_outlined,
              size: 80,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Nenhuma categoria cadastrada.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
