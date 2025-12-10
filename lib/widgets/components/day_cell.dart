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
  final Widget? Function(DateTime date, List<CalendarSelection> daySelections)?
  dayBuilder;

  @override
  Widget build(BuildContext context) {
    if (selectionNotifier == null) {
      return _cell(context, null);
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
    );
    return GestureDetector(
      onTap: () {
        selectionNotifier!.selectDay(date);
      },
      child:
          overrideDay ??
          Stack(
            children: _buildSelectionDecoration
                .map((decoration) => _cell(context, decoration))
                .toList(),
          ),
    );
  }

  Widget _cell(BuildContext context, Decoration? e) {
    return Container(
      decoration: e,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: dayDecoration.verticalMargin),
      child: Text(
        '${date.day}',
        style:
            (dayDecoration.dayTextStyle ??
                    Theme.of(context).textTheme.bodyLarge)
                ?.copyWith(
                  color: e == null
                      ? (dayDecoration.disabledDayBackgroundColor ??
                            Colors.grey.shade300)
                      : null,
                ),
      ),
    );
  }

  List<BoxDecoration> get _buildSelectionDecoration {
    final isDaySelected =
        selectionNotifier!.lastSelectedDay?.isSameDate(date) ?? false;

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

    final selections = selectionNotifier!.getSelections(date);
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
          final backgroundBorder = BorderRadius.only(
            topLeft: Radius.circular(9999),
            bottomLeft: Radius.circular(9999),
          );
          borderRadius = BorderRadius.all(Radius.circular(9999));
          decorations.add(
            BoxDecoration(
              color: selectionColor.withAlpha(dayDecoration.cellSelectionAlpha),
              borderRadius: backgroundBorder,
            ),
          );
        }
      } else if (date.isSameDate(selection.end)) {
        selectionColor = selection.color;

        final backgroundBorder = BorderRadius.only(
          topRight: Radius.circular(9999),
          bottomRight: Radius.circular(9999),
        );
        borderRadius = BorderRadius.all(Radius.circular(9999));
        decorations.add(
          BoxDecoration(
            color: selectionColor.withAlpha(dayDecoration.cellSelectionAlpha),
            borderRadius: backgroundBorder,
          ),
        );
      } else if (date.isAfter(selection.start) &&
          date.isBefore(selection.end)) {
        selectionColor = selection.color.withAlpha(
          dayDecoration.cellSelectionAlpha,
        );

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
