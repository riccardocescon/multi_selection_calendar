part of '../multi_selection_calendar.dart';

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.monthIndex,
    required this.year,
    required this.month,
    required this.prevMonth,
    required this.nextMonth,
    required this.dayDecoration,
    required this.selectionNotifier,
    this.dayBuilder,
  });

  final int monthIndex;
  final int year;
  final Month? prevMonth;
  final Month? nextMonth;
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
          children: [
            ..._weekdayHeaders(context, itemWidth),
            ..._offsetPrevDays(itemWidth),
            ..._days(itemWidth),
            ..._offsetNextDays(itemWidth),
          ],
        );
      },
    );
  }

  List<Widget> _weekdayHeaders(BuildContext context, double itemWidth) {
    return List.generate(7, (index) {
      final weekday = DateFormat.E().format(DateTime(2024, 1, 1 + index));
      return SizedBox(
        width: itemWidth,
        height: itemWidth * 0.6,
        child: Center(
          child: Text(
            weekday,
            style:
                dayDecoration.dayTextStyle ??
                Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    });
  }

  List<Widget> _offsetPrevDays(double itemWidth) {
    final monthOffset = (DateTime(year, monthIndex + 1, 1).weekday + 6) % 7;
    if (monthOffset == 0) return [];
    final prevDays = prevMonth?.days.reversed.take(monthOffset).toList();
    return List.generate(monthOffset, (index) {
      return SizedBox(
        width: itemWidth,
        height: itemWidth,
        child: prevDays == null
            ? null
            : _DayCell.disabled(
                date: DateTime(
                  year,
                  monthIndex,
                  prevDays[prevDays.length - 1 - index],
                ),
                dayDecoration: dayDecoration,
              ),
      );
    });
  }

  List<Widget> _offsetNextDays(double itemWidth) {
    final totalCells =
        ((month.days.length +
                    (DateTime(year, monthIndex + 1, 1).weekday % 7) -
                    1) /
                7)
            .ceil() *
        7;
    final nextDaysCount =
        totalCells -
        month.days.length -
        ((DateTime(year, monthIndex + 1, 1).weekday % 7) - 1);
    if (nextDaysCount == 0) return [];

    final nextDays = nextMonth?.days.take(nextDaysCount).toList();
    return List.generate(nextDaysCount, (index) {
      return SizedBox(
        width: itemWidth,
        height: itemWidth,
        child: nextDays == null
            ? null
            : _DayCell.disabled(
                date: DateTime(year, monthIndex + 2, nextDays[index]),
                dayDecoration: dayDecoration,
              ),
      );
    });
  }

  List<Widget> _days(double itemWidth) {
    return List.generate(month.days.length, (index) {
      final day = month.days[index];
      return SizedBox(
        width: itemWidth,
        height: itemWidth,
        child: _DayCell(
          date: DateTime(year, monthIndex + 1, day),
          dayDecoration: dayDecoration,
          selectionNotifier: selectionNotifier,
          dayBuilder: dayBuilder,
        ),
      );
    });
  }
}
