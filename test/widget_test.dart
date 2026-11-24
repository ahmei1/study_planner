import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner/main.dart';

void main() {
  testWidgets('goals can be added, toggled, and deleted', (tester) async {
    await tester.pumpWidget(const StudyPlannerApp());

    expect(find.text('My Study Planner'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Mathematics'));
    await tester.pump();

    final maths = tester.widget<Text>(find.text('Mathematics'));
    expect(maths.style?.decoration, TextDecoration.lineThrough);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Sample Goal 1'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Mathematics'),
        matching: find.byTooltip('Delete goal'),
      ),
    );
    await tester.pump();

    expect(find.text('Mathematics'), findsNothing);
    expect(find.text('English'), findsOneWidget);
  });
}
