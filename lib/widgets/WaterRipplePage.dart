import 'package:flutter/material.dart';
import 'dart:math';
class WaterRipple extends StatefulWidget {
  final int count;
  final Color color;

  const WaterRipple({Key? key, this.count = 3, this.color = const Color(0xFF0080ff)}) : super(key: key);

  @override
  _WaterRippleState createState() => _WaterRippleState();
}
class _WaterRippleState extends State<WaterRipple> with SingleTickerProviderStateMixin {
  late  AnimationController animationController ;
  @override
  void initState() {
    animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 2000))
      ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: WaterRipplePainter(animationController.value,count: widget.count,color: widget.color),
        );
      },
    );
  }
}

class WaterRipplePainter extends CustomPainter {
  final double progress;
  final int count;
  final Color color;

  Paint _paint = Paint()..style = PaintingStyle.fill;

  WaterRipplePainter(this.progress,
      {this.count = 3, this.color = const Color(0xFF0080ff)});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = min(size.width / 2, size.height / 2);
    for (int i = count; i >= 0; i--) {
      final double opacity = (1.0 - ((i + progress) / (count + 1)));
      final Color _color = color.withOpacity(opacity);
      _paint..color = _color;

      double _radius = radius * ((i + progress) / (count + 1));

      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2), _radius, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
