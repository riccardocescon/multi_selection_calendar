part of 'multi_selection_calendar.dart';

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.monthIndex,
    required this.month,
    required this.dayDecoration,
    required this.selectionNotifier,
    this.dayBuilder,
  });

  final int monthIndex;
  final Month month;
  final DayDecoration dayDecoration;
  final SelectionNotifier selectionNotifier;
  final Widget? Function(DateTime date, List<CalendarSelection> daySelections)?
  dayBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / 7;
        return Wrap(
          children: month.days.map((day) {
            return SizedBox(
              width: itemWidth,
              height: itemWidth,
              child: _DayCell(
                date: DateTime(DateTime.now().year, monthIndex + 1, day),
                dayDecoration: dayDecoration,
                selectionNotifier: selectionNotifier,
                dayBuilder: dayBuilder,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
