part of 'multi_selection_calendar.dart';

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.dayDecoration,
    required this.selectionNotifier,
    this.dayBuilder,
  });

  final DateTime date;
  final DayDecoration dayDecoration;
  final SelectionNotifier selectionNotifier;
  final Widget? Function(DateTime date, List<CalendarSelection> daySelections)?
  dayBuilder;

  @override
  Widget build(BuildContext context) {
    final overrideDay = dayBuilder?.call(
      date,
      selectionNotifier.getSelections(date),
    );

    return ListenableBuilder(
      listenable: selectionNotifier,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            selectionNotifier.selectDay(date);
          },
          child:
              overrideDay ??
              Stack(
                children: _buildSelectionDecoration.map((e) {
                  return Container(
                    decoration: e,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(
                      vertical: dayDecoration.verticalMargin,
                    ),
                    child: Text(
                      '${date.day}',
                      style:
                          dayDecoration.dayTextStyle ??
                          Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }).toList(),
              ),
        );
      },
    );
  }

  List<BoxDecoration> get _buildSelectionDecoration {
    final isDaySelected =
        selectionNotifier.lastSelectedDay?.isSameDate(date) ?? false;

    if (isDaySelected) {
      return [
        BoxDecoration(
          color: dayDecoration.selectedDayBackgroundColor ?? Colors.blue,
          borderRadius: BorderRadius.all(
            Radius.circular(dayDecoration.selectedRadius),
          ),
        ),
      ];
    }

    final selections = selectionNotifier.getSelections(date);
    if (selections.isEmpty) {
      return [
        BoxDecoration(
          color: dayDecoration.cellBackgroundColor ?? Colors.transparent,
        ),
      ];
    }

    List<BoxDecoration> decorations = [];

    for (final selection in selections) {
      Color? selectionColor;
      BorderRadius? borderRadius;

      if (date.isSameDate(selection.start)) {
        selectionColor = selection.color;

        if (date.isSameDate(selection.end)) {
          // Single day selection
          borderRadius = BorderRadius.all(
            Radius.circular(dayDecoration.selectedRadius),
          );
        } else {
          // Start of selection
          borderRadius = BorderRadius.only(
            topLeft: Radius.circular(dayDecoration.selectedRadius),
            bottomLeft: Radius.circular(dayDecoration.selectedRadius),
          );
        }
      } else if (date.isSameDate(selection.end)) {
        selectionColor = selection.color;

        // End of selection
        borderRadius = BorderRadius.only(
          topRight: Radius.circular(dayDecoration.selectedRadius),
          bottomRight: Radius.circular(dayDecoration.selectedRadius),
        );
      } else if (date.isAfter(selection.start) &&
          date.isBefore(selection.end)) {
        selectionColor = selection.color.withAlpha(
          dayDecoration.cellSelectionAlpha,
        );
        // No border radius for middle days
        borderRadius = null;
      }

      if (selectionColor != null) {
        decorations.add(
          BoxDecoration(color: selectionColor, borderRadius: borderRadius),
        );
      }
    }

    return decorations;
  }
}
