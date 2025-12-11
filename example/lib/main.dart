import 'package:flutter/material.dart';
import 'package:multi_selection_calendar/controller/calendar_controller.dart';
import 'package:multi_selection_calendar/enums/enums.dart';
import 'package:multi_selection_calendar/widgets/multi_selection_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CalendarController _calendarController = CalendarController(
    conflictMode: ConflictMode.override,
    initialSelections: [
      CalendarSelection(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 4)),
        color: Colors.green,
      ),
      CalendarSelection(
        start: DateTime.now().subtract(const Duration(days: 5)),
        end: DateTime.now().subtract(const Duration(days: 2)),
        color: Colors.orange,
      ),
    ],
  );

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Center(
        child: Column(
          children: [
            Container(
              width: 600,
              padding: const EdgeInsets.all(32),
              child: MultiSelectionCalendar(
                controller: _calendarController,
                // dayBuilder: (date, daySelections, isSelected) {
                //   if (isSelected) {
                //     return CalendarDayBackground.selected(
                //       child: Text(
                //         '${date.day}',
                //         style: const TextStyle(
                //           fontWeight: FontWeight.bold,
                //           color: Colors.white,
                //         ),
                //       ),
                //     );
                //   }

                //   if (daySelections.isEmpty) return null;
                //   final isEndpoint = daySelections.any(
                //     (e) => date.isSameDate(e.start) || date.isSameDate(e.end),
                //   );
                //   if (!isEndpoint) return null;

                //   return CalendarDayBackground.day(
                //     date: date,
                //     selections: daySelections,
                //     child: Text(
                //       '${date.day}',
                //       style: const TextStyle(
                //         fontWeight: FontWeight.bold,
                //         color: Colors.white,
                //       ),
                //     ),
                //   );
                // },
                // textStyleDayBuilder: (date, daySelections, enabled) {
                //   if (daySelections.isEmpty) return null;
                //   final isEndpoint = daySelections.any(
                //     (e) => date.isSameDate(e.start) || date.isSameDate(e.end),
                //   );
                //   if (!isEndpoint) return null;

                //   return const TextStyle(
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white,
                //   );
                // },
              ),
            ),
            FilledButton(
              onPressed: () {
                _calendarController.clearSelections();
              },
              child: const Text('Clear Selections'),
            ),
          ],
        ),
      ),
    );
  }
}
