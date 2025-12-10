import 'package:flutter/material.dart';

class CalendarPickerDecoration {
  final double borderRadius;
  final double padding;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const CalendarPickerDecoration({
    this.borderRadius = 16,
    this.padding = 8.0,
    this.backgroundColor,
    this.textStyle,
  });
}
