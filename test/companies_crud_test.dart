import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mis_app/features/companies/data/repositories/company_model.dart';
import 'package:mis_app/features/companies/data/repositories/mock_company_repository.dart';
import 'package:mis_app/features/companies/presentation/pages/company_list_page.dart';
import 'package:mis_app/features/companies/presentation/providers/company_providers.dart';
import 'package:mis_app/features/projects/data/repositories/mock_project_repository.dart';
import 'package:mis_app/features/projects/presentation/providers/project_providers.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en', null);
  });

  group(
      'CompanyModel JSON parsing (Backend_Makromedia-Integrated-System contract)',
      () {
    test('CompanyModel parses nested clients list from Prisma', () {
      final company = CompanyModel.fromJson(const {
        'id': 'comp-100',
        'name': 'PT Telkom Indonesia',
        'phone': '(021) 5215-100',
        'address': 'Jl. Japati No. 1',
        'city': 'Bandung',
        'clients': [
          {'id': 'cli-001', 'name': 'Budi Santoso'},
        ],
      });

      expect(company.clientIds, ['cli-001']);
      expect(company.clientNames, ['Budi Santoso']);
      expect(company.fullAddress, 'Jl. Japati No. 1, Bandung');
    });
  });

  group('CompanyListPage widget tests', () {
    Widget wrap(Widget child) {
      return ProviderScope(
        overrides: [
          companyRepositoryProvider
              .overrideWithValue(MockCompanyRepository()),
          projectRepositoryProvider
              .overrideWithValue(MockProjectRepository()),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets(
        'CompanyListPage renders companies and shows connected projects in detail sheet',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(const CompanyListPage()));
      await tester.pumpAndSettle();

      expect(find.text('Data Perusahaan (Company)'), findsOneWidget);
      expect(find.text('PT Telkom Indonesia'), findsOneWidget);

      await tester.tap(find.text('PT Telkom Indonesia'));
      await tester.pumpAndSettle();

      expect(find.text('Daftar Project Terhubung'), findsOneWidget);
      expect(find.text('Annual Summit Livestream'), findsOneWidget);
    });
  });
}
