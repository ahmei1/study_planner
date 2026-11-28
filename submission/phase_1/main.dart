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

// STATIC: The first version displays three fixed goals.
class StudyPlanner extends StatelessWidget {
  const StudyPlanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // STATIC: App title.
      appBar: AppBar(title: const Text('My Study Planner')),
      // STATIC: List heading and sample goal cards.
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('My Goals', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text('Mathematics'),
              subtitle: Text('4 hours'),
            ),
          ),
          Card(
            child: ListTile(title: Text('English'), subtitle: Text('2 hours')),
          ),
          Card(
            child: ListTile(title: Text('Physics'), subtitle: Text('3 hours')),
          ),
        ],
      ),
      // STATIC: The add button is a placeholder for the next phase.
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add goal',
        child: const Icon(Icons.add),
      ),
    );
  }
}
