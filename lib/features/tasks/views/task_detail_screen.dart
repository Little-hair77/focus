import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:intl/intl.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:provider/provider.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  String get priorityLabel {
    switch (task.priority) {
      case TaskPriority.low: return 'Baixa';
      case TaskPriority.medium: return 'Média';
      case TaskPriority.high: return 'Alta';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return Colors.green;
      case TaskPriority.medium: return Colors.orange;
      case TaskPriority.high: return Colors.red;
    }
  }

  String get statusLabel {
    switch (task.status) {
      case TaskStatus.pending: return 'Pendente';
      case TaskStatus.inProgress: return 'Em Andamento';
      case TaskStatus.done: return 'Concluída';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending: return Colors.blueGrey;
      case TaskStatus.inProgress: return Colors.blue;
      case TaskStatus.done: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryVM = context.watch<CategoryViewModel>();
    final categoryName = categoryVM.categories
        .where((category) => category.id == task.categoryId)
        .map((category) => category.name)
        .firstOrNull ?? 'Sem categoria';

    final dueDate = task.dueDate == null
        ? 'Sem prazo definido'
        : DateFormat('dd \'de\' MMMM \'v\' yyyy', 'pt_BR').format(task.dueDate!);

    return AppGestureNavigation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBarWidget(
          leading: Semantics(
            label: 'Voltar',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏷️ CATEGORIA (Em formato de Micro-Tag superior)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      categoryName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 💎 TÍTULO DA TAREFA
                  Text(
                    task.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🚥 ROW DE BADGES (Status e Prioridade com cara de App Moderno)
                  Row(
                    children: [
                      _buildBadge(
                        statusLabel, 
                        _getStatusColor(task.status),
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(
                        'Prioridade $priorityLabel', 
                        _getPriorityColor(task.priority),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: theme.dividerColor.withOpacity(0.4)),
                  const SizedBox(height: 16),

                  // 📝 SEÇÃO: DESCRIÇÃO
                  Text(
                    'Descrição',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description?.isNotEmpty == true
                        ? task.description!
                        : 'Nenhuma descrição detalhada foi informada para esta tarefa.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Divider(color: theme.dividerColor.withOpacity(0.4)),
                  const SizedBox(height: 16),

                  // 📅 CARD DE METADADOS (Prazos e Auditoria)
                  Text(
                    'Datas e Prazos',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMetaTile(
                    Icons.calendar_month_rounded,
                    'Data de entrega',
                    dueDate,
                    theme,
                  ),
                  _buildMetaTile(
                    Icons.history_rounded,
                    'Criada em',
                    DateFormat('dd/MM/yyyy \'às\' HH:mm').format(task.createdAt),
                    theme,
                  ),
                  const SizedBox(height: 40),

                  // 🚀 ALGO A MAIS: BOTÕES DE AÇÃO RÁPIDA NA BASE DO DETALHE
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implementar exclusão
                          },
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                          label: const Text('Excluir', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (task.status != TaskStatus.done)
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implementar conclusão rápida
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Concluir Tarefa', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói as tags/badges arredondadas elegantes.
  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// Constrói uma fileira de metadados limpa e minimalista.
  Widget _buildMetaTile(IconData icon, String title, String subtitle, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant?.withOpacity(0.5) ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}