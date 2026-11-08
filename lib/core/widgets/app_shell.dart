import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../app/router/app_router.dart';
import '../responsive/breakpoints.dart';
import '../theme/app_colors.dart';

class _MenuItem {
  const _MenuItem(this.label, this.icon, this.path);
  final String label;
  final IconData icon;
  final String path;
}

class _MenuSection {
  const _MenuSection(this.title, this.items);
  final String? title;
  final List<_MenuItem> items;
}

// Struktur sidebar mengikuti Figma: 2 menu atas + grup SALES / MANPOWER / CLIENT DATA.
// TODO: filter per role (Director, Finance, Sales, Project Manager, Production Team).
const _sections = <_MenuSection>[
  _MenuSection(null, [
    _MenuItem('Dashboard', Iconsax.home_2, AppRoutes.dashboard),
    _MenuItem(
        'Production Cost Approval', Iconsax.document_text, AppRoutes.approvals),
  ]),
  _MenuSection('SALES', [
    _MenuItem('Project List', Iconsax.document, AppRoutes.projects),
    _MenuItem('History Project', Iconsax.chart_square, AppRoutes.history),
  ]),
  _MenuSection('MANPOWER', [
    _MenuItem('Data Manpower', Iconsax.people, AppRoutes.manpower),
    _MenuItem('Skill Management', Iconsax.star, AppRoutes.skills),
  ]),
  _MenuSection('CLIENT DATA', [
    _MenuItem('Data Client', Iconsax.profile_2user, AppRoutes.clients),
    _MenuItem('Data Company', Iconsax.buildings_2, AppRoutes.companies),
  ]),
];

/// Kerangka halaman:
///  - Desktop (>=1024): sidebar permanen 305px di kiri.
///  - Tablet/Mobile   : sidebar menjadi Drawer + AppBar dengan tombol menu.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(width: 305, child: _Sidebar(location: location)),
            const VerticalDivider(),
            Expanded(child: child),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makromedia',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary50,
                child: Text('JD')),
          ),
        ],
      ),
      drawer: Drawer(
          child:
              SafeArea(child: _Sidebar(location: location, closeOnTap: true))),
      body: child,
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.location, this.closeOnTap = false});

  final String location;
  final bool closeOnTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: const Text('M',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Text('Makromedia', style: Theme.of(context).textTheme.titleLarge),
          ]),
          const SizedBox(height: 24),
          for (final s in _sections) ...[
            if (s.title != null)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(s.title!,
                    style: Theme.of(context).textTheme.labelSmall),
              ),
            for (final item in s.items)
              _MenuTile(
                item: item,
                selected: location.startsWith(item.path),
                onTap: () {
                  if (closeOnTap) Navigator.of(context).pop();

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(item.path);
                  });
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(
      {required this.item, required this.selected, required this.onTap});

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
                child: Text(item.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: fg, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
