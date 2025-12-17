part of '../multi_selection_calendar.dart';

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.dayDecoration,
    required this.calendarController,
    this.dayBuilder,
    this.textStyleDayBuilder,
  });

  factory _DayCell.disabled({
    required DateTime date,
    required DayDecoration dayDecoration,
  }) {
    return _DayCell(
      date: date,
      dayDecoration: dayDecoration,
      calendarController: null,
    );
  }

  final DateTime date;
  final DayDecoration dayDecoration;
  final CalendarController? calendarController;
  final Widget? Function(
    DateTime date,
    List<CalendarSelection> daySelections,
    bool isSelected,
  )?
  dayBuilder;
  final TextStyle? Function(
    DateTime date,
    List<CalendarSelection> daySelections,
    bool enabled,
  )?
  textStyleDayBuilder;

  bool get isDaySelected =>
      calendarController?.lastSelectedDay?.isSameDate(date) ?? false;

  @override
  Widget build(BuildContext context) {
    if (calendarController == null) {
      return _cell(context);
    }
    return ListenableBuilder(
      listenable: calendarController!,
      builder: (context, child) => _selectableCell(context),
    );
  }

  Widget _selectableCell(BuildContext context) {
    final overrideDay = dayBuilder?.call(
      date,
      calendarController!.getSelections(date),
      isDaySelected,
    );
    return GestureDetector(
      onTap: () {
        calendarController!.selectDay(date);
      },
      child: overrideDay ?? _cell(context),
    );
  }

  Widget _cell(BuildContext context) {
    final selections = calendarController?.getSelections(date) ?? [];

    if (isDaySelected) {
      return CalendarDayBackground.selected(
        date: date,
        selections: selections,
        dayDecoration: dayDecoration,
        child: _text(context, calendarController != null),
      );
    }

    return CalendarDayBackground.day(
      date: date,
      selections: selections,
      dayDecoration: dayDecoration,
      child: _text(context, calendarController != null),
    );
  }

  Widget _text(BuildContext context, bool enabled) {
    return Text(
      '${date.day}',
      style:
          textStyleDayBuilder?.call(
            date,
            calendarController?.getSelections(date) ?? [],
            enabled,
          ) ??
          (dayDecoration.dayTextStyle ?? Theme.of(context).textTheme.bodyLarge)
              ?.copyWith(
                color: enabled
                    ? null
                    : (dayDecoration.disabledDayBackgroundColor ??
                          Colors.grey.shade300),
              ),
    );
  }
}
