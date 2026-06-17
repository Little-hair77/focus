import 'package:flutter/material.dart';
import 'package:focus/data/repositories/access_log_repository.dart';
import 'package:focus/data/repositories/firebase_access_log_repository.dart';
import 'package:focus/features/auth/services/login_access_recorder.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:focus/core/theme/app_theme.dart';
import 'package:focus/features/tasks/views/dashboard_screen.dart';
import 'package:focus/features/tasks/views/task_list_screen.dart';
import 'package:focus/features/settings/viewmodels/theme_view_model.dart';
import 'package:focus/features/settings/views/settings_screen.dart';
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
import 'package:focus/core/services/permission_service.dart';
import 'package:focus/core/services/device_permission_service.dart';
import 'package:focus/data/repositories/location/contracts/location_repository.dart';
import 'package:focus/data/repositories/location/gps_location_repository.dart';
import 'package:focus/data/repositories/sensors/contracts/sensor_repository.dart';
import 'package:focus/data/repositories/sensors/device_sensor_repository.dart';
import 'package:focus/features/focus/viewmodels/focus_view_model.dart';
import 'package:focus/features/focus/views/focus_mode_screen.dart';
import 'package:focus/features/profile/viewmodels/profile_view_model.dart';
import 'package:focus/features/profile/view/profile_screen.dart';
import 'package:focus/shared/utils/navigation.dart';

/// Inicializa Firebase, repositórios e providers globais.
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
        Provider<PermissionService>(create: (_) => DevicePermissionService()),
        Provider<LocationRepository>(create: (_) => GpsLocationRepository()),
        Provider<AccessLogRepository>(
          create: (_) => FirebaseAccessLogRepository(),
        ),
        Provider<LoginAccessRecorder>(
          create: (context) => LoginAccessRecorder(
            permissionService: context.read<PermissionService>(),
            locationRepository: context.read<LocationRepository>(),
            accessLogRepository: context.read<AccessLogRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            loginAccessRecorder: context.read<LoginAccessRecorder>(),
          ),
        ),
        Provider<SensorRepository>(
          create: (_) => DeviceSensorRepository(),
          dispose: (_, repository) {
            // Se a biblioteca nativa expuser algum método de fechamento futuramente,
            // o ciclo de vida seguro já fica garantido pelo Provider aqui.
          },
        ),

        ChangeNotifierProvider(
          create: (context) => FocusViewModel(
            permissionService: context.read<PermissionService>(),
            locationRepository: context.read<LocationRepository>(),
            sensorRepository: context.read<SensorRepository>(),
          ),
        ),

        ChangeNotifierProxyProvider<AuthViewModel, ProfileViewModel>(
          create: (context) => ProfileViewModel(
            accessLogRepository: context.read<AccessLogRepository>(),
          ),
          update: (context, authVM, profileVM) {
            profileVM!.syncUser(
              authVM.currentUser?.id,
              accessLogVersion: authVM.accessLogVersion,
            );
            return profileVM;
          },
        ),

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

/// Widget raiz que define tema, rotas e providers visíveis ao app.
class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();

    return MaterialApp(
      title: 'Focus',
      showSemanticsDebugger: false, // Linha temporária
      debugShowCheckedModeBanner: false,
      themeMode: themeVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      onGenerateRoute: _onGenerateRoute,
      home: const AuthGate(authenticatedScreen: DashboardScreen()),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final Widget? page = switch (settings.name) {
      '/register' => const RegisterPage(),
      '/login' => const LoginPage(),
      '/home' => const AuthGate(authenticatedScreen: DashboardScreen()),
      '/tasks' => const AuthGate(authenticatedScreen: TaskListScreen()),
      '/categories' => const AuthGate(
        authenticatedScreen: CategoryListScreen(),
      ),
      '/trash' => const AuthGate(authenticatedScreen: TrashScreen()),
      '/focus' => const AuthGate(authenticatedScreen: FocusModeScreen()),
      '/profile' => const AuthGate(authenticatedScreen: ProfileScreen()),
      '/settings' => const AuthGate(authenticatedScreen: SettingsScreen()),
      _ => null,
    };

    if (page == null) return null;

    if (appTabRoutes.contains(settings.name)) {
      return PageRouteBuilder<void>(
        settings: settings,
        pageBuilder: (_, _, _) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
    }

    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }
}
