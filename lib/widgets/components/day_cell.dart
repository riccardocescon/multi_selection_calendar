part of '../multi_selection_calendar.dart';

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.dayDecoration,
    required this.selectionNotifier,
    this.dayBuilder,
  });

  factory _DayCell.disabled({
    required DateTime date,
    required DayDecoration dayDecoration,
  }) {
    return _DayCell(
      date: date,
      dayDecoration: dayDecoration,
      selectionNotifier: null,
    );
  }

  final DateTime date;
  final DayDecoration dayDecoration;
  final SelectionNotifier? selectionNotifier;
  final Widget? Function(
    DateTime date,
    List<CalendarSelection> daySelections,
    bool isSelected,
  )?
  dayBuilder;

  bool get isDaySelected =>
      selectionNotifier?.lastSelectedDay?.isSameDate(date) ?? false;

  @override
  Widget build(BuildContext context) {
    if (selectionNotifier == null) {
      return _cell(context);
    }
    return ListenableBuilder(
      listenable: selectionNotifier!,
      builder: (context, child) => _selectableCell(context),
    );
  }

  Widget _selectableCell(BuildContext context) {
    final overrideDay = dayBuilder?.call(
      date,
      selectionNotifier!.getSelections(date),
      isDaySelected,
    );
    return GestureDetector(
      onTap: () {
        selectionNotifier!.selectDay(date);
      },
      child: overrideDay ?? _cell(context),
    );
  }

  Widget _cell(BuildContext context) {
    if (isDaySelected) {
      return CalendarDayBackground.selected(
        child: _text(context, selectionNotifier != null),
      );
    }

    return CalendarDayBackground.day(
      date: date,
      selections: selectionNotifier?.getSelections(date) ?? [],
      dayDecoration: dayDecoration,
      child: _text(context, selectionNotifier != null),
    );
  }

  Widget _text(BuildContext context, bool enabled) {
    return Text(
      '${date.day}',
      style:
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
