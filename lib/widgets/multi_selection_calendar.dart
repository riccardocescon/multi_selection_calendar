import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_selection_calendar/entities/calendar_decorations.dart';
import 'package:multi_selection_calendar/entities/month.dart';
import 'package:multi_selection_calendar/enums/enums.dart';
import 'package:multi_selection_calendar/notifiers/selection_notifier.dart';
import 'package:multi_selection_calendar/extensions/extensions.dart';

part 'components/month_calendar.dart';
part 'components/day_cell.dart';

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
    this.selectionSettings,
    this.headerBuilder,
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

  /// Creates a [MultiSelectionCalendar] that allows only a single selection.
  factory MultiSelectionCalendar.single({
    Key? key,
    CalendarSelection? initialSelection,
    int? initMonthIndex,
    DayDecoration? dayDecoration,
    void Function(CalendarSelection selection)? onSelectionAdded,
    int? minYear,
    int? maxYear,
    int? initYear,
    Widget? Function(DateTime date, List<CalendarSelection> daySelections)?
    dayBuilder,
    Widget? Function(
      int selectedYear,
      int selectedMonthIndex,
      VoidCallback? onLoadNextMonth,
      VoidCallback? onLoadPrevMonth,
      void Function(int year) onLoadNewYear,
    )?
    headerBuilder,
  }) {
    return MultiSelectionCalendar(
      conflictMode: ConflictMode.override,
      initialSelections: initialSelection != null ? [initialSelection] : [],
      initMonthIndex: initMonthIndex,
      dayDecoration: dayDecoration,
      onSelectionAdded: onSelectionAdded,
      minYear: minYear,
      maxYear: maxYear,
      initYear: initYear,
      dayBuilder: dayBuilder,
      headerBuilder: headerBuilder,
      selectionSettings: SelectionSettings(
        maxSelectionCount: 1,
        selectionConflictMode: SelectionConflictMode.fifo,
      ),
    );
  }

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

  /// Selection settings for the calendar.
  final SelectionSettings? selectionSettings;

  /// Custom builder for day cells.
  /// date is the date of the cell.
  /// daySelections is the list of selections that include this date.
  final Widget? Function(DateTime date, List<CalendarSelection> daySelections)?
  dayBuilder;

  /// Custom header builder for the calendar.
  /// [onLoadNextMonth] is called when the user wants to load the next month,
  /// if null the next month button should be disabled.
  /// [onLoadPrevMonth] is called when the user wants to load the previous month,
  /// if null the previous month button should be disabled.
  /// [onLoadNewYear] is called when the user selects a new year.
  final Widget? Function(
    int selectedYear,
    int selectedMonthIndex,
    VoidCallback? onLoadNextMonth,
    VoidCallback? onLoadPrevMonth,
    void Function(int year) onLoadNewYear,
  )?
  headerBuilder;

  @override
  State<MultiSelectionCalendar> createState() => _MultiSelectionCalendarState();
}

class _MultiSelectionCalendarState extends State<MultiSelectionCalendar> {
  late final SelectionNotifier _selectionNotifier;

  late int monthIndex;
  late int minYear = widget.minYear ?? DateTime.now().year - 5;
  late int maxYear = widget.maxYear ?? DateTime.now().year + 5;
  late int selectedYear = widget.initYear ?? DateTime.now().year;

  List<Month> get months => List.generate(12, (month) {
    final daysInMonth = DateTime(selectedYear, month + 2, 0).day;
    return Month(List.generate(daysInMonth, (day) => day + 1));
  });

  bool get enablePrevMonth => monthIndex > 0 || selectedYear > minYear;
  bool get enableNextMonth => monthIndex < 12 && selectedYear < maxYear;

  @override
  void initState() {
    _selectionNotifier = SelectionNotifier(
      conflictMode: widget.conflictMode,
      selections: widget.initialSelections,
      onSelectionAdded: widget.onSelectionAdded,
      selectionSettings: widget.selectionSettings,
    );
    monthIndex = widget.initMonthIndex ?? DateTime.now().month - 1;
    super.initState();
  }

  @override
  void dispose() {
    _selectionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Month? prevMonth = monthIndex > 0 ? months[monthIndex - 1] : null;
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

    Month? nextMonth = monthIndex < 11 ? months[monthIndex + 1] : null;
    if (nextMonth == null) {
      // first month of the next year if applicable
      if (selectedYear < maxYear) {
        nextMonth = Month(
          List.generate(DateTime(selectedYear + 1, 1, 0).day, (day) => day + 1),
        );
      }
    }

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          widget.headerBuilder?.call(
                selectedYear,
                monthIndex,
                enableNextMonth ? _loadNextMonth : null,
                enablePrevMonth ? _loadPrevMonth : null,
                _loadNewYear,
              ) ??
              _header(),
          _MonthCalendar(
            selectionNotifier: _selectionNotifier,
            month: months[monthIndex],
            dayDecoration: widget.dayDecoration ?? DayDecoration(),
            monthIndex: monthIndex,
            dayBuilder: widget.dayBuilder,
            year: selectedYear,
            prevMonth: prevMonth,
            nextMonth: nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: 16,
            children: [
              Text(
                DateFormat.MMMM().format(
                  DateTime(DateTime.now().year, monthIndex + 1),
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
                  if (newYear == null) return;

                  _loadNewYear(newYear);
                },
                value: selectedYear,
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: enablePrevMonth ? _loadPrevMonth : null,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            IconButton(
              onPressed: enableNextMonth ? _loadNextMonth : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),
      ],
    );
  }

  void _loadPrevMonth() {
    if (!enablePrevMonth) return;

    setState(() {
      if (monthIndex == 0) {
        monthIndex = 11;
        if (enablePrevMonth) {
          selectedYear--;
        }
      } else {
        monthIndex--;
      }
    });
  }

  void _loadNextMonth() {
    if (!enableNextMonth) return;

    setState(() {
      if (monthIndex == 11) {
        monthIndex = 0;
        if (enableNextMonth) {
          selectedYear++;
        }
      } else {
        monthIndex++;
      }
    });
  }

  void _loadNewYear(int year) {
    if (year < minYear || year > maxYear) return;

    setState(() {
      selectedYear = year;
    });
  }
}
