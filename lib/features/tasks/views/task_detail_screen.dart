import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:focus/features/tasks/models/task_model.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  // A model salva prioridade como enum; a tela traduz para texto legível.
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

  // Centraliza a conversão do status para evitar texto solto no build.
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
    final isDark = theme.brightness == Brightness.dark;
    // A data pode ser nula, então a tela mostra um fallback em vez de quebrar a formatação.
    final dueDate = task.dueDate == null
        ? 'Sem prazo definido'
        : DateFormat('dd/MM/yyyy').format(task.dueDate!);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Detalhes da Tarefa"),
        titleTextStyle: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          // Mantém o mesmo padrão responsivo do formulário: centralizado e sem esticar no desktop.
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Replica o contraste dos cards da Home nos modos claro e escuro.
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    task.description?.isNotEmpty == true
                        ? task.description!
                        : 'Sem descrição',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    Icons.flag_rounded,
                    'Prioridade',
                    priorityLabel,
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.check_circle_rounded,
                    'Status',
                    statusLabel,
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    'Vencimento',
                    dueDate,
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.history_rounded,
                    'Criada em',
                    DateFormat('dd/MM/yyyy HH:mm').format(task.createdAt),
                    theme,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
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
    );
  }
}
