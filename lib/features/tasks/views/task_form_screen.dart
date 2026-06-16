import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:focus/shared/widgets/app_input_decoration.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedCategoryId;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.colorScheme.primary,
              brightness: theme.brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskVM = context.read<TaskViewModel>();

      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        dueDate: _selectedDate,
        priority: _selectedPriority,
        status: TaskStatus.pending,
        categoryId: _selectedCategoryId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      taskVM.addTask(newTask);
      Navigator.pop(context);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryVM = context.watch<CategoryViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return AppGestureNavigation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBarWidget(
          leading: IconButton(
            tooltip: 'Voltar',
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.onPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? 520 : double.infinity,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho de Boas-Vindas
                    Text(
                      "Novo Objetivo",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.titleLarge?.color,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Organize seus passos e defina prazos claros.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    //Escopo da Tarefa (CONTAINER CLEAN)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "O que será feito?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _titleController,
                            maxLength: 50,
                            buildCounter:
                                (
                                  context, {
                                  required currentLength,
                                  required isFocused,
                                  maxLength,
                                }) => null, // Oculta contador feio nativo
                            decoration: appInputDecoration(
                              context,
                              label: 'Título do objetivo',
                              icon: Icons.edit_note_rounded,
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Insira um título para continuar'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descController,
                            maxLines: 3,
                            decoration: appInputDecoration(
                              context,
                              label: 'Notas adicionais ou descrição...',
                              icon: Icons.notes_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Configurações Metadados
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Ajustes de execução",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dropdown Categoria
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategoryId,
                            decoration: appInputDecoration(
                              context,
                              label: 'Categoria do projeto',
                              icon: Icons.category_rounded,
                            ),
                            items: categoryVM.categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category.id,
                                    child: Text(category.name),
                                  ),
                                )
                                .toList(),
                            onChanged: categoryVM.isLoading
                                ? null
                                : (value) => setState(
                                    () => _selectedCategoryId = value,
                                  ),
                          ),

                          const SizedBox(height: 16),

                          // Seletor de Data customizado estilo Card
                          Semantics(
                            button: true,
                            label: _selectedDate == null
                                ? 'Definir data de vencimento'
                                : 'Data de vencimento ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                            child: InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ExcludeSemantics(
                                      child: Icon(
                                        Icons.calendar_today_rounded,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedDate == null
                                            ? 'Definir data de vencimento'
                                            : 'Vence em: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _selectedDate == null
                                              ? Colors.grey
                                              : theme.colorScheme.primary,
                                          fontWeight: _selectedDate == null
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    ExcludeSemantics(
                                      child: Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Escolha de Prioridade com Chip de Feedback
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Nível de Urgência",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  _selectedPriority == TaskPriority.high
                                      ? 'ALTA'
                                      : _selectedPriority == TaskPriority.medium
                                      ? 'MÉDIA'
                                      : 'BAIXA',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                backgroundColor: _getPriorityColor(
                                  _selectedPriority,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<TaskPriority>(
                              style: SegmentedButton.styleFrom(
                                selectedBackgroundColor: theme
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.12),
                                selectedForegroundColor:
                                    theme.colorScheme.primary,
                              ),
                              segments: const [
                                ButtonSegment(
                                  value: TaskPriority.low,
                                  label: Text("Baixa"),
                                ),
                                ButtonSegment(
                                  value: TaskPriority.medium,
                                  label: Text("Média"),
                                ),
                                ButtonSegment(
                                  value: TaskPriority.high,
                                  label: Text("Alta"),
                                ),
                              ],
                              selected: {_selectedPriority},
                              onSelectionChanged:
                                  (Set<TaskPriority> newSelection) {
                                    setState(
                                      () => _selectedPriority =
                                          newSelection.first,
                                    );
                                  },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botão de Criação de Tarefa
                    Center(
                      child: Container(
                        width: isWideScreen ? 350 : double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary.withValues(
                                alpha: 0.85,
                              ),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _saveTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "SALVAR TAREFA",
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
