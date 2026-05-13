import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus/features/tasks/views/home.dart';
import 'package:focus/features/tasks/viewmodels/theme_view_model.dart';
import 'features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/data/repositories/sqlite_task_repository.dart';

void main() async {
  // 1. Garante que os plugins nativos (SQLite/Prefs) funcionem com código async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Carrega as preferências de tema antes do app iniciar
  final themeViewModel = ThemeViewModel();
  await themeViewModel.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        // Injeta o repositório SQLite [cite: 44, 115]
        Provider(create: (_) => SQLiteTaskRepository()),
        
        // Injeta o ViewModel de Tarefas e já busca os dados do banco [cite: 43, 70]
        ChangeNotifierProvider(
          create: (context) => TaskViewModel(
            context.read<SQLiteTaskRepository>(),
          )..fetchTasks(), 
        ),
        
        // Injeta o ViewModel de Tema carregado [cite: 105]
        ChangeNotifierProvider.value(value: themeViewModel),
      ],
      child: const FocusApp(),
    ),
  );
}

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o ThemeViewModel para mudar as cores do app [cite: 104]
    final themeVM = context.watch<ThemeViewModel>();

    return MaterialApp(
      title: 'Focus',
      debugShowCheckedModeBanner: false,
      // Gerencia o tema automaticamente entre Claro e Escuro [cite: 28]
      themeMode: themeVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue, // Cor azul conforme a identidade do Flutter [cite: 81]
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      // Aponta para a sua tela principal [cite: 41, 52]
      home: const HomeScreen(), 
    );
  }
}