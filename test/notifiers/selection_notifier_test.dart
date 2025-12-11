import 'package:flutter_test/flutter_test.dart';
import 'package:multi_selection_calendar/controller/calendar_controller.dart';
import 'package:multi_selection_calendar/enums/enums.dart';

void main() {
  group('Selection Notifier', () {
    group("Base Functionalities", () {
      test('Insert Date', () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        calendarController.selectDay(date1);
        expect(calendarController.lastSelectedDay, date1);

        calendarController.selectDay(date2);
        final selections = calendarController.getSelections(
          DateTime(2024, 6, 12),
        );
        expect(selections.length, 1);

        final selection = selections.first;
        expect(selection.start, date1);
        expect(selection.end, date2);

        expect(calendarController.lastSelectedDay, isNull);

        calendarController.dispose();
      });

      test('Clear dates', () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);
        final date3 = DateTime(2024, 6, 20);

        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        var selections = calendarController.getSelections(date1);
        expect(selections.length, 1);

        calendarController.selectDay(date3);

        expect(calendarController.lastSelectedDay, date3);

        calendarController.clearSelections();
        expect(calendarController.getSelections(date1).length, 0);
        expect(calendarController.getSelections(date2).length, 0);
        expect(calendarController.getSelections(date3).length, 0);
        expect(calendarController.lastSelectedDay, isNull);

        calendarController.dispose();
      });

      test('Deselect day', () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);

        calendarController.selectDay(date1);

        expect(calendarController.lastSelectedDay, date1);

        calendarController.selectDay(date1);

        expect(calendarController.getSelections(date1).length, 0);
        expect(calendarController.lastSelectedDay, isNull);

        calendarController.dispose();
      });

      test('Remove selection', () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.overlap,
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);
        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        var selections = calendarController.getSelections(date1);
        expect(selections.length, 1);

        calendarController.removeSelection(selections.first);
        selections = calendarController.getSelections(date1);
        expect(selections.length, 0);

        calendarController.dispose();
      });

      test("Settings Block", () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.override,
          selectionSettings: SelectionSettings(
            maxSelectionCount: 1,
            selectionConflictMode: SelectionConflictMode.block,
          ),
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        expect(calendarController.getSelections(date1).length, 1);
        expect(calendarController.getSelections(date2).length, 1);

        // This selection should be blocked
        final date3 = DateTime(2024, 6, 20);
        calendarController.selectDay(date3);

        expect(calendarController.getSelections(date3).length, 0);
        expect(calendarController.lastSelectedDay, isNull);
        expect(calendarController.getSelections(date1).length, 1);
        expect(calendarController.getSelections(date2).length, 1);

        calendarController.dispose();
      });

      test("Settings Fifo", () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.override,
          selectionSettings: SelectionSettings(
            maxSelectionCount: 1,
            selectionConflictMode: SelectionConflictMode.fifo,
          ),
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        expect(calendarController.getSelections(date1).length, 1);
        expect(calendarController.getSelections(date2).length, 1);

        final date3 = DateTime(2024, 6, 20);
        calendarController.selectDay(date3);

        expect(calendarController.getSelections(date1).length, 0);
        expect(calendarController.getSelections(date2).length, 0);
        expect(calendarController.getSelections(date3).length, 0);
        expect(calendarController.lastSelectedDay, date3);

        calendarController.dispose();
      });
    });

    group("Override", () {
      test('2 Separate dates', () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        final selectionsDate1 = calendarController.getSelections(date1);
        expect(selectionsDate1.length, 1);
        expect(selectionsDate1.first.start, date1);
        expect(selectionsDate1.first.end, date2);

        final date3 = DateTime(2024, 6, 20);
        final date4 = DateTime(2024, 6, 25);

        calendarController.selectDay(date3);
        calendarController.selectDay(date4);

        final selectionsDate2 = calendarController.getSelections(date3);
        expect(selectionsDate2.length, 1);
        expect(selectionsDate2.first.start, date3);
        expect(selectionsDate2.first.end, date4);

        calendarController.dispose();
      });

      test("Cancel with first selection", () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        final selectionsBefore = calendarController.getSelections(date1);
        expect(selectionsBefore.length, 1);

        final date3 = DateTime(2024, 6, 12);

        calendarController.selectDay(date3);

        final selectionsAfter = calendarController.getSelections(date1);
        expect(selectionsAfter.length, 0);

        calendarController.dispose();
      });

      test("Cancel with last selection", () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        final selectionsBefore = calendarController.getSelections(date1);
        expect(selectionsBefore.length, 1);

        final date3 = DateTime(2024, 6, 20);

        calendarController.selectDay(date3);

        final selectionsMiddle = calendarController.getSelections(date1);
        expect(selectionsMiddle.length, 1);

        final date4 = DateTime(2024, 6, 12);
        calendarController.selectDay(date4);

        final selectionsAfter = calendarController.getSelections(date1);
        expect(selectionsAfter.length, 0);

        calendarController.dispose();
      });

      test("Cancel with wrap selection", () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        final selectionsBefore = calendarController.getSelections(date1);
        expect(selectionsBefore.length, 1);

        final date3 = DateTime(2024, 6, 5);

        calendarController.selectDay(date3);

        final selectionsMiddle = calendarController.getSelections(date1);
        expect(selectionsMiddle.length, 1);

        final date4 = DateTime(2024, 6, 20);
        calendarController.selectDay(date4);

        final selectionsAfter = calendarController.getSelections(date1);
        expect(selectionsAfter.length, 1);

        calendarController.dispose();
      });
    });

    group("Overlap", () {
      test('Overlap first day', () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.overlap,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        final date3 = DateTime(2024, 6, 12);

        calendarController.selectDay(date3);

        final selectionsDate1 = calendarController.getSelections(date1);
        expect(selectionsDate1.length, 1);
        expect(calendarController.lastSelectedDay, date3);

        final selectionsDate3 = calendarController.getSelections(date3);
        expect(selectionsDate3.length, 1);

        calendarController.dispose();
      });

      test("Overlap last day", () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.overlap,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        final date3 = DateTime(2024, 6, 20);

        calendarController.selectDay(date3);

        final selectionsDateMiddle = calendarController.getSelections(date1);
        expect(selectionsDateMiddle.length, 1);
        expect(calendarController.lastSelectedDay, date3);

        final date4 = DateTime(2024, 6, 12);
        calendarController.selectDay(date4);

        final selectionDate1After = calendarController.getSelections(date1);
        expect(selectionDate1After.length, 1);

        final selectionDate2 = calendarController.getSelections(date3);
        expect(selectionDate2.length, 1);

        calendarController.dispose();
      });

      test('Overlap Wrap', () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.overlap,
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);
        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        final date3 = DateTime(2024, 6, 5);
        final date4 = DateTime(2024, 6, 20);
        calendarController.selectDay(date3);
        calendarController.selectDay(date4);

        final selectionsDate1 = calendarController.getSelections(date1);
        expect(selectionsDate1.length, 2);

        final selectionsDate3 = calendarController.getSelections(date3);
        expect(selectionsDate3.length, 1);

        calendarController.dispose();
      });
    });

    group("Merge", () {
      test("Merge first day", () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.merge,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        final date3 = DateTime(2024, 6, 5);

        calendarController.selectDay(date3);

        final selectionsDate1 = calendarController.getSelections(date1);
        expect(selectionsDate1.length, 1);
        expect(selectionsDate1.first.start, date1);
        expect(selectionsDate1.first.end, date2);

        expect(calendarController.lastSelectedDay, date3);

        calendarController.dispose();
      });

      test("Merge last day", () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.merge,
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);
        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        final date3 = DateTime(2024, 6, 20);
        calendarController.selectDay(date3);

        final selectionsDate1 = calendarController.getSelections(date1);
        expect(selectionsDate1.length, 1);

        final date4 = DateTime(2024, 6, 12);
        calendarController.selectDay(date4);

        final selectionsDate2 = calendarController.getSelections(date2);
        expect(selectionsDate2.length, 1);
        expect(selectionsDate2.first.start, date1);
        expect(selectionsDate2.first.end, date3);

        calendarController.dispose();
      });

      test("Merge wrap", () {
        final calendarController = CalendarController(
          conflictMode: ConflictMode.merge,
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);
        calendarController.selectDay(date1);
        calendarController.selectDay(date2);

        final date3 = DateTime(2024, 6, 5);
        calendarController.selectDay(date3);

        final date4 = DateTime(2024, 6, 20);
        calendarController.selectDay(date4);

        final selectionsDate1 = calendarController.getSelections(date1);
        expect(selectionsDate1.length, 1);
        expect(selectionsDate1.first.start, date3);
        expect(selectionsDate1.first.end, date4);

        calendarController.dispose();
      });
    });
  });
}
