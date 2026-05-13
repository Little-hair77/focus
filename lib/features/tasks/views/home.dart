import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus/features/tasks/viewmodels/theme_view_model.dart';
import '../viewmodels/task_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    final taskVM = context.watch<TaskViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Botão para alternar o tema (SharedPreferences) 
          IconButton(
            icon: Icon(themeVM.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeVM.toggleTheme(),
            tooltip: 'Alternar Tema',
          ),
        ],
      ),
      body: taskVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskVM.tasks.isEmpty
              ? const Center(child: Text('Nenhuma tarefa para hoje. 🎯'))
              : ListView.builder(
                  itemCount: taskVM.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskVM.tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.description ?? ''),
                      trailing: Checkbox(
                        value: task.status.index == 2, 
                        onChanged: (value) => taskVM.toggleTaskStatus(task),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aqui você chamará a tela de criação (Futuro)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionalidade de criação em breve!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}