import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mis_app/features/projects/presentation/pages/project_detail_page.dart';

import '../../core/widgets/app_shell.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/projects/presentation/pages/project_list_page.dart';

/// Semua path aplikasi di satu tempat (dipakai juga oleh sidebar).
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
  // TODO: ganti dengan state auth (Riverpod) + redirect guard.
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
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
              routes: [
                GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return ProjectDetailPage(projectId: id);
                    })
              ]),
          // Halaman lain: sementara placeholder sampai fitur dibuat.
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
