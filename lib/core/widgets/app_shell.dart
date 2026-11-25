import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../app/router/app_router.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../responsive/breakpoints.dart';
import '../theme/app_colors.dart';

// ---- Menu item model ----
class _MenuItem {
  const _MenuItem(this.label, this.icon, this.path, {this.allowedRoles});
  final String label;
  final IconData icon;
  final String path;

  /// Jika null → semua role bisa akses. Jika diisi → hanya role tsb.
  final Set<UserRole>? allowedRoles;
}

class _MenuSection {
  const _MenuSection(this.title, this.items);
  final String? title;
  final List<_MenuItem> items;
}

// ---- Definisi menu + hak akses per role ----
const _allSections = <_MenuSection>[
  _MenuSection(null, [
    _MenuItem('Dashboard', Iconsax.home_2, AppRoutes.dashboard),
    _MenuItem(
      'Production Cost Approval',
      Iconsax.document_text,
      AppRoutes.approvals,
      allowedRoles: {UserRole.director, UserRole.finance, UserRole.projectManager},
    ),
  ]),
  _MenuSection('SALES', [
    _MenuItem(
      'Project List',
      Iconsax.document,
      AppRoutes.projects,
      allowedRoles: {UserRole.director, UserRole.sales, UserRole.projectManager},
    ),
    _MenuItem(
      'History Project',
      Iconsax.chart_square,
      AppRoutes.history,
      allowedRoles: {UserRole.director, UserRole.sales, UserRole.projectManager},
    ),
  ]),
  _MenuSection('MANPOWER', [
    _MenuItem(
      'Data Manpower',
      Iconsax.people,
      AppRoutes.manpower,
      allowedRoles: {UserRole.director, UserRole.projectManager, UserRole.production},
    ),
    _MenuItem(
      'Skill Management',
      Iconsax.star,
      AppRoutes.skills,
      allowedRoles: {UserRole.director, UserRole.projectManager, UserRole.production},
    ),
  ]),
  _MenuSection('CLIENT DATA', [
    _MenuItem(
      'Data Client',
      Iconsax.profile_2user,
      AppRoutes.clients,
      allowedRoles: {UserRole.director, UserRole.sales},
    ),
    _MenuItem(
      'Data Company',
      Iconsax.buildings_2,
      AppRoutes.companies,
      allowedRoles: {UserRole.director, UserRole.sales},
    ),
  ]),
];

/// Filter sections berdasarkan role user.
List<_MenuSection> _filteredSections(UserRole? role) {
  if (role == null) return _allSections;

  return _allSections
      .map((section) {
        final filtered = section.items
            .where((item) =>
                item.allowedRoles == null || item.allowedRoles!.contains(role))
            .toList();
        if (filtered.isEmpty) return null;
        return _MenuSection(section.title, filtered);
      })
      .whereType<_MenuSection>()
      .toList();
}

/// Kerangka halaman:
///  - Desktop (>=1024): sidebar permanen 305px di kiri.
///  - Tablet/Mobile   : sidebar menjadi Drawer + AppBar dengan tombol menu.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 305,
              child: _Sidebar(location: location, user: user),
            ),
            const VerticalDivider(),
            Expanded(child: child),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Makromedia',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary50,
                child: Text(
                  user?.initials ?? '??',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: _Sidebar(location: location, user: user, closeOnTap: true),
        ),
      ),
      body: child,
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.location,
    required this.user,
    this.closeOnTap = false,
  });

  final String location;
  final User? user;
  final bool closeOnTap;

  @override
  Widget build(BuildContext context) {
    final sections = _filteredSections(user?.role);

    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              children: [
                // Logo
                Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'M',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Makromedia',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ]),
                const SizedBox(height: 24),

                // Menu sections
                for (final s in sections) ...[
                  if (s.title != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        s.title!,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  for (final item in s.items)
                    _MenuTile(
                      item: item,
                      selected: location.startsWith(item.path),
                      onTap: () {
                        if (closeOnTap) Navigator.of(context).pop();
                        context.go(item.path);
                      },
                    ),
                ],
              ],
            ),
          ),

          // ---- Bottom: user info + profile link ----
          const Divider(height: 1),
          _UserTile(user: user, closeOnTap: closeOnTap),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, this.closeOnTap = false});

  final User? user;
  final bool closeOnTap;

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        if (closeOnTap) Navigator.of(context).pop();
        context.go(AppRoutes.profile);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Text(
                user!.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user!.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    user!.role.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Iconsax.setting_2,
              size: 18,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _MenuItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.white : AppColors.gray600;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Icon(item.icon, size: 22, color: fg),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
