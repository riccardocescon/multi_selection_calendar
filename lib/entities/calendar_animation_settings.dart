import 'package:flutter/animation.dart';

class CalendarAnimationSettings {
  final Duration duration;
  final Curve curve;

  const CalendarAnimationSettings({
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOutCubic,
  });
}
