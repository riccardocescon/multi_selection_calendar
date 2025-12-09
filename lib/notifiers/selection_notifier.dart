import 'package:flutter/material.dart';
import 'package:multi_selection_calendar/enums/enums.dart';
import 'package:multi_selection_calendar/extensions/extensions.dart';

class CalendarSelection {
  final DateTime start;
  final DateTime end;
  final Color color;

  const CalendarSelection({
    required this.start,
    required this.end,
    required this.color,
  });
}

class SelectionNotifier extends ChangeNotifier {
  late final _selections = <CalendarSelection>[];
  DateTime? _lastSelectedDay;
  final ConflictMode conflictMode;
  late Color _nextColor;
  final void Function(CalendarSelection selection)? onSelectionAdded;

  SelectionNotifier({
    required this.conflictMode,
    this.onSelectionAdded,
    List<CalendarSelection> selections = const [],
  }) {
    _selections.addAll(selections);
    _nextColor = Colors.blue;
    notifyListeners();
  }

  // Utils
  bool _isDateinRange(DateTime day, CalendarSelection selection) {
    return (day.isAfter(selection.start) && day.isBefore(selection.end)) ||
        day.isSameDate(selection.start) ||
        day.isSameDate(selection.end);
  }

  // Setters
  void setSelectionColor(Color newColor) => _nextColor = newColor;

  void selectDay(DateTime day) {
    if (_lastSelectedDay == null) {
      _lastSelectedDay = day;
      if (conflictMode == ConflictMode.override) {
        _selections.removeWhere((selection) => _isDateinRange(day, selection));
      }
    } else if (day.isSameDate(_lastSelectedDay!)) {
      _lastSelectedDay = null;
    } else {
      final minDay = day.isBefore(_lastSelectedDay!) ? day : _lastSelectedDay!;
      final maxDay = day.isAfter(_lastSelectedDay!) ? day : _lastSelectedDay!;
      CalendarSelection calendarSelection = CalendarSelection(
        start: minDay,
        end: maxDay,
        color: _nextColor,
      );

      if (conflictMode == ConflictMode.override) {
        _selections.removeWhere((selection) {
          if (_isDateinRange(minDay, selection)) return true;
          if (_isDateinRange(maxDay, selection)) return true;

          if (_isDateinRange(selection.start, calendarSelection)) return true;
          if (_isDateinRange(selection.end, calendarSelection)) return true;

          return false;
        });
      } else if (conflictMode == ConflictMode.merge) {
        final overlappingSelections = _selections.where((selection) {
          if (_isDateinRange(minDay, selection)) return true;
          if (_isDateinRange(maxDay, selection)) return true;

          if (_isDateinRange(selection.start, calendarSelection)) return true;
          if (_isDateinRange(selection.end, calendarSelection)) return true;

          return false;
        }).toList();

        if (overlappingSelections.isNotEmpty) {
          DateTime mergedStart = calendarSelection.start;
          DateTime mergedEnd = calendarSelection.end;

          for (final selection in overlappingSelections) {
            if (selection.start.isBefore(mergedStart)) {
              mergedStart = selection.start;
            }
            if (selection.end.isAfter(mergedEnd)) {
              mergedEnd = selection.end;
            }
          }

          // Remove overlapping selections
          _selections.removeWhere(
            (selection) => overlappingSelections.contains(selection),
          );

          // Create new merged selection
          calendarSelection = CalendarSelection(
            start: mergedStart,
            end: mergedEnd,
            color: _nextColor,
          );
        }
      }

      _selections.add(calendarSelection);
      _lastSelectedDay = null;
      onSelectionAdded?.call(calendarSelection);
    }

    notifyListeners();
  }

  void removeSelection(CalendarSelection selection) {
    _selections.remove(selection);
    notifyListeners();
  }

  void clearSelections() {
    _selections.clear();
    _lastSelectedDay = null;
    notifyListeners();
  }

  // Getters
  DateTime? get lastSelectedDay => _lastSelectedDay;

  List<CalendarSelection> getSelections(DateTime day) {
    return _selections
        .where((selection) => _isDateinRange(day, selection))
        .toList();
  }
}
