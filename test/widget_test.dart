import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:study_planner/database_helper.dart';
import 'package:study_planner/main.dart';

void main() {
  late Directory databaseFolder;
  late Database database;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  setUp(() async {
    databaseFolder = await Directory.systemTemp.createTemp(
      'study_planner_test',
    );
    await databaseFactory.setDatabasesPath(databaseFolder.path);
    database = await initDatabase();
  });

  tearDown(() async {
    await database.close();
    await databaseFolder.delete(recursive: true);
  });

  testWidgets('validates goals and refreshes the summary after changes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('My Study Planner'), findsOneWidget);
    expect(
      find.text('No goals yet. Tap Add goal to get started.'),
      findsOneWidget,
    );
    expectSummary(tester, [0, 0, 0]);

    await tester.tap(find.text('Add goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a subject.'), findsOneWidget);
    expect(find.text('Enter a whole number greater than 0.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '  Mathematics  ');
    await tester.enterText(find.byType(TextField).at(1), '1.5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a whole number greater than 0.'), findsOneWidget);
    expect(find.byType(AddGoalScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '4');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('4 hours'), findsOneWidget);
    expectSummary(tester, [4, 0, 1]);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(
      tester.widget<Text>(find.text('Mathematics')).style?.decoration,
      TextDecoration.lineThrough,
    );
    expectSummary(tester, [4, 1, 0]);

    await tester.tap(find.text('Mathematics'));
    await tester.pumpAndSettle();
    expectSummary(tester, [4, 0, 1]);

    await tester.tap(find.text('Add goal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'English');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('English'), findsNothing);
    expectSummary(tester, [4, 0, 1]);

    await tester.tap(find.byTooltip('Delete goal'));
    await tester.pumpAndSettle();

    expect(find.text('Mathematics'), findsNothing);
    expect(
      find.text('No goals yet. Tap Add goal to get started.'),
      findsOneWidget,
    );
    expectSummary(tester, [0, 0, 0]);
  });

  test(
    'SQLite keeps saved goals, completion, and deletions after reopening',
    () async {
      final mathsId = await insertGoal({
        'subject': 'Mathematics',
        'hours': 4,
        'done': false,
      });
      final englishId = await insertGoal({
        'subject': 'English',
        'hours': 2,
        'done': false,
      });

      expect(mathsId, isNot(englishId));
      await updateGoal(mathsId, true);
      await deleteGoal(englishId);

      await database.close();
      database = await initDatabase();

      expect(await getGoals(), [
        {'id': mathsId, 'subject': 'Mathematics', 'hours': 4, 'done': true},
      ]);
    },
  );
}

void expectSummary(WidgetTester tester, List<int> expected) {
  final cards = tester.widgetList<SummaryCard>(find.byType(SummaryCard));
  expect(cards.map((card) => card.value), expected);
}
