import 'package:flutter/material.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:focus/core/theme/app_theme.dart';
import 'package:focus/features/tasks/views/dashboard_screen.dart';
import 'package:focus/features/tasks/views/task_list_screen.dart';
import 'package:focus/features/settings/viewmodels/theme_view_model.dart';
import 'package:focus/features/tasks/viewmodels/task_view_model.dart';
import 'package:focus/data/repositories/task_repository.dart';
import 'package:focus/data/repositories/firebase_task_repository.dart';
import 'package:focus/data/repositories/category_repository.dart';
import 'package:focus/data/repositories/firebase_category_repository.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:focus/features/categories/views/category_list_screen.dart';
import 'package:focus/features/trash/views/trash_screen.dart';
import 'package:focus/features/auth/views/login.dart';
import 'package:focus/features/auth/views/register.dart';
import 'package:focus/features/auth/views/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:focus/data/repositories/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Erro ao inicializar o Firebase: $e");
  }

  // Primeiro checa se NÃO é Web. Se for Web, ele nem lê o resto e evita o erro do SQLite.
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final themeViewModel = ThemeViewModel();
  await themeViewModel.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        Provider<TaskRepository>(create: (_) => FirebaseTaskRepository()),
        Provider<CategoryRepository>(
          create: (_) => FirebaseCategoryRepository(),
        ),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),

        ChangeNotifierProxyProvider<AuthViewModel, TaskViewModel>(
          create: (context) => TaskViewModel(context.read<TaskRepository>()),
          update: (context, authVM, taskVM) {
            taskVM!.syncUser(authVM.currentUser?.id);
            return taskVM;
          },
        ),
        ChangeNotifierProxyProvider<AuthViewModel, CategoryViewModel>(
          create: (context) =>
              CategoryViewModel(context.read<CategoryRepository>()),
          update: (context, authVM, categoryVM) {
            categoryVM!.syncUser(authVM.currentUser?.id);
            return categoryVM;
          },
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
        '/home': (context) =>
            const AuthGate(authenticatedScreen: DashboardScreen()),
        '/tasks': (context) =>
            const AuthGate(authenticatedScreen: TaskListScreen()),
        '/categories': (context) =>
            const AuthGate(authenticatedScreen: CategoryListScreen()),
        '/trash': (context) =>
            const AuthGate(authenticatedScreen: TrashScreen()),
      },

      home: const AuthGate(authenticatedScreen: DashboardScreen()),
    );
  }
}
