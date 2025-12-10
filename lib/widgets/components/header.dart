part of '../multi_selection_calendar.dart';

class _Header extends StatelessWidget {
  const _Header({
    required this.selectedYear,
    required this.monthIndex,
    required this.minYear,
    required this.maxYear,
    required this.enablePrevMonth,
    required this.enableNextMonth,
    required this.loadPrevMonth,
    required this.loadNextMonth,
    required this.loadNewYear,
    required this.onChangeMonth,
    required this.onChangeYear,
    required this.decoration,
  });

  final int selectedYear;
  final int monthIndex;
  final int minYear;
  final int maxYear;
  final bool enablePrevMonth;
  final bool enableNextMonth;
  final VoidCallback loadPrevMonth;
  final VoidCallback loadNextMonth;
  final void Function(int year) loadNewYear;
  final VoidCallback onChangeMonth;
  final VoidCallback onChangeYear;
  final HeaderDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: 16,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onChangeMonth,
                child: Row(
                  spacing: 8,
                  children: [
                    Text(
                      (decoration.shortMonthName
                              ? DateFormat.MMM()
                              : DateFormat.MMMM())
                          .format(DateTime(selectedYear, monthIndex + 1)),
                      style:
                          decoration.monthTextStyle ??
                          Theme.of(context).textTheme.headlineSmall,
                    ),
                    Icon(Icons.arrow_drop_down_rounded),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onChangeYear,
                child: Row(
                  spacing: 8,
                  children: [
                    Text(
                      DateFormat.y().format(
                        DateTime(selectedYear, monthIndex + 1),
                      ),
                      style:
                          decoration.yearTextStyle ??
                          Theme.of(context).textTheme.bodyLarge,
                    ),
                    Icon(Icons.arrow_drop_down_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: enablePrevMonth ? loadPrevMonth : null,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: decoration.iconSize,
            ),
            IconButton(
              onPressed: enableNextMonth ? loadNextMonth : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              iconSize: decoration.iconSize,
            ),
          ],
        ),
      ],
    );
  }
}
