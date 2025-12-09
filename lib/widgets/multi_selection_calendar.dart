import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_selection_calendar/entities/calendar_decorations.dart';
import 'package:multi_selection_calendar/entities/month.dart';
import 'package:multi_selection_calendar/enums/enums.dart';
import 'package:multi_selection_calendar/notifiers/selection_notifier.dart';
import 'package:multi_selection_calendar/extensions/extensions.dart';

part 'month_calendar.dart';
part 'day_cell.dart';

class MultiSelectionCalendar extends StatefulWidget {
  const MultiSelectionCalendar({
    super.key,
    this.conflictMode = ConflictMode.override,
    this.initialSelections = const [],
    this.initMonthIndex,
    this.dayDecoration,
    this.dayBuilder,
  });

  /// Defines how to handle conflicts when selecting date ranges.
  final ConflictMode conflictMode;

  /// Initial selections to be applied to the calendar.
  final List<CalendarSelection> initialSelections;

  /// Initial month index to display (0 for January, 11 for December).
  /// If null, defaults to the current month.
  final int? initMonthIndex;

  /// Decoration for each day cell in the calendar.
  final DayDecoration? dayDecoration;

  /// Custom builder for day cells.
  /// date is the date of the cell.
  /// daySelections is the list of selections that include this date.
  final Widget? Function(DateTime date, List<CalendarSelection> daySelections)?
  dayBuilder;

  @override
  State<MultiSelectionCalendar> createState() => _MultiSelectionCalendarState();
}

class _MultiSelectionCalendarState extends State<MultiSelectionCalendar> {
  late final SelectionNotifier _selectionNotifier;

  late int initMonthIndex;

  final months = List.generate(12, (month) {
    final daysInMonth = DateTime(DateTime.now().year, month + 1, 0).day;
    return Month(List.generate(daysInMonth, (day) => day + 1));
  });

  @override
  void initState() {
    _selectionNotifier = SelectionNotifier(
      conflictMode: widget.conflictMode,
      selections: widget.initialSelections,
    );
    initMonthIndex = widget.initMonthIndex ?? DateTime.now().month - 1;
    super.initState();
  }

  @override
  void dispose() {
    _selectionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat.MMMM().format(
                    DateTime(DateTime.now().year, initMonthIndex + 1),
                  ),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        initMonthIndex--;
                      });
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        initMonthIndex++;
                      });
                    },
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ],
              ),
            ],
          ),
          _MonthCalendar(
            selectionNotifier: _selectionNotifier,
            month: months[initMonthIndex],
            dayDecoration: widget.dayDecoration ?? DayDecoration(),
            monthIndex: initMonthIndex,
            dayBuilder: widget.dayBuilder,
          ),
        ],
      ),
    );
  }
}
