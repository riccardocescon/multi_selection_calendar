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
    required this.animationSettings,
    this.dayBuilder,
  });

  final int monthIndex;
  final int year;
  final Month? prevMonth;
  final Month? nextMonth;
  final Month month;
  final DayDecoration dayDecoration;
  final SelectionNotifier selectionNotifier;
  final Widget? Function(
    DateTime date,
    List<CalendarSelection> daySelections,
    bool isSelected,
  )?
  dayBuilder;
  final CalendarAnimationSettings animationSettings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / 7;

        return SlidingMonthView(
          animationSettings: animationSettings,
          month: DateTime(year, monthIndex),
          builder: (month) {
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

class SlidingMonthView extends StatefulWidget {
  final Widget Function(DateTime month) builder;
  final DateTime month;
  final CalendarAnimationSettings animationSettings;

  const SlidingMonthView({
    super.key,
    required this.builder,
    required this.month,
    required this.animationSettings,
  });

  @override
  State<SlidingMonthView> createState() => _SlidingMonthViewState();
}

class _SlidingMonthViewState extends State<SlidingMonthView>
    with SingleTickerProviderStateMixin {
  late DateTime _oldMonth;
  late DateTime _newMonth;
  late AnimationController _controller;
  late Animation<Offset> _incoming;
  late Animation<Offset> _outgoing;
  bool _isNext = true;

  @override
  void initState() {
    super.initState();
    _oldMonth = widget.month;
    _newMonth = widget.month;

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationSettings.duration,
    );

    _incoming = AlwaysStoppedAnimation<Offset>(Offset.zero);
    _outgoing = AlwaysStoppedAnimation<Offset>(Offset.zero);
  }

  @override
  void didUpdateWidget(covariant SlidingMonthView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.month == oldWidget.month) return;

    // Determina direzione
    _isNext = widget.month.isAfter(oldWidget.month);

    _oldMonth = oldWidget.month;
    _newMonth = widget.month;

    _prepareAnimations(directionNext: _isNext);

    _controller.forward(from: 0.0);
  }

  void _prepareAnimations({required bool directionNext}) {
    if (directionNext) {
      // next: nuovo entra da destra, vecchio esce a sinistra
      _incoming = Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.animationSettings.curve,
        ),
      );
      _outgoing = Tween(begin: Offset.zero, end: const Offset(-1, 0)).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.animationSettings.curve,
        ),
      );
    } else {
      // prev: nuovo entra da sinistra, vecchio esce a destra
      _incoming = Tween(begin: const Offset(-1, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.animationSettings.curve,
        ),
      );
      _outgoing = Tween(begin: Offset.zero, end: const Offset(1, 0)).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.animationSettings.curve,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          // Calendario entrante
          SlideTransition(
            position: _incoming,
            child: widget.builder(_newMonth),
          ),

          // Calendario uscente
          SlideTransition(
            position: _outgoing,
            child: widget.builder(_oldMonth),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
