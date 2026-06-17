import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/shared/widgets/app_card.dart';

/// Gráfico circular de progresso geral no dashboard.
class DashboardProgressChart extends StatelessWidget {
  final String title;
  final double progress;
  final int completed;
  final int total;

  const DashboardProgressChart({
    super.key,
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
                        strokeWidth: 10,
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

/// Gráfico de barras horizontal usado no dashboard.
class DashboardBarChart extends StatelessWidget {
  final String title;
  final List<DashboardChartItem> items;

  const DashboardBarChart({
    super.key,
    required this.title,
    required this.items,
  });

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

/// Item de dados exibido em um gráfico do dashboard.
class DashboardChartItem {
  final String label;
  final int value;

  const DashboardChartItem(this.label, this.value);
}

/// Título compartilhado entre gráficos do dashboard.
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
