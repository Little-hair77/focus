import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';

/// Estado vazio quando não há tarefas cadastradas.
class TaskEmptyState extends StatelessWidget {
  const TaskEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Icon(
              Icons.assignment_turned_in_outlined,
              size: 80,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
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

/// Estado vazio quando os filtros não encontram tarefas.
class TaskNoResultsState extends StatelessWidget {
  const TaskNoResultsState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Nenhuma tarefa encontrada com os filtros atuais.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textMuted, fontSize: 16),
      ),
    );
  }
}
