import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

// STATIC: App setup and theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Study Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: const StudyPlanner(),
    );
  }
}

class StudyPlanner extends StatefulWidget {
  const StudyPlanner({super.key});

  @override
  State<StudyPlanner> createState() => _StudyPlannerState();
}

class _StudyPlannerState extends State<StudyPlanner> {
  // LOGIC: Keep the goals in memory.
  final List<Map<String, dynamic>> _goals = [
    {'subject': 'Mathematics', 'hours': 4, 'done': false},
    {'subject': 'English', 'hours': 2, 'done': false},
    {'subject': 'Physics', 'hours': 3, 'done': true},
  ];

  // LOGIC: Add a sample goal.
  void _addGoal() {
    setState(() {
      _goals.add({'subject': 'New Subject', 'hours': 1, 'done': false});
    });
  }

  // LOGIC: Flip the completion flag.
  void _toggleGoal(Map<String, dynamic> goal) {
    setState(() => goal['done'] = goal['done'] == false);
  }

  // LOGIC: Remove the selected goal.
  void _deleteGoal(Map<String, dynamic> goal) {
    setState(() => _goals.remove(goal));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // STATIC: App title.
      appBar: AppBar(title: const Text('My Study Planner')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _buildBody(),
          ),
        ),
      ),
      // CONNECTION: The add button calls the sample goal function.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGoal,
        icon: const Icon(Icons.add),
        label: const Text('Add goal'),
      ),
    );
  }

  Widget _buildBody() {
    // CONNECTION: Build the list from goal data and link its controls.
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
      itemCount: _goals.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              'My Goals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        final goal = _goals[index - 1];
        final subject = goal['subject'] as String;
        final hours = goal['hours'] as int;
        final done = goal['done'] as bool;

        return Card(
          child: ListTile(
            onTap: () => _toggleGoal(goal),
            leading: Checkbox(
              value: done,
              semanticLabel: 'Complete $subject',
              onChanged: (_) => _toggleGoal(goal),
            ),
            title: Text(
              subject,
              style: TextStyle(
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(hours == 1 ? '1 hour' : '$hours hours'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete goal',
              onPressed: () => _deleteGoal(goal),
            ),
          ),
        );
      },
    );
  }
}
