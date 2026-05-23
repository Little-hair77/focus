import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_drawer.dart';
import 'package:focus/shared/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskVM = context.watch<TaskViewModel>();
    final theme = Theme.of(context);
    final tasks = taskVM.tasks;
    final totalTasks = tasks.length;
    final pendingTasks = _countStatus(tasks, TaskStatus.pending);
    final inProgressTasks = _countStatus(tasks, TaskStatus.inProgress);
    final doneTasks = _countStatus(tasks, TaskStatus.done);
    final highPriorityTasks = _countPriority(tasks, TaskPriority.high);
    final overdueTasks = _countOverdue(tasks);
    final completionRate = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const AppBarWidget(),
      drawer: const AppDrawer(),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/tasks');
          }
        },
      ),
      body: taskVM.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 760;
                          return GridView.count(
                            crossAxisCount: isWide ? 4 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            childAspectRatio: isWide ? 1.8 : 1.35,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _SummaryCard(
                                label: 'Total',
                                value: totalTasks.toString(),
                                icon: Icons.assignment_rounded,
                              ),
                              _SummaryCard(
                                label: 'Concluídas',
                                value: doneTasks.toString(),
                                icon: Icons.check_circle_rounded,
                              ),
                              _SummaryCard(
                                label: 'Alta prioridade',
                                value: highPriorityTasks.toString(),
                                icon: Icons.flag_rounded,
                              ),
                              _SummaryCard(
                                label: 'Atrasadas',
                                value: overdueTasks.toString(),
                                icon: Icons.warning_rounded,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 860;
                          final charts = [
                            _ProgressChart(
                              title: 'Progresso geral',
                              progress: completionRate,
                              completed: doneTasks,
                              total: totalTasks,
                            ),
                            _BarChart(
                              title: 'Tarefas por status',
                              items: [
                                _ChartItem('Pendentes', pendingTasks),
                                _ChartItem('Em andamento', inProgressTasks),
                                _ChartItem('Concluídas', doneTasks),
                              ],
                            ),
                            _BarChart(
                              title: 'Prioridade',
                              items: [
                                _ChartItem(
                                  'Baixa',
                                  _countPriority(tasks, TaskPriority.low),
                                ),
                                _ChartItem(
                                  'Média',
                                  _countPriority(tasks, TaskPriority.medium),
                                ),
                                _ChartItem('Alta', highPriorityTasks),
                              ],
                            ),
                          ];

                          return isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: charts
                                      .map(
                                        (chart) => Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            child: chart,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : Column(
                                  children: charts
                                      .map(
                                        (chart) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: chart,
                                        ),
                                      )
                                      .toList(),
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  int _countStatus(List<Task> tasks, TaskStatus status) {
    return tasks.where((task) => task.status == status).length;
  }

  int _countPriority(List<Task> tasks, TaskPriority priority) {
    return tasks.where((task) => task.priority == priority).length;
  }

  int _countOverdue(List<Task> tasks) {
    final today = DateTime.now();
    return tasks.where((task) {
      final dueDate = task.dueDate;
      return dueDate != null &&
          dueDate.isBefore(DateTime(today.year, today.month, today.day)) &&
          task.status != TaskStatus.done;
    }).length;
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final String title;
  final double progress;
  final int completed;
  final int total;

  const _ProgressChart({
    required this.title,
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartTitle(title),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 132,
              height: 132,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$completed de $total tarefas concluídas',
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final String title;
  final List<_ChartItem> items;

  const _BarChart({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = items.fold<int>(0, (max, item) {
      return item.value > max ? item.value : max;
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartTitle(title),
          const SizedBox(height: 18),
          ...items.map((item) {
            final ratio = maxValue == 0 ? 0.0 : item.value / maxValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        item.value.toString(),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 10,
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChartTitle extends StatelessWidget {
  final String title;

  const _ChartTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleMedium?.color,
      ),
    );
  }
}

class _ChartItem {
  final String label;
  final int value;

  const _ChartItem(this.label, this.value);
}

BoxDecoration _cardDecoration(ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadow.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
