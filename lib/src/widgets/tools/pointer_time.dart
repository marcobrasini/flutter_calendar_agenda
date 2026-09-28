import 'package:flutter/material.dart';
import '../../config.dart';
import '../../enums.dart';
import 'painter_lines.dart';
import 'painter_point.dart';


class TimePointer extends StatelessWidget {
  const TimePointer({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context).clock;
    final colors = Theme.of(context).colorScheme;
    final color = config.clockColor ?? colors.primary;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: CustomPaint(
        size: Size.infinite,
        painter: LinesPainter(
          positions: [0.0],
          lineStyle: LineStyle.solid,
          lineColor: color,
          lineWidth: config.clockWidth,
          direction: LineDirection.horizontal,
          points: [
            PointPainter(
              offset: Offset.zero,
              radius: config.clockRadius,
              color: color,
            )
          ],
        ),
      ),
    );
  }
}