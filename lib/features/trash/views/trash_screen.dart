import 'package:flutter/material.dart';
import 'package:focus/core/constants/trash_policy.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/categories/models/category_model.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_drawer.dart';
import 'package:focus/shared/widgets/bottom_navigation_bar.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:focus/shared/widgets/app_card.dart';
import 'package:provider/provider.dart';

/// Tela da lixeira com tarefas e categorias removidas.
class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskVM = context.watch<TaskViewModel>();
    final categoryVM = context.watch<CategoryViewModel>();
    final isLoading = taskVM.isLoading || categoryVM.isLoading;
    final isEmpty =
        taskVM.trashedTasks.isEmpty && categoryVM.trashedCategories.isEmpty;

    return AppGestureNavigation(
      tabIndex: 3,
      child: Scaffold(
        appBar: const AppBarWidget(),
        drawer: const AppDrawer(),
        bottomNavigationBar: AppBottomNavigationBar(currentIndex: 3),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Lixeira',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Os itens são excluídos definitivamente após '
                '${TrashPolicy.retentionDays} dias.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? Semantics(
                        label: 'Carregando lixeira',
                        liveRegion: true,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : isEmpty
                    ? const _EmptyState()
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          if (taskVM.trashedTasks.isNotEmpty) ...[
                            const _SectionTitle('Tarefas'),
                            ...taskVM.trashedTasks.map(
                              (task) => _TrashTaskCard(task: task),
                            ),
                          ],
                          if (categoryVM.trashedCategories.isNotEmpty) ...[
                            const _SectionTitle('Categorias'),
                            ...categoryVM.trashedCategories.map(
                              (category) =>
                                  _TrashCategoryCard(category: category),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Título de seção dentro da lixeira.
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Card de uma tarefa enviada para a lixeira.
class _TrashTaskCard extends StatelessWidget {
  final Task task;

  const _TrashTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return _TrashCard(
      icon: Icons.checklist_rounded,
      title: task.title,
      daysRemaining: _daysRemaining(task.deletedAt!),
      onRestore: () => context.read<TaskViewModel>().restoreTask(task.id),
    );
  }
}

/// Card de uma categoria enviada para a lixeira.
class _TrashCategoryCard extends StatelessWidget {
  final Category category;

  const _TrashCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return _TrashCard(
      icon: Icons.category_rounded,
      title: category.name,
      daysRemaining: _daysRemaining(category.deletedAt!),
      onRestore: () async {
        await context.read<CategoryViewModel>().restoreCategory(category.id);
      },
    );
  }
}

/// Card base compartilhado entre itens da lixeira.
class _TrashCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int daysRemaining;
  final Future<void> Function() onRestore;

  const _TrashCard({
    required this.icon,
    required this.title,
    required this.daysRemaining,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ExcludeSemantics(
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$daysRemaining dias restantes'),
        trailing: TextButton.icon(
          onPressed: () => onRestore(),
          icon: const Icon(Icons.restore),
          label: Text('Restaurar $title'),
        ),
      ),
    );
  }
}

/// Calcula dias restantes para exclusão definitiva.
int _daysRemaining(DateTime deletedAt) {
  return TrashPolicy.daysRemaining(deletedAt, DateTime.now());
}

/// Estado vazio da lixeira.
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
              Icons.delete_outline,
              size: 80,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'A lixeira está vazia.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
