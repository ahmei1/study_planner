import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

Database? _database;

// LOGIC: Open goals.db and create the table on the first run.
Future<Database> initDatabase() async {
  final database = _database;
  if (database != null && database.isOpen) return database;

  final path = join(await getDatabasesPath(), 'goals.db');
  return _database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subject TEXT NOT NULL,
          hours INTEGER NOT NULL,
          done INTEGER NOT NULL
        )
      ''');
    },
  );
}

Future<int> insertGoal(Map<String, dynamic> goal) async {
  final db = await initDatabase();
  return await db.insert('goals', {
    'subject': goal['subject'],
    'hours': goal['hours'],
    'done': goal['done'] == true ? 1 : 0,
  });
}

Future<List<Map<String, dynamic>>> getGoals() async {
  final db = await initDatabase();
  final rows = await db.query('goals', orderBy: 'id');

  // Copy each row so the UI can change its done value.
  return [
    for (final row in rows) {...row, 'done': row['done'] == 1},
  ];
}

Future<void> updateGoal(int id, bool done) async {
  final db = await initDatabase();
  await db.update(
    'goals',
    {'done': done ? 1 : 0},
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteGoal(int id) async {
  final db = await initDatabase();
  await db.delete('goals', where: 'id = ?', whereArgs: [id]);
}
