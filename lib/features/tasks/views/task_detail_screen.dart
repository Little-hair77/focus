import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:intl/intl.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_card.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:provider/provider.dart';

/// Tela de detalhes completos de uma tarefa.
class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  /// Texto exibido para a prioridade da tarefa.
  String get priorityLabel {
    switch (task.priority) {
      case TaskPriority.low:
        return 'Baixa';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.high:
        return 'Alta';
    }
  }

  /// Texto exibido para o status da tarefa.
  String get statusLabel {
    switch (task.status) {
      case TaskStatus.pending:
        return 'Pendente';
      case TaskStatus.inProgress:
        return 'Em andamento';
      case TaskStatus.done:
        return 'Concluída';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryVM = context.watch<CategoryViewModel>();
    final categoryName = categoryVM.categories
        .where((category) => category.id == task.categoryId)
        .map((category) => category.name)
        .firstOrNull;
    // A data pode ser nula, então a tela mostra um fallback em vez de quebrar a formatação.
    final dueDate = task.dueDate == null
        ? 'Sem prazo definido'
        : DateFormat('dd/MM/yyyy').format(task.dueDate!);

    return AppGestureNavigation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBarWidget(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.onPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            // Em telas largas, o card ganha mais espaço sem ocupar a tela inteira.
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhes da tarefa ${task.title}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          task.description?.isNotEmpty == true
                              ? task.description!
                              : 'Sem descrição',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = constraints.maxWidth > 520
                                ? (constraints.maxWidth - 16) / 2
                                : constraints.maxWidth;

                            // Wrap mantém uma coluna no mobile e duas colunas quando o card tem espaço.
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _buildInfoRow(
                                  Icons.flag_rounded,
                                  'Prioridade',
                                  priorityLabel,
                                  theme,
                                  itemWidth,
                                ),
                                _buildInfoRow(
                                  Icons.check_circle_rounded,
                                  'Status',
                                  statusLabel,
                                  theme,
                                  itemWidth,
                                ),
                                _buildInfoRow(
                                  Icons.calendar_today_rounded,
                                  'Vencimento',
                                  dueDate,
                                  theme,
                                  itemWidth,
                                ),
                                _buildInfoRow(
                                  Icons.category_rounded,
                                  'Categoria',
                                  categoryName ?? 'Sem categoria',
                                  theme,
                                  itemWidth,
                                ),
                                _buildInfoRow(
                                  Icons.history_rounded,
                                  'Criada em',
                                  DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(task.createdAt),
                                  theme,
                                  itemWidth,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Monta uma linha de informação da tarefa.
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
