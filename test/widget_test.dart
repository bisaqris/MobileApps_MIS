import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mis_app/app/app.dart';

void main() {
  testWidgets('App boots and shows the dashboard', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MisApp()));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsWidgets);
  });
}