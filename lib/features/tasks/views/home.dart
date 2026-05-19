import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus/features/tasks/viewmodels/theme_view_model.dart';
import '../viewmodels/task_view_model.dart';
import './task_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    final taskVM = context.watch<TaskViewModel>();
    final isDark = themeVM.isDarkMode;

    // Definição de cores para o design roxo clean
    const primaryPurple = Colors.deepPurple;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: backgroundColor,

      // O Drawer é o menu de "três traços" (Hambúrguer)
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: primaryPurple),
              accountName: const Text(
                "Pablo Henrique",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text("Desenvolvedor"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  "P",
                  style: TextStyle(fontSize: 24, color: primaryPurple),
                ),
              ),
            ),
            ListTile(
              leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              title: Text(isDark ? "Modo Claro" : "Modo Noturno"),
              trailing: Switch(
                value: isDark,
                onChanged: (value) => themeVM.toggleTheme(),
                activeColor: primaryPurple,
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Focus App v1.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : primaryPurple),
        title: const Text(
          'Focus',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: primaryPurple,
          ),
        ),
        centerTitle: false,

        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            tooltip: 'Login',
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Minhas Tarefas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: taskVM.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryPurple),
                    )
                  : taskVM.tasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: taskVM.tasks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = taskVM.tasks[index];
                        final isDone = task.status.index == 2;

                        return Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDone
                                    ? Colors.grey
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            subtitle: Text(
                              task.description ?? 'Sem descrição',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: isDone,
                                activeColor: primaryPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) =>
                                    taskVM.toggleTaskStatus(task),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskFormScreen()),
          );
        },
        label: const Text("Nova Tarefa", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tudo limpo por aqui!\nQue tal focar em algo novo?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
