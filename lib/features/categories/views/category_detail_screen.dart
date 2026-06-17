import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/categories/models/category_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/features/tasks/models/task_model.dart'; 
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = category.displayColor;

    final taskVM = context.watch<TaskViewModel>();
    final categoryTasks = taskVM.tasks.where((task) => task.categoryId == category.id).toList();

    final completedTasksCount = categoryTasks.where((task) => task.status == TaskStatus.done).length;
    final pendingTasksCount = categoryTasks.length - completedTasksCount;

    return AppGestureNavigation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBarWidget(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.folder_open_rounded,
                          color: primaryColor,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Criada em ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(category.createdAt)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Desempenho da Categoria',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _buildStatCard(
                        context: context,
                        label: 'Concluídas',
                        value: completedTasksCount.toString(), 
                        icon: Icons.check_circle_outline_rounded,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        context: context,
                        label: 'Pendentes',
                        value: pendingTasksCount.toString(), 
                        icon: Icons.hourglass_empty_rounded,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // LISTA DE TAREFAS FILTRADAS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tarefas Recentes',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      if (categoryTasks.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            // Direciona para a lista geral passando o filtro se necessário
                            Navigator.pushNamed(context, '/tasks', arguments: category.id);
                          },
                          child: Text(
                            'Ver tudo',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // RENDERIZAÇÃO CONDICIONAL DA LISTA DE TAREFAS REAIS
                  if (categoryTasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'Nenhuma tarefa vinculada a esta categoria.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                    )
                  else
                    // Lista dinamicamente as tarefas encontradas para o ID desta categoria
                    ListView.builder(
                      shrinkWrap: true, // Garante que a lista não ocupe espaço infinito
                      physics: const NeverScrollableScrollPhysics(), 
                      itemCount: categoryTasks.length > 5 ? 5 : categoryTasks.length, 
                      itemBuilder: (context, index) {
                        final task = categoryTasks[index];
                        return _buildMiniTaskTile(
                          title: task.title,
                          isDone: task.status == TaskStatus.done,
                          theme: theme,
                        );
                      },
                    ),
                  
                  const SizedBox(height: 40),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.palette_rounded, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Text(
                          'Identificador de cor:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category.color.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
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

  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTaskTile({
    required String title,
    required bool isDone,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? Colors.grey : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}