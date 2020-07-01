library spinnable;

import 'dart:math';

import 'package:flutter/material.dart';

class Spinnable extends StatefulWidget {
  final double radius;
  final Widget child;

  Spinnable({
    @required this.radius,
    @required this.child,
  })  : assert(child != null),
        assert(radius != null);

  @override
  _SpinnableState createState() => _SpinnableState();
}

class _SpinnableState extends State<Spinnable> with SingleTickerProviderStateMixin {
  double angle = 0;
  Offset lockedOn;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _animationController.addListener(() {
      print('i am listening');
      setState(() => angle += _animationController.value);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) => lockedOn = d.localPosition,
      onPanUpdate: _panUpdateHandler,
      onPanEnd: _panEndHandler,
      child: Transform.rotate(angle: angle, child: widget.child),
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

  void _panEndHandler(DragEndDetails d) {}
}
