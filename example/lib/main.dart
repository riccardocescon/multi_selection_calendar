import 'package:flutter/material.dart';
import 'package:multi_selection_calendar/controller/calendar_controller.dart';
import 'package:multi_selection_calendar/entities/calendar_decorations.dart';
import 'package:multi_selection_calendar/enums/enums.dart';
import 'package:multi_selection_calendar/extensions/extensions.dart';
import 'package:multi_selection_calendar/widgets/calendar_day_background.dart';
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
    conflictMode: ConflictMode.overlap,
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

              // child: MultiSelectionCalendar(
              //   controller: _calendarController,
              //   dayBuilder: (date, daySelections, isSelected) {
              //     if (isSelected) {
              //       return CalendarDayBackground.selected(
              //         date: date,
              //         selections: daySelections,
              //         child: Text(
              //           '${date.day}',
              //           style: const TextStyle(
              //             fontWeight: FontWeight.bold,
              //             color: Colors.white,
              //           ),
              //         ),
              //       );
              //     }

              //     if (daySelections.isEmpty) return null;
              //     final isEndpoint = daySelections.any(
              //       (e) => date.isSameDate(e.start) || date.isSameDate(e.end),
              //     );
              //     if (!isEndpoint) {
              //       return CalendarDayBackground.selected(
              //         date: date,
              //         selections: daySelections,
              //         dayDecoration: DayDecoration(
              //           selectedDayBackgroundColor: Colors.transparent,
              //         ),
              //         boxDecoration: BoxDecoration(
              //           border: Border.all(color: Colors.purple, width: 2),
              //           borderRadius: BorderRadius.all(Radius.circular(9999)),
              //         ),
              //         child: Text(
              //           '${date.day}',
              //           style: const TextStyle(
              //             fontWeight: FontWeight.bold,
              //             color: Colors.white,
              //           ),
              //         ),
              //       );
              //     }

              //     return CalendarDayBackground.day(
              //       date: date,
              //       selections: daySelections,
              //       dayDecoration: DayDecoration(
              //         selectedDayBackgroundColor: Colors.purple,
              //       ),
              //       child: Text(
              //         '${date.day}',
              //         style: const TextStyle(
              //           fontWeight: FontWeight.bold,
              //           color: Colors.white,
              //         ),
              //       ),
              //     );
              //   },
              //   textStyleDayBuilder: (date, daySelections, enabled) {
              //     if (daySelections.isEmpty) return null;
              //     final isEndpoint = daySelections.any(
              //       (e) => date.isSameDate(e.start) || date.isSameDate(e.end),
              //     );
              //     if (!isEndpoint) return null;

              //     return const TextStyle(
              //       fontWeight: FontWeight.bold,
              //       color: Colors.white,
              //     );
              //   },
              // ),
              child: _Test(),
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

class _Test extends StatefulWidget {
  const _Test({super.key});

  @override
  State<_Test> createState() => __TestState();
}

class __TestState extends State<_Test> {
  late CalendarController _calendarController;

  final timelines = [
    CalendarSelection(
      start: DateTime(2026, 1, 20),
      end: DateTime(2026, 1, 28),
      color: Colors.red,
    ),
  ];

  @override
  void initState() {
    _calendarController = CalendarController(
      conflictMode: ConflictMode.overlap,
      tapSettings: const TapSettings(enableRangeSelection: false),
      initialSelections: timelines,
      onSelectDay: (day) {},
      selectedDay: null,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiSelectionCalendar(
      minYear: DateTime.now().year,
      maxYear: DateTime.now().year + 1,
      initYear: DateTime.now().year,
      controller: _calendarController,
      dayDecoration: const DayDecoration(
        selectedDayBackgroundColor: Colors.red,
      ),
      dayBuilder: (date, daySelections, isSelected) {
        if (isSelected) {
          return _day(
            date: date,
            daySelections: daySelections,
            isSelected: isSelected,
            isException: false,
          );
        }

        final isInTimeline = timelines.any(
          (timeline) =>
              date.isAfterOrToday(timeline.start) &&
              date.isBeforeOrToday(timeline.end),
        );

        if (!isInTimeline) return null;

        return _day(
          date: date,
          daySelections: daySelections,
          isSelected: isSelected,
          isException: false,
        );
      },
    );
  }

  Widget _day({
    required DateTime date,
    required List<CalendarSelection> daySelections,
    required bool isSelected,
    required bool isException,
  }) {
    final text = Text(
      date.day.toString(),
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: isException ? Colors.red : Colors.white,
        fontSize: 12,
      ),
    );

    final decoration = DayDecoration(
      selectedDayBackgroundColor: Colors.red,
      cellSelectionAlpha: 200,
    );

    // Verifica se il giorno è un endpoint della selezione (start o end)
    final isEndpoint = daySelections.any(
      (selection) =>
          date.isSameDate(selection.start) || date.isSameDate(selection.end),
    );

    if (isSelected || isEndpoint) {
      return CalendarDayBackground.selected(
        date: date,
        selections: daySelections,
        dayDecoration: decoration,
        child: text,
      );
    }

    return CalendarDayBackground.day(
      date: date,
      selections: daySelections,
      dayDecoration: decoration,
      boxDecoration: isException
          ? BoxDecoration(border: Border.all(color: Colors.red, width: 2))
          : null,
      child: text,
    );
  }
}

extension DateTimeX on DateTime {
  bool isAfterOrToday(DateTime dateCompare) {
    return isAfter(dateCompare) || isSameDate(dateCompare);
  }

  bool isBeforeOrToday(DateTime dateCompare) {
    return isBefore(dateCompare) || isSameDate(dateCompare);
  }
}
