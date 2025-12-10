import 'package:flutter/material.dart';
import 'package:multi_selection_calendar/entities/calendar_decorations.dart';
import 'package:multi_selection_calendar/extensions/extensions.dart';
import 'package:multi_selection_calendar/notifiers/selection_notifier.dart';

class CalendarDayBackground extends StatelessWidget {
  const CalendarDayBackground._({
    required this.date,
    required this.selections,
    required this.dayDecoration,
    required this.isSelected,
    required this.child,
  });

  factory CalendarDayBackground.day({
    required DateTime date,
    required List<CalendarSelection> selections,
    required Widget child,
    DayDecoration dayDecoration = const DayDecoration(),
  }) {
    return CalendarDayBackground._(
      date: date,
      selections: selections,
      dayDecoration: dayDecoration,
      isSelected: false,
      child: child,
    );
  }

  factory CalendarDayBackground.selected({required Widget child}) {
    return CalendarDayBackground._(
      date: DateTime.now(),
      selections: [],
      dayDecoration: const DayDecoration(),
      isSelected: true,
      child: child,
    );
  }

  final DateTime date;
  final List<CalendarSelection> selections;
  final DayDecoration dayDecoration;
  final bool isSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _buildSelectionDecoration
          .map((decoration) => _cell(context, decoration))
          .toList(),
    );
  }

  Widget _cell(BuildContext context, Decoration? decoration) {
    return Container(
      decoration: decoration,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: dayDecoration.verticalMargin),
      child: child,
    );
  }

  List<BoxDecoration> get _buildSelectionDecoration {
    if (isSelected) {
      return [
        BoxDecoration(
          color: dayDecoration.selectedDayBackgroundColor ?? Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(9999)),
        ),
      ];
    }

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
