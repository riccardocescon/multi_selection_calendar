import 'package:flutter/material.dart';
import 'package:multi_selection_calendar/controller/calendar_controller.dart';
import 'package:multi_selection_calendar/entities/calendar_decorations.dart';
import 'package:multi_selection_calendar/extensions/extensions.dart';

class CalendarDayBackground extends StatelessWidget {
  const CalendarDayBackground._({
    required this.date,
    required this.selections,
    required this.dayDecoration,
    required this.isSelected,
    required this.child,
  });

  factory CalendarDayBackground.day({
    required Widget child,
    required DateTime date,
    required List<CalendarSelection> selections,
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

  factory CalendarDayBackground.selected({
    required Widget child,
    required List<CalendarSelection> selections,
    DayDecoration dayDecoration = const DayDecoration(),
  }) {
    return CalendarDayBackground._(
      date: DateTime.now(),
      selections: selections,
      dayDecoration: dayDecoration,
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
      // Get the selected day decoration
      return [
        ...selections.map(
          (selection) => BoxDecoration(
            color: selection.color.withAlpha(dayDecoration.cellSelectionAlpha),
          ),
        ),
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

    List<BoxDecoration> backgroundDecorations = [];
    List<BoxDecoration> circleDecorations = [];

    for (final selection in selections) {
      final startMatch = date.isSameDate(selection.start);
      final endMatch = date.isSameDate(selection.end);
      final baseColor = selection.color;

      if (startMatch && endMatch) {
        backgroundDecorations.add(
          BoxDecoration(
            color: baseColor.withAlpha(dayDecoration.cellSelectionAlpha),
            borderRadius: BorderRadius.all(Radius.circular(9999)),
          ),
        );

        circleDecorations.add(
          BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.all(
              Radius.circular(dayDecoration.selectedRadius),
            ),
          ),
        );
      } else if (startMatch) {
        // START RANGE
        backgroundDecorations.add(
          BoxDecoration(
            color: baseColor.withAlpha(dayDecoration.cellSelectionAlpha),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(9999),
              bottomLeft: Radius.circular(9999),
            ),
          ),
        );

        circleDecorations.add(
          BoxDecoration(
            color: dayDecoration.selectedDayBackgroundColor ?? baseColor,
            borderRadius: BorderRadius.all(
              Radius.circular(dayDecoration.selectedRadius),
            ),
          ),
        );
      } else if (endMatch) {
        // END RANGE
        backgroundDecorations.add(
          BoxDecoration(
            color: baseColor.withAlpha(dayDecoration.cellSelectionAlpha),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(9999),
              bottomRight: Radius.circular(9999),
            ),
          ),
        );

        circleDecorations.add(
          BoxDecoration(
            color: dayDecoration.selectedDayBackgroundColor ?? baseColor,
            borderRadius: BorderRadius.all(
              Radius.circular(dayDecoration.selectedRadius),
            ),
          ),
        );
      } else if (date.isAfter(selection.start) &&
          date.isBefore(selection.end)) {
        // MIDDLE DAYS
        backgroundDecorations.add(
          BoxDecoration(
            color: baseColor.withAlpha(dayDecoration.cellSelectionAlpha),
          ),
        );
      }
    }

    return [...backgroundDecorations, ...circleDecorations];
  }
}
