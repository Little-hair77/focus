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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryVM = context.watch<CategoryViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;

    // Define se a tela atual é considerada larga (Tablets ou Computador/Web)
    final isWideScreen = screenWidth > 600;

    return Scaffold(
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
      // Centraliza o formulário em telas grandes
      body: Center(
        child: ConstrainedBox(
          // Se for tela larga, limita a largura em 500px para o design não quebrar ou esticar.
          constraints: BoxConstraints(
            maxWidth: isWideScreen ? 500 : double.infinity,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Defina seu próximo objetivo",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _titleController,
                    decoration: appInputDecoration(
                      context,
                      label: 'O que você vai fazer?',
                      icon: Icons.edit_note_rounded,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Campo obrigatório'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: appInputDecoration(
                      context,
                      label: 'Detalhes adicionais',
                      icon: Icons.notes_rounded,
                    ),
                  ),

                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: appInputDecoration(
                      context,
                      label: 'Categoria',
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
                        : (value) {
                            setState(() => _selectedCategoryId = value);
                          },
                  ),

                  const SizedBox(height: 24),

                  // Campo de Data (DueDate) Adaptativo
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.05,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate == null
                                ? 'Quando vence?'
                                : 'Vence em: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                            style: TextStyle(
                              color: _selectedDate == null
                                  ? AppColors.textMediumEmphasis
                                  : theme.colorScheme.primary,
                              fontWeight: _selectedDate == null
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Prioridade",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<TaskPriority>(
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: theme.colorScheme.primary
                            .withValues(alpha: 0.15),
                        selectedForegroundColor: theme.colorScheme.primary,
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
                      onSelectionChanged: (Set<TaskPriority> newSelection) {
                        setState(() => _selectedPriority = newSelection.first);
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botão de Salvar Responsivo e com Cores do Tema
                  Center(
                    child: Container(
                      width: isWideScreen
                          ? 350
                          : double
                                .infinity, // Trava o tamanho se a tela for web/tablet
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _saveTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.transparent,
                          shadowColor: AppColors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "CRIAR TAREFA",
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
