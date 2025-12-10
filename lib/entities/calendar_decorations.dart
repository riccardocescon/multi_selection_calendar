import 'package:flutter/material.dart';

class DayDecoration {
  final TextStyle? dayTextStyle;
  final Color? dayBackgroundColor;
  final double selectedRadius;
  final double verticalMargin;
  final Color? selectedDayBackgroundColor;
  final Color? cellBackgroundColor;
  final Color? disabledDayBackgroundColor;
  final int cellSelectionAlpha;

  const DayDecoration({
    this.dayTextStyle,
    this.dayBackgroundColor,
    this.selectedRadius = 32,
    this.verticalMargin = 1.0,
    this.selectedDayBackgroundColor,
    this.cellBackgroundColor,
    this.disabledDayBackgroundColor,
    this.cellSelectionAlpha = 80,
  }) : assert(
         (cellSelectionAlpha >= 0 && cellSelectionAlpha <= 255),
         'cellSelectionAlpha must be between 0 and 255',
       );
}
