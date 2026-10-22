import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mis_app/core/widgets/responsive_data_view.dart';

void main() {
  final columns = [
    DataColumnDef<String>(label: 'Name', isTitle: true, cell: (_, s) => Text(s)),
    DataColumnDef<String>(label: 'Length', cell: (_, s) => Text('${s.length}')),
  ];

  Future<void> pump(WidgetTester t, double width) async {
    t.view.physicalSize = Size(width, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(body: ResponsiveDataView<String>(items: const ['a', 'bb'], columns: columns)),
    ));
  }

  testWidgets('lebar -> tabel (ada header "Length")', (t) async {
    await pump(t, 1200);
    expect(find.byType(Card), findsNothing);
    expect(find.text('Length'), findsOneWidget);
  });

  testWidgets('sempit -> satu Card per baris', (t) async {
    await pump(t, 400);
    expect(find.byType(Card), findsNWidgets(2));
  });
}
