part of '../multi_selection_calendar.dart';

enum _OpenedMenu { year, month, none }

class _Header extends StatefulWidget {
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
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  _OpenedMenu _openedMenu = _OpenedMenu.none;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: 16,
            children: [
              _AnimatedHeaderOption(
                onTap: () {
                  setState(() {
                    _openedMenu = _openedMenu == _OpenedMenu.month
                        ? _OpenedMenu.none
                        : _OpenedMenu.month;
                  });
                  widget.onChangeMonth.call();
                },
                isOpened: _openedMenu == _OpenedMenu.month,
                child: Text(
                  (widget.decoration.shortMonthName
                          ? DateFormat.MMM()
                          : DateFormat.MMMM())
                      .format(
                        DateTime(widget.selectedYear, widget.monthIndex + 1),
                      ),
                  style:
                      widget.decoration.monthTextStyle ??
                      Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              _AnimatedHeaderOption(
                onTap: () {
                  setState(() {
                    _openedMenu = _openedMenu == _OpenedMenu.year
                        ? _OpenedMenu.none
                        : _OpenedMenu.year;
                  });
                  widget.onChangeYear.call();
                },
                isOpened: _openedMenu == _OpenedMenu.year,
                child: Text(
                  DateFormat.y().format(
                    DateTime(widget.selectedYear, widget.monthIndex + 1),
                  ),
                  style:
                      widget.decoration.yearTextStyle ??
                      Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: widget.enablePrevMonth ? widget.loadPrevMonth : null,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: widget.decoration.iconSize,
            ),
            IconButton(
              onPressed: widget.enableNextMonth ? widget.loadNextMonth : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              iconSize: widget.decoration.iconSize,
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedHeaderOption extends StatefulWidget {
  const _AnimatedHeaderOption({
    required this.onTap,
    required this.isOpened,
    required this.child,
  });

  final VoidCallback onTap;
  final bool isOpened;
  final Widget child;

  @override
  State<_AnimatedHeaderOption> createState() => _AnimatedHeaderOptionState();
}

class _AnimatedHeaderOptionState extends State<_AnimatedHeaderOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  bool _isSelected = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _rotation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant _AnimatedHeaderOption oldWidget) {
    if (widget.isOpened != oldWidget.isOpened) {
      if (widget.isOpened) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isSelected = !_isSelected;
      if (_isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    widget.onTap.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: Row(
        spacing: 8,
        children: [
          widget.child,
          RotationTransition(
            turns: _rotation,
            child: const Icon(Icons.arrow_drop_down_rounded),
          ),
        ],
      ),
    );
  }
}
