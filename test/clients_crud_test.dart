import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mis_app/features/clients/data/repositories/client_model.dart';
import 'package:mis_app/features/clients/data/repositories/mock_client_repository.dart';
import 'package:mis_app/features/clients/presentation/pages/client_list_page.dart';
import 'package:mis_app/features/clients/presentation/providers/client_providers.dart';
import 'package:mis_app/features/companies/data/repositories/mock_company_repository.dart';
import 'package:mis_app/features/companies/presentation/providers/company_providers.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en', null);
  });

  group(
      'ClientModel JSON parsing (Backend_Makromedia-Integrated-System contract)',
      () {
    test('ClientModel parses nested company relation from Prisma', () {
      final client = ClientModel.fromJson(const {
        'id': 'cli-100',
        'companyClientId': 'comp-100',
        'name': 'Budi Santoso',
        'email': 'budi@telkom.co.id',
        'phone': '081288001122',
        'company': {'id': 'comp-100', 'name': 'PT Telkom Indonesia'},
      });

      expect(client.companyClientId, 'comp-100');
      expect(client.companyName, 'PT Telkom Indonesia');
      expect(client.toUpsertJson()['companyClientId'], 'comp-100');
    });
  });

  group('ClientListPage widget tests', () {
    Widget wrap(Widget child) {
      return ProviderScope(
        overrides: [
          clientRepositoryProvider.overrideWithValue(MockClientRepository()),
          companyRepositoryProvider
              .overrideWithValue(MockCompanyRepository()),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('ClientListPage renders clients, searches, and opens form',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(const ClientListPage()));
      await tester.pumpAndSettle();

      expect(find.text('Data Client'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Siti Rahmawati'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '0813-4455');
      await tester.pumpAndSettle();

      expect(find.text('Siti Rahmawati'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsNothing);

      await tester.tap(find.text('Add Client'));
      await tester.pumpAndSettle();
      expect(find.text('Tambah Client Baru'), findsOneWidget);
    });
  });
}
