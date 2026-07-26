import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../app/theme.dart';
import '../constants/app_roles.dart';
import '../controllers/daily_task_controller.dart';
import '../controllers/employee_controller.dart';
import '../controllers/employee_request_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/shift_controller.dart';
import '../controllers/store_controller.dart';
import '../controllers/system_log_controller.dart';
import '../controllers/task_category_controller.dart';
import '../controllers/task_controller.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_employees.dart';
import '../screens/admin/admin_global_search.dart';
import '../screens/admin/admin_history.dart';
import '../screens/admin/admin_notifications.dart';
import '../screens/admin/admin_settings.dart';
import '../screens/admin/admin_shifts.dart';
import '../screens/admin/admin_stores.dart';
import '../screens/admin/admin_task_stats.dart';
import '../screens/admin/admin_tasks.dart';
import '../screens/admin/admin_statistics.dart';
import '../screens/admin/daily_tasks/admin_daily_task_templates.dart';
import '../screens/admin/requests/admin_requests_page.dart';

import '../repositories/task_repository.dart';
import '../screens/auth/login_screen.dart';
import '../screens/employee/employee_dashboard.dart';
import '../screens/employee/tasks/my_tasks_screen.dart';
import '../screens/employee/tasks/task_details_screen.dart';
import '../services/task_checker_service.dart';

// ==================== Smooth Page Transitions ====================
class _FadeSlidePage<T> extends CustomTransitionPage<T> {
  _FadeSlidePage({required super.child})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.08, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}

// ==================== Router (created once, never rebuilt) ====================
final _router = GoRouter(
  initialLocation: AppRoutes.login,
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentEmployee;
    final isLoggedIn = user != null;
    final isLoginRoute = state.matchedLocation == AppRoutes.login;

    if (!isLoggedIn && !isLoginRoute) {
      return AppRoutes.login;
    }
    if (isLoggedIn && isLoginRoute) {
      final role = user.role;
      if (role == AppRoles.admin) return AppRoutes.admin;
      return AppRoutes.employee;
    }

    if (isLoggedIn && user.role != AppRoles.admin) {
      if (state.matchedLocation.startsWith('/admin') ||
          state.matchedLocation == AppRoutes.settings) {
        return AppRoutes.employee;
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.admin,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminDashboard()),
    ),
    GoRoute(
      path: AppRoutes.adminEmployees,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminEmployeesPage()),
    ),
    GoRoute(
      path: AppRoutes.adminStores,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminStoresPage()),
    ),
    GoRoute(
      path: AppRoutes.adminShifts,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminShiftsPage()),
    ),
    GoRoute(
      path: AppRoutes.adminHistory,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminHistoryPage()),
    ),
    GoRoute(
      path: AppRoutes.adminNotifications,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminNotificationsPage()),
    ),
    GoRoute(
      path: AppRoutes.adminSearch,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminGlobalSearchPage()),
    ),
    GoRoute(
      path: AppRoutes.adminTasks,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminTasksPage()),
    ),
    GoRoute(
      path: AppRoutes.adminDailyTasks,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminDailyTaskTemplatesPage()),
    ),
    GoRoute(
      path: AppRoutes.adminRequests,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminRequestsPage()),
    ),
    GoRoute(
      path: AppRoutes.adminTasksStats,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminTaskStatsPage()),
    ),
    GoRoute(
      path: AppRoutes.adminStatistics,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminStatisticsPage()),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const AdminSettingsPage()),
    ),
    GoRoute(
      path: AppRoutes.employee,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const EmployeeDashboardPage()),
    ),
    GoRoute(
      path: AppRoutes.employeeTasks,
      pageBuilder: (context, state) =>
          _FadeSlidePage(child: const MyTasksScreen()),
    ),
    GoRoute(
      path: '${AppRoutes.employeeTasks}/:id',
      pageBuilder: (context, state) {
        final taskId = int.parse(state.pathParameters['id']!);
        return _FadeSlidePage(child: TaskDetailsScreen(taskId: taskId));
      },
    ),
    GoRoute(
      path: AppRoutes.employeeProfile,
      pageBuilder: (context, state) => _FadeSlidePage(
        child: const Scaffold(
          appBar: null,
          body: Center(child: Text('Профиль сотрудника (в разработке)')),
        ),
      ),
    ),
  ],
);

class RossTabakApp extends StatelessWidget {
  const RossTabakApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Запускаем фоновую проверку просроченных задач
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final checker = TaskCheckerService();
      checker.start();
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) {
            // Wrap AuthProvider creation in try/catch so startup errors
            // are caught by the global error handler in main.dart
            try {
              return AuthProvider();
            } catch (e, stackTrace) {
              // Log via the global handler
              FlutterError.reportError(
                FlutterErrorDetails(
                  exception: e,
                  stack: stackTrace,
                  context: ErrorDescription('AuthProvider creation'),
                ),
              );
              rethrow;
            }
          },
        ),
        Provider(create: (_) => TaskRepository()),
        ChangeNotifierProvider(create: (_) => StoreController()..loadStores()),
        ChangeNotifierProvider(
          create: (_) => EmployeeController()..loadEmployees(),
        ),
        ChangeNotifierProvider(create: (_) => TaskController()..loadTasks()),
        ChangeNotifierProvider(
          create: (_) => TaskCategoryController()..loadCategories(),
        ),
        ChangeNotifierProvider(create: (_) => ShiftController()..loadShifts()),
        ChangeNotifierProvider(
          create: (_) => SystemLogController()..loadLogs(),
        ),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(
          create: (_) => DailyTaskController()..loadTemplates(),
        ),
        ChangeNotifierProvider(create: (_) => EmployeeRequestController()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'RossTabak Manager',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
