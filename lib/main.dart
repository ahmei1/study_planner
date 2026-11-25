
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// STATIC: Main app setup
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StudyPlanner(),
    );
  }
}

// Phase 2: Stateful screen
class StudyPlanner extends StatefulWidget {
  const StudyPlanner({super.key});

  @override
  State<StudyPlanner> createState() => _StudyPlannerState();
}

class _StudyPlannerState extends State<StudyPlanner> {

  // LOGIC: Store the study goals
  List<Map<String, dynamic>> goals = [
    {'subject': 'Mathematics', 'hours': 4, 'done': false},
    {'subject': 'English', 'hours': 2, 'done': false},
    {'subject': 'Physics', 'hours': 3, 'done': true},
  ];

  // LOGIC: Add a sample goal
  void addGoal() {
    setState(() {
      goals.add({
        'subject': 'New Subject',
        'hours': 1,
        'done': false,
      });
    });
  }

  // LOGIC: Mark a goal as done or not done
  void toggleGoal(int index) {
    setState(() {
      goals[index]['done'] = !goals[index]['done'];
    });
  }

  // LOGIC: Delete a goal
  void deleteGoal(int index) {
    setState(() {
      goals.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // STATIC: App title
      appBar: AppBar(
        title: const Text('My Study Planner'),
      ),

      // STATIC: Heading and goals list
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'My Goals',
              style: TextStyle(fontSize: 24),
            ),
          ),

          // CONNECTION: Display goals from the list
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];

                return Card(
                  child: ListTile(
                    // CONNECTION: Tap to change completion status
                    onTap: () => toggleGoal(index),

                    leading: Checkbox(
                      value: goal['done'],
                      onChanged: (value) => toggleGoal(index),
                    ),

                    title: Text(
                      goal['subject'],
                      style: TextStyle(
                        decoration: goal['done']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),

                    subtitle: Text('${goal['hours']} hours'),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteGoal(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // STATIC in Phase 1; adds a goal in Phase 2
      floatingActionButton: FloatingActionButton(
        onPressed: addGoal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
