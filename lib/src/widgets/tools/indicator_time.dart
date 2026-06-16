import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../config.dart';
import '../../enums.dart';
import 'painter_lines.dart';
import 'painter_point.dart';

class TimeIndicator extends StatelessWidget {
  const TimeIndicator({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.timeScheme,
    double? length,
  }) : length = length ?? width;

  final Date date;
  final double width;
  final double height;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  final double length;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final color = config.view.indicatorColor
        ?? Theme.of(context).primaryColor;
    return TimerBuilder.periodic(
      config.view.indicatorPeriod,
      builder: (context) {
        final now = DateTime.now();
        final time = now.time % Time.fromHour(timeScheme.beg);
        final day = now.date % date;
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned(
                left: day * length,
                top: time / timeScale,
                width: length,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: CustomPaint(
                    size: Size.zero,
                    painter: LinesPainter(
                      positions: [0.0],
                      lineStyle: LineStyle.solid,
                      lineColor: color,
                      lineWidth: config.view.indicatorWidth,
                      direction: LineDirection.horizontal,
                      points: [
                        PointPainter(
                          offset: Offset.zero,
                          radius: config.view.indicatorRadius,
                          color: color,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
