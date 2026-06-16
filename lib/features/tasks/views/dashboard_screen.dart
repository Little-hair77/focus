import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_drawer.dart';
import 'package:focus/shared/widgets/bottom_navigation_bar.dart';
import 'package:focus/shared/widgets/app_card.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskVM = context.watch<TaskViewModel>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: 0),
      body: taskVM.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Painel de Controle',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: theme.textTheme.titleLarge?.color,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Acompanhe o rendimento do seu foco',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.darkTextMediumEmphasis
                                        : AppColors.textMediumEmphasis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              completionRate == 1.0 && totalTasks > 0
                                  ? "🔥 Concluído!"
                                  : "⚡ Em Foco",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // CONTAINER DE CARDS
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 760;
                          return GridView.count(
                            crossAxisCount: isWide ? 4 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            mainAxisExtent: 160,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _SummaryCard(
                                label: 'Total',
                                value: totalTasks.toString(),
                                icon: Icons.assignment_rounded,
                                iconColor: isDark
                                    ? AppColors.darkInfo
                                    : AppColors.info,
                              ),
                              _SummaryCard(
                                label: 'Concluídas',
                                value: doneTasks.toString(),
                                icon: Icons.check_circle_rounded,
                                iconColor: isDark
                                    ? AppColors.darkSuccess
                                    : AppColors.success,
                              ),
                              _SummaryCard(
                                label: 'Alta prioridade',
                                value: highPriorityTasks.toString(),
                                icon: Icons.flag_rounded,
                                iconColor: isDark
                                    ? AppColors.darkWarning
                                    : AppColors.warning,
                              ),
                              _SummaryCard(
                                label: 'Atrasadas',
                                value: overdueTasks.toString(),
                                icon: Icons.warning_rounded,
                                iconColor: isDark
                                    ? AppColors.darkDanger
                                    : AppColors.danger,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // CHARTS / GRÁFICOS
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 900;
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
                              title: 'Distribuição de prioridade',
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
                                              right: 16,
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
                                            bottom: 16,
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
  final Color iconColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$label: $value',
      readOnly: true,
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ícone envelopado em um background suave para parecer mais moderno e clean
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
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

    return Semantics(
      label:
          '$title. $percent por cento. $completed de $total focos concluídos.',
      readOnly: true,
      child: AppCard(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChartTitle(title),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth:
                            10, // Diminuído levemente a espessura para ficar mais elegante
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '$completed de $total focos concluídos',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
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

    final semanticSummary = items
        .map((item) => '${item.label}: ${item.value}')
        .join(', ');

    return Semantics(
      label: '$title. $semanticSummary.',
      readOnly: true,
      child: AppCard(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChartTitle(title),
            const SizedBox(height: 24),
            ...items.map((item) {
              final ratio = maxValue == 0 ? 0.0 : item.value / maxValue;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            item.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.value.toString(),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
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
        fontWeight: FontWeight.w800,
        color: Theme.of(context).textTheme.titleMedium?.color,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _ChartItem {
  final String label;
  final int value;

  const _ChartItem(this.label, this.value);
}
