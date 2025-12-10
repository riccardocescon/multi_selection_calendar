import 'package:flutter/widgets.dart';

class HeaderDecoration {
  final bool shortMonthName;
  final TextStyle? monthTextStyle;
  final TextStyle? yearTextStyle;
  final double iconSize;

  const HeaderDecoration({
    this.shortMonthName = false,
    this.monthTextStyle,
    this.yearTextStyle,
    this.iconSize = 16,
  });
}
