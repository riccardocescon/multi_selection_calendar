import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_selection_calendar/controller/calendar_controller.dart';
import 'package:multi_selection_calendar/entities/calendar_animation_settings.dart';
import 'package:multi_selection_calendar/widgets/calendar_day_background.dart';
import 'package:multi_selection_calendar/entities/calendar_decorations.dart';
import 'package:multi_selection_calendar/entities/calendar_picker_decoration.dart';
import 'package:multi_selection_calendar/entities/header_decoration.dart';
import 'package:multi_selection_calendar/entities/month.dart';
import 'package:multi_selection_calendar/extensions/extensions.dart';

part 'components/month_calendar.dart';
part 'components/day_cell.dart';
part 'components/header.dart';
part 'components/pick_element.dart';

class MultiSelectionCalendar extends StatefulWidget {
  const MultiSelectionCalendar({
    super.key,
    required this.controller,
    this.initMonthIndex,
    this.dayDecoration,
    this.pickerDecoration,
    this.headerDecoration,
    this.minYear,
    this.maxYear,
    this.initYear,
    this.animationSettings,
    this.dayBuilder,
    this.textStyleDayBuilder,
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

  /// Controller to manage calendar selections and state.
  final CalendarController controller;

  /// Initial month index to display (0 for January, 11 for December).
  /// If null, defaults to the current month.
  final int? initMonthIndex;

  /// Decoration for each day cell in the calendar.
  final DayDecoration? dayDecoration;

  /// Decoration for the month picker.
  final CalendarPickerDecoration? pickerDecoration;

  /// Decoration for the header of the calendar.
  final HeaderDecoration? headerDecoration;

  /// Minimum year selectable in the calendar.
  final int? minYear;

  /// Maximum year selectable in the calendar.
  final int? maxYear;

  /// Initial year to display in the calendar.
  final int? initYear;

  /// Animation settings for month transitions.
  final CalendarAnimationSettings? animationSettings;

  /// Custom builder for day cells.
  /// [date] is the date of the cell.
  /// [daySelections] is the list of selections that include this date.
  /// [isSelected] indicates if the day is currently selected.
  final Widget? Function(
    DateTime date,
    List<CalendarSelection> daySelections,
    bool isSelected,
  )?
  dayBuilder;

  /// Custom text style builder for day cells.
  /// This will keep the default day cell layout but allow customizing the text style.
  /// [date] is the date of the cell.
  /// [daySelections] is the list of selections that include this date.
  /// [enabled] indicates if the day cell is part of the selected month or an offset day.
  final TextStyle? Function(
    DateTime date,
    List<CalendarSelection> daySelections,
    bool enabled,
  )?
  textStyleDayBuilder;

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
    VoidCallback? onChangeMonth,
    VoidCallback? onChangeYear,
  )?
  headerBuilder;

  @override
  State<MultiSelectionCalendar> createState() => _MultiSelectionCalendarState();
}

class _MultiSelectionCalendarState extends State<MultiSelectionCalendar> {
  late int monthIndex;
  late int minYear = widget.minYear ?? DateTime.now().year - 5;
  late int maxYear = widget.maxYear ?? DateTime.now().year + 5;
  late int selectedYear = widget.initYear ?? DateTime.now().year;

  _PageView _currentPageView = _PageView.days;

  List<Month> get months => List.generate(12, (month) {
    final daysInMonth = DateTime(selectedYear, month + 2, 0).day;
    return Month(List.generate(daysInMonth, (day) => day + 1));
  });

  bool get enablePrevMonth => monthIndex > 0 || selectedYear > minYear;
  bool get enableNextMonth => monthIndex < 12 && selectedYear < maxYear;

  @override
  void initState() {
    monthIndex = widget.initMonthIndex ?? DateTime.now().month - 1;
    super.initState();
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

    final calendarDecoration =
        widget.pickerDecoration ?? CalendarPickerDecoration();

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          _header(),

          Stack(
            alignment: Alignment.center,
            children: [
              _MonthCalendar(
                calendarController: widget.controller,
                month: months[monthIndex],
                dayDecoration: widget.dayDecoration ?? DayDecoration(),
                monthIndex: monthIndex,
                dayBuilder: widget.dayBuilder,
                textStyleDayBuilder: widget.textStyleDayBuilder,
                year: selectedYear,
                prevMonth: prevMonth,
                nextMonth: nextMonth,
                animationSettings:
                    widget.animationSettings ?? CalendarAnimationSettings(),
              ),

              if (_currentPageView == _PageView.months)
                Positioned.fill(
                  child: _PickElement(
                    itemCount: 12,
                    itemBuilder: (index) {
                      final isSelected = index == monthIndex;
                      return Text(
                        DateFormat.MMMM().format(DateTime(2000, index + 1)),
                        style:
                            calendarDecoration.textStyle ??
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isSelected ? Colors.white : null,
                            ),
                      );
                    },
                    elementIndex: monthIndex,
                    decoration:
                        widget.pickerDecoration ?? CalendarPickerDecoration(),
                    onElementPicked: (elementIndex) {
                      setState(() {
                        monthIndex = elementIndex;
                        _currentPageView = _PageView.days;
                      });
                    },
                  ),
                ),

              if (_currentPageView == _PageView.years)
                Positioned.fill(
                  child: _PickElement(
                    itemCount: maxYear - minYear + 20,
                    itemBuilder: (index) {
                      final year = minYear + index;
                      final isSelected = year == selectedYear;
                      final isInRange = year >= minYear && year <= maxYear;

                      final textStyle =
                          calendarDecoration.textStyle ??
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isSelected ? Colors.white : null,
                          );
                      return Text(
                        DateFormat.y().format(DateTime(year, 1)),
                        style: textStyle?.copyWith(
                          color: isInRange
                              ? textStyle.color
                              : textStyle.color?.withAlpha(80),
                        ),
                      );
                    },
                    enabled: (index) =>
                        (minYear + index) >= minYear &&
                        (minYear + index) <= maxYear,
                    elementIndex: selectedYear - minYear,
                    decoration:
                        widget.pickerDecoration ?? CalendarPickerDecoration(),
                    onElementPicked: (elementIndex) {
                      setState(() {
                        selectedYear = minYear + elementIndex;
                        _currentPageView = _PageView.days;
                      });
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final customHeader = widget.headerBuilder?.call(
      selectedYear,
      monthIndex,
      enableNextMonth ? _loadNextMonth : null,
      enablePrevMonth ? _loadPrevMonth : null,
      _loadNewYear,
      _changeMonth,
      _changeYear,
    );

    return customHeader ??
        _Header(
          selectedYear: selectedYear,
          monthIndex: monthIndex,
          minYear: minYear,
          maxYear: maxYear,
          enablePrevMonth: enablePrevMonth,
          enableNextMonth: enableNextMonth,
          loadPrevMonth: _loadPrevMonth,
          loadNextMonth: _loadNextMonth,
          loadNewYear: _loadNewYear,
          onChangeMonth: _changeMonth,
          onChangeYear: _changeYear,
          decoration: widget.headerDecoration ?? HeaderDecoration(),
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

  void _changeMonth() {
    if (_currentPageView == _PageView.months) {
      setState(() {
        _currentPageView = _PageView.days;
      });
      return;
    }

    setState(() {
      _currentPageView = _PageView.months;
    });
  }

  void _changeYear() {
    if (_currentPageView == _PageView.years) {
      setState(() {
        _currentPageView = _PageView.days;
      });
      return;
    }

    setState(() {
      _currentPageView = _PageView.years;
    });
  }
}

enum _PageView { days, months, years }
