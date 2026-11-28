import 'package:material_ui/material_ui.dart';

import 'database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initDatabase();
  } catch (error) {
    // The home screen can show the error and let the user retry.
    debugPrint('Could not open goals.db: $error');
  }
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
  // LOGIC: Goals in memory and the statistics derived from them.
  List<Map<String, dynamic>> _goals = [];
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;

  int get _totalHours =>
      _goals.fold<int>(0, (sum, goal) => sum + (goal['hours'] as int));

  int get _completedGoals =>
      _goals.where((goal) => goal['done'] == true).length;

  int get _remainingGoals =>
      _goals.where((goal) => goal['done'] == false).length;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  // LOGIC: Load the saved goals when the screen opens.
  Future<void> _loadGoals() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final goals = await getGoals();
      if (!mounted) return;
      setState(() {
        _goals = goals;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  // LOGIC: Run one database change at a time.
  Future<void> _saveChange(Future<void> Function() change) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await change();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the change. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addGoal() async {
    if (_saving) return;
    final goal = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddGoalScreen()),
    );
    if (!mounted || goal == null) return;

    await _saveChange(() async {
      final id = await insertGoal(goal);
      if (!mounted) return;
      setState(() => _goals.add({...goal, 'id': id}));
    });
  }

  Future<void> _toggleGoal(Map<String, dynamic> goal) async {
    final done = goal['done'] == false;
    await _saveChange(() async {
      await updateGoal(goal['id'] as int, done);
      if (!mounted) return;
      setState(() => goal['done'] = done);
    });
  }

  Future<void> _deleteGoal(Map<String, dynamic> goal) async {
    await _saveChange(() async {
      await deleteGoal(goal['id'] as int);
      if (!mounted) return;
      setState(() => _goals.remove(goal));
    });
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
      // CONNECTION: The add button opens the form.
      floatingActionButton: _loading || _loadFailed
          ? null
          : FloatingActionButton.extended(
              onPressed: _saving ? null : _addGoal,
              icon: const Icon(Icons.add),
              label: const Text('Add goal'),
            ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load your goals.'),
            TextButton(onPressed: _loadGoals, child: const Text('Try again')),
          ],
        ),
      );
    }

    // CONNECTION: Build the list from goal data and link its controls.
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
      itemCount: _goals.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader(context);

        final goal = _goals[index - 1];
        final subject = goal['subject'] as String;
        final hours = goal['hours'] as int;
        final done = goal['done'] as bool;

        return Card(
          child: ListTile(
            onTap: _saving ? null : () => _toggleGoal(goal),
            leading: Checkbox(
              value: done,
              semanticLabel: 'Complete $subject',
              onChanged: _saving ? null : (_) => _toggleGoal(goal),
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
              onPressed: _saving ? null : () => _deleteGoal(goal),
            ),
          ),
        );
      },
    );
  }

  // STATIC: The summary row, heading, and empty list message.
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SummaryCard(label: 'Total hours', value: _totalHours),
              ),
              Expanded(
                child: SummaryCard(
                  label: 'Completed goals',
                  value: _completedGoals,
                ),
              ),
              Expanded(
                child: SummaryCard(
                  label: 'Remaining goals',
                  value: _remainingGoals,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Text(
            'My Goals',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (_goals.isEmpty)
          const Padding(
            padding: EdgeInsets.all(4),
            child: Text('No goals yet. Tap Add goal to get started.'),
          ),
      ],
    );
  }
}

// STATIC: The same card layout is used for all three statistics.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Column(
          children: [
            Text('$value', style: theme.textTheme.headlineSmall),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  // LOGIC: The controllers hold what the user types.
  final _subjectController = TextEditingController();
  final _hoursController = TextEditingController();
  String? _subjectError;
  String? _hoursError;

  void _saveGoal() {
    final subject = _subjectController.text.trim();
    final hours = int.tryParse(_hoursController.text.trim(), radix: 10);

    setState(() {
      _subjectError = subject.isEmpty ? 'Enter a subject.' : null;
      _hoursError = hours == null || hours <= 0
          ? 'Enter a whole number greater than 0.'
          : null;
    });
    if (subject.isEmpty || hours == null || hours <= 0) return;

    Navigator.pop(context, <String, dynamic>{
      'subject': subject,
      'hours': hours,
      'done': false,
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // STATIC: Subject and hours fields with a Save button.
    return Scaffold(
      appBar: AppBar(title: const Text('Add goal')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _subjectController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    errorText: _subjectError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _saveGoal(),
                  decoration: InputDecoration(
                    labelText: 'Hours',
                    errorText: _hoursError,
                    errorMaxLines: 3,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _saveGoal, child: const Text('Save')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
