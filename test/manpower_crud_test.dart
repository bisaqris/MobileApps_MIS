import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mis_app/features/manpower/data/repositories/manpower_model.dart';
import 'package:mis_app/features/manpower/data/repositories/mock_manpower_repository.dart';
import 'package:mis_app/features/manpower/domain/entities/manpower.dart';
import 'package:mis_app/features/manpower/presentation/pages/manpower_list_page.dart';
import 'package:mis_app/features/manpower/presentation/providers/manpower_providers.dart';
import 'package:mis_app/features/skills/data/repositories/mock_skill_repository.dart';
import 'package:mis_app/features/skills/presentation/providers/skill_providers.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en', null);
  });

  group(
      'ManpowerModel JSON parsing (Backend_Makromedia-Integrated-System contract)',
      () {
    test('ManpowerModel parses nested positionRef & skills from Prisma', () {
      final mp = ManpowerModel.fromJson(const {
        'id': 'mp-100',
        'name': 'Raka Pratama',
        'position': 'Legacy Pos',
        'positionRef': {'id': 'pos-1', 'name': 'Director of Photography'},
        'email': 'raka@makromedia.id',
        'phone': '08123456789',
        'employmentStatus': 'FULLTIME',
        'standardRate': '1500000.00',
        'skills': [
          {
            'skill': {'id': 'skl-1', 'name': 'Videography'},
          },
          {
            'skill': {'id': 'skl-2', 'name': 'Lighting Design'},
          },
        ],
        'availability': 'ON_PROJECT',
      });

      expect(mp.role, 'Director of Photography');
      expect(mp.skills, ['Videography', 'Lighting Design']);
      expect(mp.skillIds, ['skl-1', 'skl-2']);
      expect(mp.employmentStatus, EmploymentStatus.fulltime);
      expect(mp.availability, ManpowerAvailability.onProject);
      expect(mp.standardRate, 1500000);
      expect(mp.toUpsertJson()['position'], 'Director of Photography');
      expect(mp.toUpsertJson()['employmentStatus'], 'FULLTIME');
    });
  });

  group('ManpowerListPage widget tests', () {
    Widget wrap(Widget child) {
      return ProviderScope(
        overrides: [
          manpowerRepositoryProvider
              .overrideWithValue(MockManpowerRepository()),
          skillRepositoryProvider.overrideWithValue(MockSkillRepository()),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets(
        'ManpowerListPage filters by availability and opens form sheet',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(const ManpowerListPage()));
      await tester.pumpAndSettle();

      expect(find.text('Data Manpower'), findsOneWidget);
      expect(find.text('Raka Pratama'), findsOneWidget);
      expect(find.text('Dimas Saputra'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'On Project'));
      await tester.pumpAndSettle();

      expect(find.text('Dimas Saputra'), findsOneWidget);
      expect(find.text('Raka Pratama'), findsNothing);

      await tester.tap(find.text('Add Manpower'));
      await tester.pumpAndSettle();
      expect(find.text('Tambah Manpower Baru'), findsOneWidget);
    });
  });
}
