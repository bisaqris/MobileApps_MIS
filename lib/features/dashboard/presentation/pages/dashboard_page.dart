import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Angka contoh dari Figma. Ganti dengan provider data asli.
    final stats = <(String, int)>[
      ('Total Contract Value', 19000000),
      ('Total Paid', 5000000),
      ('Rest of the Bill', 14000000),
      ('Total Project Cost', 8000000),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, c) {
            // 4 kolom (lebar) -> 2 kolom (tablet) -> 1 kolom (mobile)
            final cols = c.maxWidth >= 900 ? 4 : (c.maxWidth >= 500 ? 2 : 1);
            const gap = 16.0;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final s in stats)
                  SizedBox(
                    width: w,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.$1, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Text(Formatters.rupiah(s.$2),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                        ]),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 24),
          Text('Calendar Project', style: Theme.of(context).textTheme.titleLarge),
          // TODO: table_calendar + daftar card-schedule.
        ],
      ),
    );
  }
}
