# My Study Planner

My Study Planner is a Flutter app for tracking study goals. Add a subject and
its planned hours, tap its checkbox when you finish it, or use the trash icon
to remove it. The three summary cards show your total planned hours and how
many goals are completed or remaining.

### Group 1

- 26669/2024
- 26932/2024
- 27844/2024
- 27701/2024
- 27224/2024

## Run the app

1. Open a terminal in the project folder. Use Flutter 3.50.1 with Dart 3.14,
   the versions used to build this project. For Android setup, follow the
   [Flutter Android guide](https://docs.flutter.dev/platform-integration/android/setup).
2. Start an Android emulator in Android Studio's Device Manager or connect an
   Android phone with USB debugging enabled. On a Mac, you can also use an iOS
   simulator.
3. Run these commands from the folder containing `pubspec.yaml`.

   ```sh
   flutter doctor
   flutter pub get
   flutter devices
   flutter run -d DEVICE_ID
   ```

   Replace `DEVICE_ID` with the Android or iOS device ID printed by
   `flutter devices`. The final app uses the native SQLite plugin, so choose
   a mobile target when demonstrating it.

4. Tap **Add goal**, enter **Mathematics** and **4**, then tap **Save**. The
   cards show **4 total hours**, **0 completed**, and **1 remaining**. Tick the
   checkbox and they change to **4**, **1**, and **0**.
5. Press `q` in the Flutter terminal to stop the app. Open **study_planner**
   from the device's app launcher. Mathematics should still be checked.
   Delete it, then close and reopen again. The goal should stay deleted and
   all three cards should show zero.

To build an installable Android APK, run `flutter build apk --debug`.
Flutter writes it to `build/app/outputs/flutter-apk/app-debug.apk`.

## The five phases

1. [**Static screen**](submission/phase_1/main.dart) uses a `StatelessWidget`
   and three fixed cards. The plus button is a placeholder.
2. [**Working list**](submission/phase_2/main.dart) moves the goals into a list
   of maps. The plus button adds a sample goal and `setState()` refreshes the
   screen when goals are added, checked, or removed.
3. [**Statistics and cards**](submission/phase_3/main.dart) calculates the
   three statistics from the list and shows an empty-state message after the
   last goal is deleted.
4. [**Second screen**](submission/phase_4/main.dart) replaces the sample button
   with a form. The user can save a real goal or go back to cancel.
5. [**SQLite persistence**](lib/main.dart) starts with an empty database on a
   fresh install. It saves goals, checkboxes, and deletions in `goals.db`.
   This is the version that opens when you run `flutter run`.

The early phases are runnable on their own. For example, use the command below
for Phase 1. Replace `phase_1` with `phase_2`, `phase_3`, or `phase_4` to
run that phase.

```sh
flutter run -d DEVICE_ID -t submission/phase_1/main.dart
```

Each phase folder under [submission](submission) has screenshots captured at
phone size by the Flutter test runner. The
[Phase 5 restart screenshot](submission/phase_5/03-after-restart.png) comes
from a separate test launch that reopened the same SQLite file. For Phase 5,
use [main.dart](lib/main.dart), [database_helper.dart](lib/database_helper.dart),
and [pubspec.yaml](pubspec.yaml) from the project.

## Walk through the final code

### 1. Start in main.dart

`main()` calls `WidgetsFlutterBinding.ensureInitialized()` so Flutter can
talk to the SQLite plugin before a screen exists. Then it awaits
`initDatabase()` and opens `MyApp`. `MyApp` sets the title and theme, and
uses `StudyPlanner` as its home screen.

### 2. Load the goals and build the list

`StudyPlanner` is a `StatefulWidget` because its goal data changes while
the app is open. Its state calls `_loadGoals()` from `initState()` once
when the screen is created. `getGoals()` reads the database rows, then
`setState()` puts the returned list into `_goals` and tells Flutter to
rebuild the screen.

Each item is a map. For example, a saved goal can look like this.

```dart
{'id': 1, 'subject': 'Mathematics', 'hours': 4, 'done': false}
```

`ListView.builder` renders the header first and then creates each goal's
`Card` and `ListTile` as needed. The checkbox and the tile both call
`_toggleGoal()`. A checked goal gets a line through its subject.

### 3. Recalculate the summary

The three getters read the current list every time the header rebuilds.
`_totalHours` uses `fold()` to start at zero and add each goal's hours.
`_completedGoals` and `_remainingGoals` use `where()` to count goals with
`done` set to `true` or `false`. The same `SummaryCard` widget displays
all three values. A `Row` with three `Expanded` children divides the
available width evenly.

### 4. Follow a new goal through both screens

Tapping **Add goal** calls `_addGoal()`, which awaits
`Navigator.push()`. Flutter opens `AddGoalScreen` while the first screen
waits for a result. The form reads its two `TextEditingController` objects
and trims the text. It shows an error beside an empty subject or hours that
cannot be read as a positive whole number.

With valid input, `Navigator.pop()` returns the new goal map. When the user
uses Back, it returns `null` and the home screen ignores it. The form releases
both controllers in `dispose()` when it closes.

### 5. Save the change in SQLite

All SQL and database calls live in [database_helper.dart](lib/database_helper.dart).

- `initDatabase()` uses `join()` to put `goals.db` in the platform's
  database folder. Its `onCreate` callback creates the `goals` table the
  first time the file is opened.
- `insertGoal()` writes the new goal and returns the ID that SQLite
  assigned. The screen then adds the map and its ID to `_goals`.
- `updateGoal()` and `deleteGoal()` use the goal's ID to target its row.
  Two goals can have the same subject and still have different IDs.
- Dart uses `true` and `false` for `done`. SQLite stores those values as
  `1` and `0`. The helper converts them in both directions.

The home screen waits for each write before changing its list with
`setState()`. `_saveChange()` keeps the controls disabled until the write
finishes, so two changes can't overlap. It checks `mounted` after waiting
because the user might have left the screen. On the next launch,
`_loadGoals()` reads the file again and the same getters recalculate the
summary.

## Verify the project

```sh
flutter analyze
flutter test
```

The tests cover form validation, adding, checking, unchecking, deleting,
cancelling, summary updates, and reopening a real SQLite database file.
They use `sqflite_common_ffi` so they can run without a phone. To practice for
the oral check, trace what happens from **Save** through `Navigator.pop()`,
`insertGoal()`, `setState()`, and the next app launch.
