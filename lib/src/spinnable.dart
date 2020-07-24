import 'dart:math';

import 'package:flutter/material.dart';

class Spinnable extends StatefulWidget {
  final double radius;
  final Widget child;
  final List<double> snapAngles;
  final ValueChanged<double> onAngleChanged;

  Spinnable({
    @required this.radius,
    @required this.child,
    this.snapAngles,
    this.onAngleChanged,
  })  : assert(child != null),
        assert(radius != null) {
    if (snapAngles != null && snapAngles.isNotEmpty) {
      snapAngles.sort();
    }
  }

  @override
  _SpinnableState createState() => _SpinnableState(onAngleChanged);
}

class _SpinnableState extends State<Spinnable> with SingleTickerProviderStateMixin {
  ValueChanged<double> angleChanged;
  Tween<double> _tween;
  Duration _duration;
  bool cw = true;

  Offset lockedOn;

  _SpinnableState(this.angleChanged)
      : _tween = Tween<double>(begin: 0, end: 0),
        _duration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) {
        _tween.end %= 2 * pi;
        if (_tween.end < 0) _tween.end += 2 * pi;
        _tween.begin = _tween.end;
        _duration = Duration.zero;
        lockedOn = d.localPosition;
      },
      onPanUpdate: _panUpdateHandler,
      onPanEnd: _panEndHandler,
      child: TweenAnimationBuilder<double>(
        tween: _tween,
        builder: (context, value, child) => Transform.rotate(angle: value, child: child),
        duration: _duration,
        child: widget.child,
      ),
    );
  }

  void _panUpdateHandler(DragUpdateDetails d) {
    final lockedOnAngle = atan2(lockedOn.dx - widget.radius, lockedOn.dy - widget.radius);
    final currentAngle = atan2(d.localPosition.dx - widget.radius, d.localPosition.dy - widget.radius);
    setState(() {
      cw = (lockedOnAngle - currentAngle) > 0;
      lockedOn = d.localPosition;
      _duration = Duration.zero;
      _tween = Tween<double>(begin: _tween.end, end: _tween.end + lockedOnAngle - currentAngle);
    });
  }

  void _panEndHandler(DragEndDetails d) {
    if (widget.snapAngles != null && widget.snapAngles.isNotEmpty) {
      double angle = _tween.end;
      angle %= 2 * pi;
      if (angle < 0) _tween.end += 2 * pi;
      final nextSnapPoint = widget.snapAngles.firstWhere(
        (element) => element >= angle,
        orElse: () => widget.snapAngles.first + 2 * pi,
      );
      final prevSnapPoint = widget.snapAngles.lastWhere(
        (element) => element <= angle,
        orElse: () => widget.snapAngles.last - 2 * pi,
      );
      print('next: $nextSnapPoint');
      print('prev: $prevSnapPoint');
      double snapPoint;
      if (d.velocity.pixelsPerSecond.distanceSquared <= 1e-5) {
        if ((nextSnapPoint - angle).abs() <= (prevSnapPoint - angle).abs()) {
          snapPoint = nextSnapPoint;
        } else {
          snapPoint = prevSnapPoint;
        }
      } else if (cw) {
        snapPoint = nextSnapPoint;
      } else {
        snapPoint = prevSnapPoint;
      }
      if (_tween.end < 0) snapPoint -= 2 * pi;
      final increment = snapPoint - _tween.end;
      _duration = Duration(
        milliseconds: (375 * increment.abs() / (2 * pi)).floor(),
      );
      print('tweening from ${_tween.end} to ${snapPoint}');
      _tween = Tween<double>(begin: _tween.end, end: snapPoint);
      if (angleChanged != null) angleChanged(snapPoint);
      setState(() {});
    }
  }
}
