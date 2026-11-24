import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const StudyPlannerApp());
}

// STATIC: the app shell. It only sets the title, the colours, and the home screen.
class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Study Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0FDFA),
      ),
      home: const StudyPlannerScreen(),
    );
  }
}

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  // LOGIC: every goal is one map with subject, hours, and done.
  final List<Map<String, dynamic>> goals = [
    {'subject': 'Mathematics', 'hours': 4, 'done': false},
    {'subject': 'English', 'hours': 2, 'done': false},
    {'subject': 'Physics', 'hours': 3, 'done': true},
  ];

  int _nextSample = 1;

  // LOGIC: the + button adds one practice goal.
  void addSampleGoal() {
    setState(() {
      goals.add({
        'subject': 'Sample Goal $_nextSample',
        'hours': 1,
        'done': false,
      });
      _nextSample = _nextSample + 1;
    });
  }

  // LOGIC: tap a goal to switch done on or off.
  void toggleDone(int index) {
    setState(() {
      final isDone = goals[index]['done'] == true;
      goals[index]['done'] = !isDone;
    });
  }

  // LOGIC: remove one goal from the list.
  void deleteGoal(int index) {
    setState(() {
      goals.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // STATIC: the bar at the top with the app name.
      appBar: AppBar(
        title: const Text('My Study Planner'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),

      // STATIC: everything under the bar.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATIC: the heading above the list.
            Text(
              'My Goals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF134E4A),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              // CONNECTION: this list is drawn from the goals data above.
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final done = goal['done'] == true;
                  final hours = goal['hours'] as int;
                  final hoursText = hours == 1 ? '1 hour' : '$hours hours';

                  // STATIC: one goal card.
                  return Card(
                    color: done ? const Color(0xFFE8F1F4) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => toggleDone(index),
                      leading: Checkbox(
                        value: done,
                        onChanged: (_) => toggleDone(index),
                      ),
                      title: Text(
                        goal['subject'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: done
                              ? const Color(0xFF475569)
                              : const Color(0xFF134E4A),
                        ),
                      ),
                      subtitle: Text(hoursText),
                      trailing: IconButton(
                        tooltip: 'Delete goal',
                        icon: Icon(
                          Icons.delete_outline,
                          color: colors.error,
                        ),
                        onPressed: () => deleteGoal(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // STATIC: the round + button.
      // CONNECTION: pressing it calls addSampleGoal, which updates the list.
      floatingActionButton: FloatingActionButton(
        onPressed: addSampleGoal,
        tooltip: 'Add a sample goal',
        child: const Icon(Icons.add),
      ),
    );
  }
}
