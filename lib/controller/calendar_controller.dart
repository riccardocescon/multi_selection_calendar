import 'package:flutter/material.dart';
import 'package:multi_selection_calendar/enums/enums.dart';
import 'package:multi_selection_calendar/extensions/extensions.dart';

class CalendarController extends ChangeNotifier {
  late _SelectionHandler _selectionHandler;

  CalendarController({
    required ConflictMode conflictMode,
    void Function(CalendarSelection selection)? onSelectionAdded,
    void Function(DateTime day)? onSelectDay,
    List<CalendarSelection> initialSelections = const [],
    SelectionSettings? selectionSettings,
    TapSettings? tapSettings,
    Color initColor = Colors.blue,
    DateTime? selectedDay,
  }) {
    _selectionHandler = _SelectionHandler(
      conflictMode: conflictMode,
      initialColor: initColor,
      onSelectionAdded: onSelectionAdded,
      onSelectDay: onSelectDay,
      selections: initialSelections,
      selectionSettings: selectionSettings,
      tapSettings: tapSettings,
      selectedDay: selectedDay,
    );
    notifyListeners();
  }

  /// All the selections made in the calendar.
  /// NOTE: This list is unmodifiable.
  List<CalendarSelection> get selections => _selectionHandler.allSelections;

  /// The color that will be used for the next selection.
  Color get nextColor => _selectionHandler.nextColor;

  /// Set the color for the next selection.
  void setNextColor(Color color) => _selectionHandler.setSelectionColor(color);

  /// The last selected day in the calendar.
  /// If null, no day is currently selected.
  DateTime? get lastSelectedDay => _selectionHandler.lastSelectedDay;

  /// Select a day in the calendar.
  void selectDay(DateTime date) {
    _selectionHandler.selectDay(date);
    notifyListeners();
  }

  /// Remove a selection from the calendar.
  void removeSelection(CalendarSelection selection) {
    _selectionHandler.removeSelection(selection);
    notifyListeners();
  }

  /// Get all selections that include the given [date].
  List<CalendarSelection> getSelections(DateTime date) =>
      _selectionHandler.getSelections(date);

  /// Clear all selections in the calendar.
  void clearSelections() {
    _selectionHandler.clearSelections();
    notifyListeners();
  }
}

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

class SelectionSettings {
  /// Will trigger [selectionConflictMode] when the max selection count is reached.
  final int maxSelectionCount;

  /// Defines how to handle conflicts when the max selection count is reached.
  /// Defaults to [SelectionConflictMode.block].
  /// - block: New selections that would exceed the max count are ignored.
  /// - fifo: The oldest selection is removed to make room for the new selection.
  final SelectionConflictMode selectionConflictMode;

  const SelectionSettings({
    this.maxSelectionCount = 1,
    this.selectionConflictMode = SelectionConflictMode.block,
  });
}

class TapSettings {
  /// Whether a tap should select a single day.
  final bool enableTapSelection;

  /// Whether a tap should select a range of days.
  final bool enableRangeSelection;

  const TapSettings({
    this.enableTapSelection = true,
    this.enableRangeSelection = true,
  });
}

class _SelectionHandler {
  late final _selections = <CalendarSelection>[];
  DateTime? _lastSelectedDay;
  final ConflictMode conflictMode;
  late Color _nextColor;
  final void Function(CalendarSelection selection)? onSelectionAdded;
  final void Function(DateTime day)? onSelectDay;
  late final SelectionSettings? _selectionSettings;
  late final TapSettings? _tapSettings;

  List<CalendarSelection> get allSelections => List.unmodifiable(_selections);
  Color get nextColor => _nextColor;

  _SelectionHandler({
    required this.conflictMode,
    required Color initialColor,
    this.onSelectionAdded,
    this.onSelectDay,
    List<CalendarSelection> selections = const [],
    SelectionSettings? selectionSettings,
    TapSettings? tapSettings,
    DateTime? selectedDay,
  }) {
    _selections.addAll(selections);
    _nextColor = initialColor;
    _selectionSettings = selectionSettings;
    _tapSettings = tapSettings;
    _lastSelectedDay = selectedDay;
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
    if (_tapSettings?.enableTapSelection == false) return;

    if (_lastSelectedDay != null && day.isSameDate(_lastSelectedDay!)) {
      _lastSelectedDay = null;
      onSelectDay?.call(day);
      return;
    }

    if (_tapSettings?.enableRangeSelection == false) {
      _lastSelectedDay = null;
    }

    if (_lastSelectedDay == null) {
      final maxSizeReached =
          _selectionSettings != null &&
          _selections.length >= _selectionSettings.maxSelectionCount;

      if (maxSizeReached) {
        // Max selection count reached, handle according to conflict mode
        if (_selectionSettings.selectionConflictMode ==
            SelectionConflictMode.block) {
          return;
        }

        if (_selectionSettings.selectionConflictMode ==
            SelectionConflictMode.fifo) {
          _selections.removeAt(0);
        }
      }

      _lastSelectedDay = day;
      if (conflictMode == ConflictMode.override) {
        _selections.removeWhere((selection) => _isDateinRange(day, selection));
      }

      onSelectDay?.call(day);
      return;
    }

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

  void removeSelection(CalendarSelection selection) {
    _selections.remove(selection);
  }

  void clearSelections() {
    _selections.clear();
    _lastSelectedDay = null;
  }

  // Getters
  DateTime? get lastSelectedDay => _lastSelectedDay;

  List<CalendarSelection> getSelections(DateTime day) {
    return _selections
        .where((selection) => _isDateinRange(day, selection))
        .toList();
  }
}
