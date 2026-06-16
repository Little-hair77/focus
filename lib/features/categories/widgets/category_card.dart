import 'package:flutter/material.dart';
import 'package:focus/core/constants/trash_policy.dart';
import 'package:focus/features/categories/models/category_model.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:focus/features/categories/views/category_detail_screen.dart';
import 'package:focus/features/categories/views/category_form_screen.dart';
import 'package:focus/shared/models/trash_drag_data.dart';
import 'package:focus/shared/widgets/app_card.dart';
import 'package:provider/provider.dart';

/// Card visual de uma categoria com ações rápidas e drag para lixeira.
class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

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

  /// Confirma antes de mover a categoria para a lixeira.
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
