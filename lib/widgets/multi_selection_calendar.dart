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
    this.onSelectionAdded,
    this.minYear,
    this.maxYear,
    this.initYear,
    this.dayBuilder,
  }) : assert(
         initMonthIndex == null ||
             (initMonthIndex >= 0 && initMonthIndex <= 11),
         'initMonthIndex must be between 0 and 11',
       ),
       assert(
         minYear == null || maxYear == null || minYear <= maxYear,
         'minYear must be less than or equal to maxYear',
       ),
       assert(
         initYear == null ||
             (minYear == null || initYear >= minYear) &&
                 (maxYear == null || initYear <= maxYear),
         'initYear must be between minYear and maxYear',
       );

  /// Defines how to handle conflicts when selecting date ranges.
  final ConflictMode conflictMode;

  /// Initial selections to be applied to the calendar.
  final List<CalendarSelection> initialSelections;

  /// Initial month index to display (0 for January, 11 for December).
  /// If null, defaults to the current month.
  final int? initMonthIndex;

  /// Decoration for each day cell in the calendar.
  final DayDecoration? dayDecoration;

  /// Callback when a new selection is added.
  final void Function(CalendarSelection selection)? onSelectionAdded;

  /// Minimum year selectable in the calendar.
  final int? minYear;

  /// Maximum year selectable in the calendar.
  final int? maxYear;

  /// Initial year to display in the calendar.
  final int? initYear;

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
  late int minYear = widget.minYear ?? DateTime.now().year - 5;
  late int maxYear = widget.maxYear ?? DateTime.now().year + 5;
  late int selectedYear = widget.initYear ?? DateTime.now().year;

  List<Month> get months => List.generate(12, (month) {
    final daysInMonth = DateTime(selectedYear, month + 2, 0).day;
    return Month(List.generate(daysInMonth, (day) => day + 1));
  });

  @override
  void initState() {
    _selectionNotifier = SelectionNotifier(
      conflictMode: widget.conflictMode,
      selections: widget.initialSelections,
      onSelectionAdded: widget.onSelectionAdded,
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
    Month? prevMonth = initMonthIndex > 0 ? months[initMonthIndex - 1] : null;
    if (prevMonth == null) {
      // last month of the prev year if applicable
      if (selectedYear > minYear) {
        prevMonth = Month(
          List.generate(
            DateTime(selectedYear - 1, 12, 0).day,
            (day) => day + 1,
          ),
        );
      }
    }

    Month? nextMonth = initMonthIndex < 11 ? months[initMonthIndex + 1] : null;
    if (nextMonth == null) {
      // first month of the next year if applicable
      if (selectedYear < maxYear) {
        nextMonth = Month(
          List.generate(DateTime(selectedYear + 1, 1, 0).day, (day) => day + 1),
        );
      }
    }

    final enablePrevMonth = initMonthIndex > 0 || selectedYear > minYear;
    final enableNextMonth = initMonthIndex < 12 && selectedYear < maxYear;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  spacing: 16,
                  children: [
                    Text(
                      DateFormat.MMMM().format(
                        DateTime(DateTime.now().year, initMonthIndex + 1),
                      ),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    DropdownButton(
                      underline: const SizedBox.shrink(),
                      items: List.generate(maxYear - minYear, (relativeYear) {
                        final year = minYear + relativeYear;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (newYear) {
                        if (newYear != null) {
                          setState(() {
                            selectedYear = newYear;
                          });
                        }
                      },
                      value: selectedYear,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: enablePrevMonth
                        ? () {
                            setState(() {
                              if (initMonthIndex == 0) {
                                initMonthIndex = 11;
                                if (enablePrevMonth) {
                                  selectedYear--;
                                }
                              } else {
                                initMonthIndex--;
                              }
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  IconButton(
                    onPressed: enableNextMonth
                        ? () {
                            setState(() {
                              if (initMonthIndex == 11) {
                                initMonthIndex = 0;
                                if (enableNextMonth) {
                                  selectedYear++;
                                }
                              } else {
                                initMonthIndex++;
                              }
                            });
                          }
                        : null,
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
            year: selectedYear,
            prevMonth: prevMonth,
            nextMonth: nextMonth,
          ),
        ],
      ),
    );
  }
}
