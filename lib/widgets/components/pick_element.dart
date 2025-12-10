part of '../multi_selection_calendar.dart';

class _PickElement extends StatefulWidget {
  const _PickElement({
    required this.itemCount,
    required this.itemBuilder,
    required this.elementIndex,
    required this.decoration,
    required this.onElementPicked,
    this.enabled,
  });

  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final bool Function(int index)? enabled;
  final int elementIndex;
  final CalendarPickerDecoration decoration;
  final void Function(int elementIndex) onElementPicked;

  @override
  State<_PickElement> createState() => _PickElementState();
}

class _PickElementState extends State<_PickElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1), // inizia sopra lo schermo
          end: Offset.zero, // finisce nella posizione normale
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Avvia l'animazione quando il widget viene creato
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SlideTransition(
        position: _slideAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Material(
              color: Colors.transparent,
              elevation: 4,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: GridView.count(
                  crossAxisCount: 4,
                  children: List.generate(widget.itemCount, (index) {
                    final isSelected = index == widget.elementIndex;

                    return GestureDetector(
                      onTap: widget.enabled?.call(index) ?? true
                          ? () {
                              widget.onElementPicked.call(index);
                            }
                          : null,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            padding: EdgeInsets.all(widget.decoration.padding),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.decoration.backgroundColor ??
                                        Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.all(
                                Radius.circular(widget.decoration.borderRadius),
                              ),
                            ),
                            child: widget.itemBuilder(index),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
