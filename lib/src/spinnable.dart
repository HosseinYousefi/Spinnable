import 'dart:math';

import 'package:flutter/material.dart';

class Spinnable extends StatefulWidget {
  final double radius;
  final Widget child;
  final List<double> snapAngles;

  Spinnable({
    @required this.radius,
    @required this.child,
    this.snapAngles,
  })  : assert(child != null),
        assert(radius != null) {
    if (snapAngles != null && snapAngles.isNotEmpty) {
      snapAngles.sort();
    }
  }

  @override
  _SpinnableState createState() => _SpinnableState();
}

class _SpinnableState extends State<Spinnable> with SingleTickerProviderStateMixin {
  double angle = 0;
  Tween<double> _tween;
  Duration _duration;

  Offset lockedOn;

  _SpinnableState()
      : _tween = Tween<double>(begin: 0, end: 0),
        _duration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) => lockedOn = d.localPosition,
      onPanUpdate: _panUpdateHandler,
      onPanEnd: _panEndHandler,
      child: TweenAnimationBuilder<double>(
        tween: _tween,
        builder: (context, value, child) => Transform.rotate(angle: angle + value, child: child),
        duration: _duration,
        child: widget.child,
      ),
    );
  }

  void _panUpdateHandler(DragUpdateDetails d) {
    final lockedOnAngle = atan2(lockedOn.dx - widget.radius, lockedOn.dy - widget.radius);
    final currentAngle = atan2(d.localPosition.dx - widget.radius, d.localPosition.dy - widget.radius);
    setState(() {
      lockedOn = d.localPosition;
      angle += lockedOnAngle - currentAngle;
    });
  }

  void _panEndHandler(DragEndDetails d) {
    if (widget.snapAngles != null && widget.snapAngles.isNotEmpty) {
      if (angle < 0) {
        angle = -angle + pi;
      }
      angle %= 2 * pi;
      final nextSnapPoint = widget.snapAngles.firstWhere(
        (element) => element >= angle,
        orElse: () => widget.snapAngles.first,
      );
      final prevSnapPoint = widget.snapAngles.lastWhere(
        (element) => element <= angle,
        orElse: () => widget.snapAngles.last,
      );
      double snapPoint;
      if ((nextSnapPoint - angle).abs() <= (prevSnapPoint - angle).abs()) {
        snapPoint = nextSnapPoint;
      } else {
        snapPoint = prevSnapPoint;
      }
      final increment = snapPoint - angle;
      _duration = Duration(
        milliseconds: (375 * increment.abs() / (2 * pi)).floor(),
      );
      _tween = Tween<double>(begin: 0, end: increment);
      setState(() {});
    }
  }
}
