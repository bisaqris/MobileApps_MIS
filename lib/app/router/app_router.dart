import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_shell.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/projects/presentation/pages/project_list_page.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const approvals = '/approvals';
  static const projects = '/projects';
  static const history = '/history';
  static const manpower = '/manpower';
  static const skills = '/skills';
  static const clients = '/clients';
  static const companies = '/companies';
  static const profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.uri.path == AppRoutes.login;

      if (!isLoggedIn && !isLoggingIn) return AppRoutes.login;

      if (isLoggedIn && isLoggingIn) return AppRoutes.dashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.projects,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ProjectListPage()),
          ),

          for (final p in [
            AppRoutes.approvals,
            AppRoutes.history,
            AppRoutes.manpower,
            AppRoutes.skills,
            AppRoutes.clients,
            AppRoutes.companies,
            AppRoutes.profile,
          ])
            GoRoute(
              path: p,
              pageBuilder: (_, __) => NoTransitionPage(
                child: Center(child: Text('Coming soon: $p')),
              ),
            ),
        ],
      ),
    ],
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
