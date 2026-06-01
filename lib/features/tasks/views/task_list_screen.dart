import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_drawer.dart';
import 'package:focus/shared/widgets/bottom_navigation_bar.dart';
import 'package:focus/shared/models/trash_drag_data.dart';
import 'package:focus/shared/widgets/app_card.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_view_model.dart';
import './task_detail_screen.dart';
import './task_form_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskVM = context.watch<TaskViewModel>();
    final theme = Theme.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      drawer: const AppDrawer(),

      appBar: const AppBarWidget(),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 1,
        onTrashDrop: (data) => _moveToTrash(context, data, taskVM),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Minhas Tarefas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: taskVM.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : taskVM.tasks.isEmpty
                  ? _buildEmptyState()
                  : Center(
                      // Evita que a grid passe de 1200px em telas Ultra-wide
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        // SELETOR DE LAYOUT RESPONSIVO: Grid para telas largas, Lista para celulares
                        child: isWideScreen
                            ? GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: screenWidth > 900
                                          ? 3
                                          : 2, // 3 colunas no PC, 2 no Tablet
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      mainAxisExtent:
                                          100, // Altura travada do card
                                    ),
                                itemCount: taskVM.tasks.length,
                                itemBuilder: (context, index) {
                                  final task = taskVM.tasks[index];
                                  return _buildTaskCard(context, task, taskVM);
                                },
                              )
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: taskVM.tasks.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final task = taskVM.tasks[index];
                                  return _buildTaskCard(context, task, taskVM);
                                },
                              ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskFormScreen()),
          );
        },
        label: const Text(
          "Nova Tarefa",
          style: TextStyle(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  // Card isolado e modularizado que se adapta ao grid ou ao listview dinamicamente
  Widget _buildTaskCard(BuildContext context, Task task, TaskViewModel taskVM) {
    final theme = Theme.of(context);
    final isDone = task.status == TaskStatus.done;

    final card = AppCard(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone
                ? AppColors.textMuted
                : (theme.brightness == Brightness.dark
                      ? AppColors.onPrimary
                      : AppColors.textHighEmphasis),
          ),
        ),
        subtitle: Text(
          task.description ?? 'Sem descrição',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        trailing: Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: isDone,
            activeColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (value) => taskVM.toggleTaskStatus(task),
          ),
        ),
      ),
    );

    return LongPressDraggable<TrashDragData>(
      data: TrashDragData(id: task.id, type: TrashItemType.task),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 320, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: card,
    );
  }

  Future<void> _moveToTrash(
    BuildContext context,
    TrashDragData data,
    TaskViewModel taskVM,
  ) async {
    if (data.type != TrashItemType.task) return;
    await taskVM.removeTask(data.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa movida para a lixeira.')),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 80,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tudo limpo por aqui!\nQue tal focar em algo novo?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
