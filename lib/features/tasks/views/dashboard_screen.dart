import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/features/tasks/widgets/dashboard_charts.dart';
import 'package:focus/features/tasks/widgets/dashboard_summary_card.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_drawer.dart';
import 'package:focus/shared/widgets/bottom_navigation_bar.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:provider/provider.dart';

/// Tela inicial com métricas e gráficos das tarefas.
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

    return AppGestureNavigation(
      tabIndex: 0,
      child: Scaffold(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
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
                                DashboardSummaryCard(
                                  label: 'Total',
                                  value: totalTasks.toString(),
                                  icon: Icons.assignment_rounded,
                                  iconColor: isDark
                                      ? AppColors.darkInfo
                                      : AppColors.info,
                                ),
                                DashboardSummaryCard(
                                  label: 'Concluídas',
                                  value: doneTasks.toString(),
                                  icon: Icons.check_circle_rounded,
                                  iconColor: isDark
                                      ? AppColors.darkSuccess
                                      : AppColors.success,
                                ),
                                DashboardSummaryCard(
                                  label: 'Alta prioridade',
                                  value: highPriorityTasks.toString(),
                                  icon: Icons.flag_rounded,
                                  iconColor: isDark
                                      ? AppColors.darkWarning
                                      : AppColors.warning,
                                ),
                                DashboardSummaryCard(
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
                              DashboardProgressChart(
                                title: 'Progresso geral',
                                progress: completionRate,
                                completed: doneTasks,
                                total: totalTasks,
                              ),
                              DashboardBarChart(
                                title: 'Tarefas por status',
                                items: [
                                  DashboardChartItem('Pendentes', pendingTasks),
                                  DashboardChartItem(
                                    'Em andamento',
                                    inProgressTasks,
                                  ),
                                  DashboardChartItem('Concluídas', doneTasks),
                                ],
                              ),
                              DashboardBarChart(
                                title: 'Distribuição de prioridade',
                                items: [
                                  DashboardChartItem(
                                    'Baixa',
                                    _countPriority(tasks, TaskPriority.low),
                                  ),
                                  DashboardChartItem(
                                    'Média',
                                    _countPriority(tasks, TaskPriority.medium),
                                  ),
                                  DashboardChartItem('Alta', highPriorityTasks),
                                ],
                              ),
                            ];

                            return isWide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
      ),
    );
  }

  /// Conta tarefas por status.
  int _countStatus(List<Task> tasks, TaskStatus status) {
    return tasks.where((task) => task.status == status).length;
  }

  /// Conta tarefas por prioridade.
  int _countPriority(List<Task> tasks, TaskPriority priority) {
    return tasks.where((task) => task.priority == priority).length;
  }

  /// Conta tarefas vencidas que ainda não foram concluídas.
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
