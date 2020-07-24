import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spinnable/spinnable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Spinnable(
              snapAngles: [
                0,
                math.pi / 2,
                math.pi,
                3 * math.pi / 2,
              ],
              radius: 200,
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 200,
                  ),
                  Positioned(
                    top: 50,
                    right: 150,
                    child: CircleAvatar(backgroundColor: Colors.red, radius: 50),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
