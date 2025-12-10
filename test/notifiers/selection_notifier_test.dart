import 'package:flutter_test/flutter_test.dart';
import 'package:multi_selection_calendar/enums/enums.dart';
import 'package:multi_selection_calendar/notifiers/selection_notifier.dart';

void main() {
  group('Selection Notifier', () {
    group("Base Functionalities", () {
      test('Insert Date', () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        selectionNotifier.selectDay(date1);
        expect(selectionNotifier.lastSelectedDay, date1);

        selectionNotifier.selectDay(date2);
        final selections = selectionNotifier.getSelections(
          DateTime(2024, 6, 12),
        );
        expect(selections.length, 1);

        final selection = selections.first;
        expect(selection.start, date1);
        expect(selection.end, date2);

        expect(selectionNotifier.lastSelectedDay, isNull);

        selectionNotifier.dispose();
      });

      test('Clear dates', () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);
        final date3 = DateTime(2024, 6, 20);

        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        var selections = selectionNotifier.getSelections(date1);
        expect(selections.length, 1);

        selectionNotifier.selectDay(date3);

        expect(selectionNotifier.lastSelectedDay, date3);

        selectionNotifier.clearSelections();
        expect(selectionNotifier.getSelections(date1).length, 0);
        expect(selectionNotifier.getSelections(date2).length, 0);
        expect(selectionNotifier.getSelections(date3).length, 0);
        expect(selectionNotifier.lastSelectedDay, isNull);

        selectionNotifier.dispose();
      });

      test('Deselect day', () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);

        selectionNotifier.selectDay(date1);

        expect(selectionNotifier.lastSelectedDay, date1);

        selectionNotifier.selectDay(date1);

        expect(selectionNotifier.getSelections(date1).length, 0);
        expect(selectionNotifier.lastSelectedDay, isNull);

        selectionNotifier.dispose();
      });

      test('Remove selection', () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.overlap,
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);
        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        var selections = selectionNotifier.getSelections(date1);
        expect(selections.length, 1);

        selectionNotifier.removeSelection(selections.first);
        selections = selectionNotifier.getSelections(date1);
        expect(selections.length, 0);

        selectionNotifier.dispose();
      });

      test("Settings Block", () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.override,
          selectionSettings: SelectionSettings(
            maxSelectionCount: 1,
            selectionConflictMode: SelectionConflictMode.block,
          ),
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        expect(selectionNotifier.getSelections(date1).length, 1);
        expect(selectionNotifier.getSelections(date2).length, 1);

        // This selection should be blocked
        final date3 = DateTime(2024, 6, 20);
        selectionNotifier.selectDay(date3);

        expect(selectionNotifier.getSelections(date3).length, 0);
        expect(selectionNotifier.lastSelectedDay, isNull);
        expect(selectionNotifier.getSelections(date1).length, 1);
        expect(selectionNotifier.getSelections(date2).length, 1);

        selectionNotifier.dispose();
      });

      test("Settings Fifo", () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.override,
          selectionSettings: SelectionSettings(
            maxSelectionCount: 1,
            selectionConflictMode: SelectionConflictMode.fifo,
          ),
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        expect(selectionNotifier.getSelections(date1).length, 1);
        expect(selectionNotifier.getSelections(date2).length, 1);

        final date3 = DateTime(2024, 6, 20);
        selectionNotifier.selectDay(date3);

        expect(selectionNotifier.getSelections(date1).length, 0);
        expect(selectionNotifier.getSelections(date2).length, 0);
        expect(selectionNotifier.getSelections(date3).length, 0);
        expect(selectionNotifier.lastSelectedDay, date3);

        selectionNotifier.dispose();
      });
    });

    group("Override", () {
      test('2 Separate dates', () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        final selectionsDate1 = selectionNotifier.getSelections(date1);
        expect(selectionsDate1.length, 1);
        expect(selectionsDate1.first.start, date1);
        expect(selectionsDate1.first.end, date2);

        final date3 = DateTime(2024, 6, 20);
        final date4 = DateTime(2024, 6, 25);

        selectionNotifier.selectDay(date3);
        selectionNotifier.selectDay(date4);

        final selectionsDate2 = selectionNotifier.getSelections(date3);
        expect(selectionsDate2.length, 1);
        expect(selectionsDate2.first.start, date3);
        expect(selectionsDate2.first.end, date4);

        selectionNotifier.dispose();
      });

      test("Cancel with first selection", () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        final selectionsBefore = selectionNotifier.getSelections(date1);
        expect(selectionsBefore.length, 1);

        final date3 = DateTime(2024, 6, 12);

        selectionNotifier.selectDay(date3);

        final selectionsAfter = selectionNotifier.getSelections(date1);
        expect(selectionsAfter.length, 0);

        selectionNotifier.dispose();
      });

      test("Cancel with last selection", () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        final selectionsBefore = selectionNotifier.getSelections(date1);
        expect(selectionsBefore.length, 1);

        final date3 = DateTime(2024, 6, 20);

        selectionNotifier.selectDay(date3);

        final selectionsMiddle = selectionNotifier.getSelections(date1);
        expect(selectionsMiddle.length, 1);

        final date4 = DateTime(2024, 6, 12);
        selectionNotifier.selectDay(date4);

        final selectionsAfter = selectionNotifier.getSelections(date1);
        expect(selectionsAfter.length, 0);

        selectionNotifier.dispose();
      });

      test("Cancel with wrap selection", () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.override,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        final selectionsBefore = selectionNotifier.getSelections(date1);
        expect(selectionsBefore.length, 1);

        final date3 = DateTime(2024, 6, 5);

        selectionNotifier.selectDay(date3);

        final selectionsMiddle = selectionNotifier.getSelections(date1);
        expect(selectionsMiddle.length, 1);

        final date4 = DateTime(2024, 6, 20);
        selectionNotifier.selectDay(date4);

        final selectionsAfter = selectionNotifier.getSelections(date1);
        expect(selectionsAfter.length, 1);

        selectionNotifier.dispose();
      });
    });

    group("Overlap", () {
      test('Overlap first day', () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.overlap,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        final date3 = DateTime(2024, 6, 12);

        selectionNotifier.selectDay(date3);

        final selectionsDate1 = selectionNotifier.getSelections(date1);
        expect(selectionsDate1.length, 1);
        expect(selectionNotifier.lastSelectedDay, date3);

        final selectionsDate3 = selectionNotifier.getSelections(date3);
        expect(selectionsDate3.length, 1);

        selectionNotifier.dispose();
      });

      test("Overlap last day", () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.overlap,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        final date3 = DateTime(2024, 6, 20);

        selectionNotifier.selectDay(date3);

        final selectionsDateMiddle = selectionNotifier.getSelections(date1);
        expect(selectionsDateMiddle.length, 1);
        expect(selectionNotifier.lastSelectedDay, date3);

        final date4 = DateTime(2024, 6, 12);
        selectionNotifier.selectDay(date4);

        final selectionDate1After = selectionNotifier.getSelections(date1);
        expect(selectionDate1After.length, 1);

        final selectionDate2 = selectionNotifier.getSelections(date3);
        expect(selectionDate2.length, 1);

        selectionNotifier.dispose();
      });

      test('Overlap Wrap', () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.overlap,
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);
        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        final date3 = DateTime(2024, 6, 5);
        final date4 = DateTime(2024, 6, 20);
        selectionNotifier.selectDay(date3);
        selectionNotifier.selectDay(date4);

        final selectionsDate1 = selectionNotifier.getSelections(date1);
        expect(selectionsDate1.length, 2);

        final selectionsDate3 = selectionNotifier.getSelections(date3);
        expect(selectionsDate3.length, 1);

        selectionNotifier.dispose();
      });
    });

    group("Merge", () {
      test("Merge first day", () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.merge,
        );
        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);

        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        final date3 = DateTime(2024, 6, 5);

        selectionNotifier.selectDay(date3);

        final selectionsDate1 = selectionNotifier.getSelections(date1);
        expect(selectionsDate1.length, 1);
        expect(selectionsDate1.first.start, date1);
        expect(selectionsDate1.first.end, date2);

        expect(selectionNotifier.lastSelectedDay, date3);

        selectionNotifier.dispose();
      });

      test("Merge last day", () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.merge,
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);
        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        final date3 = DateTime(2024, 6, 20);
        selectionNotifier.selectDay(date3);

        final selectionsDate1 = selectionNotifier.getSelections(date1);
        expect(selectionsDate1.length, 1);

        final date4 = DateTime(2024, 6, 12);
        selectionNotifier.selectDay(date4);

        final selectionsDate2 = selectionNotifier.getSelections(date2);
        expect(selectionsDate2.length, 1);
        expect(selectionsDate2.first.start, date1);
        expect(selectionsDate2.first.end, date3);

        selectionNotifier.dispose();
      });

      test("Merge wrap", () {
        final selectionNotifier = SelectionNotifier(
          conflictMode: ConflictMode.merge,
        );

        final date1 = DateTime(2024, 6, 10);
        final date2 = DateTime(2024, 6, 15);
        selectionNotifier.selectDay(date1);
        selectionNotifier.selectDay(date2);

        final date3 = DateTime(2024, 6, 5);
        selectionNotifier.selectDay(date3);

        final date4 = DateTime(2024, 6, 20);
        selectionNotifier.selectDay(date4);

        final selectionsDate1 = selectionNotifier.getSelections(date1);
        expect(selectionsDate1.length, 1);
        expect(selectionsDate1.first.start, date3);
        expect(selectionsDate1.first.end, date4);

        selectionNotifier.dispose();
      });
    });
  });
}
