import 'package:flutter/material.dart';

import '../responsive/breakpoints.dart';
import '../theme/app_colors.dart';

class DataColumnDef<T> {
  const DataColumnDef({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.isTitle = false,
    this.isAction = false,
  });

  final String label;
  final Widget Function(BuildContext context, T item) cell;

  final int flex;

  final bool isTitle;

  final bool isAction;
}

class ResponsiveDataView<T> extends StatelessWidget {
  const ResponsiveDataView({
    super.key,
    required this.items,
    required this.columns,
    this.onRowTap,
    this.cardBuilder,
    this.cardBreakpoint = Breakpoints.tableToCards,
    this.emptyMessage = 'Belum ada data',
    this.footer,
  });

  final List<T> items;
  final List<DataColumnDef<T>> columns;
  final ValueChanged<T>? onRowTap;

  /// Opsional: card kustom. Jika null dipakai card otomatis dari [columns].
  final Widget Function(BuildContext context, T item)? cardBuilder;
  final double cardBreakpoint;
  final String emptyMessage;

  /// Mis. pagination "Showing 10 data out of 100".
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (items.isEmpty) return _Empty(message: emptyMessage);
      final useTable = constraints.maxWidth >= cardBreakpoint;
      return useTable ? _buildTable(context) : _buildCards(context);
    });
  }

  // ---------- Desktop / tablet lebar: TABEL ----------
  Widget _buildTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stroke),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(
            context,
            background: AppColors.gray50,
            builder: (c, _) => Text(
              c.label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray500),
            ),
          ),
          for (final item in items) ...[
            const Divider(),
            InkWell(
              onTap: onRowTap == null ? null : () => onRowTap!(item),
              child: _row(context, item: item, builder: (c, i) => c.cell(context, i as T)),
            ),
          ],
          if (footer != null) ...[const Divider(), Padding(padding: const EdgeInsets.all(16), child: footer)],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    T? item,
    Color? background,
    required Widget Function(DataColumnDef<T> column, Object? item) builder,
  }) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          for (final c in columns)
            Expanded(
              flex: c.flex,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Align(alignment: Alignment.centerLeft, child: builder(c, item)),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Mobile: LIST OF CARDS (1 baris tabel = 1 card) ----------
  Widget _buildCards(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          cardBuilder?.call(context, item) ?? _DefaultCard<T>(item: item, columns: columns, onTap: onRowTap),
          const SizedBox(height: 12),
        ],
        if (footer != null) footer!,
      ],
    );
  }
}

class _DefaultCard<T> extends StatelessWidget {
  const _DefaultCard({required this.item, required this.columns, this.onTap});

  final T item;
  final List<DataColumnDef<T>> columns;
  final ValueChanged<T>? onTap;

  @override
  Widget build(BuildContext context) {
    final title = columns.where((c) => c.isTitle).firstOrNull;
    final actions = columns.where((c) => c.isAction).firstOrNull;
    final fields = columns.where((c) => !c.isTitle && !c.isAction);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap == null ? null : () => onTap!(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.titleMedium,
                  child: title.cell(context, item),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
              ],
              for (final f in fields)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(f.label, style: Theme.of(context).textTheme.bodySmall),
                      ),
                      Expanded(
                        flex: 6,
                        child: Align(alignment: Alignment.centerRight, child: f.cell(context, item)),
                      ),
                    ],
                  ),
                ),
              if (actions != null) ...[
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: actions.cell(context, item)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
      );
}
