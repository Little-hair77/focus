import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:focus/features/tasks/models/task_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;

  // Estilo padrão para os campos de texto
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.deepPurple.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
      ),
      floatingLabelStyle: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskVM = context.read<TaskViewModel>();
      
      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        priority: _selectedPriority,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      taskVM.addTask(newTask);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Tarefa"),
        titleTextStyle: const TextStyle(
          color: Colors.deepPurple, 
          fontSize: 20, 
          fontWeight: FontWeight.w900
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.deepPurple, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "O que você vai focar hoje?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 32),
              
              // Campo de Título
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: _inputStyle('Título da Tarefa', Icons.edit_note_rounded),
                validator: (value) => value == null || value.isEmpty ? 'Dê um nome ao seu foco' : null,
              ),
              
              const SizedBox(height: 20),
              
              // Campo de Descrição
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: _inputStyle('Notas ou detalhes', Icons.notes_rounded),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                "Nível de Prioridade",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              
              // SegmentedButton Estilizado
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<TaskPriority>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: Colors.deepPurple.withOpacity(0.2),
                    selectedForegroundColor: Colors.deepPurple,
                    side: BorderSide(color: Colors.deepPurple.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  segments: const [
                    ButtonSegment(value: TaskPriority.low, label: Text("Baixa"), icon: Icon(Icons.low_priority)),
                    ButtonSegment(value: TaskPriority.medium, label: Text("Média"), icon: Icon(Icons.sync_alt)),
                    ButtonSegment(value: TaskPriority.high, label: Text("Alta"), icon: Icon(Icons.priority_high)),
                  ],
                  selected: {_selectedPriority},
                  onSelectionChanged: (Set<TaskPriority> newSelection) {
                    setState(() => _selectedPriority = newSelection.first);
                  },
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Botão de Salvar Profissional
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Color(0xFF8E24AA)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    "CONCLUIR",
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w900, 
                      fontSize: 16,
                      letterSpacing: 1.2
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}