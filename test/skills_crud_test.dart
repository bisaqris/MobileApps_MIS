import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mis_app/features/skills/data/repositories/mock_skill_repository.dart';
import 'package:mis_app/features/skills/data/repositories/skill_model.dart';
import 'package:mis_app/features/skills/presentation/pages/skill_list_page.dart';
import 'package:mis_app/features/skills/presentation/providers/skill_providers.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en', null);
  });

  group('SkillModel JSON parsing (Backend_Makromedia-Integrated-System contract)',
      () {
    test('SkillModel parses backend response', () {
      final skill = SkillModel.fromJson(const {
        'id': '11111111-1111-4111-8111-111111111111',
        'name': 'Color Grading',
        'createdAt': '2026-03-01T10:00:00.000Z',
      });
      expect(skill.id, '11111111-1111-4111-8111-111111111111');
      expect(skill.name, 'Color Grading');
      expect(skill.createdAt, isNotNull);
      expect(skill.toCreateJson(), {'name': 'Color Grading'});
    });
  });

  group('SkillListPage widget tests', () {
    Widget wrap(Widget child) {
      return ProviderScope(
        overrides: [
          skillRepositoryProvider.overrideWithValue(MockSkillRepository()),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('SkillListPage renders list and opens Add Skill dialog',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(const SkillListPage()));
      await tester.pumpAndSettle();

      expect(find.text('Skill Management'), findsOneWidget);
      expect(find.text('Videography'), findsWidgets);

      await tester.tap(find.text('Add Skill'));
      await tester.pumpAndSettle();
      expect(find.text('Tambah Skill Baru'), findsOneWidget);
    });
  });
}
