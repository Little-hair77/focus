import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:focus/core/theme/app_theme.dart';
import 'package:focus/features/tasks/views/home.dart';
import 'package:focus/features/tasks/viewmodels/theme_view_model.dart';
import 'features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/data/repositories/sqlite_task_repository.dart';
import 'package:focus/features/tasks/views/login.dart';
import 'package:focus/features/tasks/views/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Primeiro checa se NÃO é Web. Se for Web, ele nem lê o resto e evita o erro.
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final themeViewModel = ThemeViewModel();
  await themeViewModel.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => SQLiteTaskRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              TaskViewModel(context.read<SQLiteTaskRepository>())..fetchTasks(),
        ),
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
    final themeVM = context.watch<ThemeViewModel>();

    return MaterialApp(
      title: 'Focus',
      debugShowCheckedModeBanner: false,
      themeMode: themeVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      routes: {
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
      },

      home: const HomeScreen(),
    );
  }
}
