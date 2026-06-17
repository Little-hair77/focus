import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/categories/models/category_model.dart';
import 'package:focus/features/focus/viewmodels/focus_view_model.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/features/tasks/views/task_detail_screen.dart';
import 'package:focus/features/tasks/views/task_form_screen.dart';
import 'package:focus/shared/models/trash_drag_data.dart';
import 'package:focus/shared/widgets/app_card.dart';
import 'package:provider/provider.dart';

/// Card visual de uma tarefa com ações rápidas e drag para lixeira.
class TaskCard extends StatelessWidget {
  final Task task;
  final TaskViewModel taskVM;
  final Map<String, Category> categoriesById;

  const TaskCard({
    super.key,
    required this.task,
    required this.taskVM,
    required this.categoriesById,
  });

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context);

    return Semantics(
      button: true,
      hint:
          'Toque duas vezes para iniciar foco. Pressione e segure para mover para a lixeira.',
      child: LongPressDraggable<TrashDragData>(
        data: TrashDragData(id: task.id, type: TrashItemType.task),
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(width: 320, child: card),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: card),
        child: card,
      ),
    );
  }

  /// Monta o conteúdo visual interno do card.
  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.status == TaskStatus.done;
    final priorityColor = _getPriorityColor(task.priority);

    return AppCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: priorityColor, width: 6)),
          ),
          child: ListTile(
            onTap: () {
              context.read<FocusViewModel>().setTask(task);
              Navigator.of(context).pushNamed('/focus');
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Ver detalhes',
                  icon: const Icon(Icons.visibility_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskFormScreen(task: task),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    semanticLabel: isDone
                        ? 'Tarefa ${task.title} concluída'
                        : 'Marcar tarefa ${task.title} como concluída',
                    value: isDone,
                    activeColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) => taskVM.toggleTaskStatus(task),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Retorna a cor visual associada à prioridade.
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red[400]!;
      case TaskPriority.medium:
        return Colors.amber[600]!;
      case TaskPriority.low:
        return Colors.green[400]!;
    }
  }
}
