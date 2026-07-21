import 'package:calendar/src/timer.dart';
import 'package:calendar/src/viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    required this.width,
    required this.height,
    required this.timeScheme,
    required this.dateScheme,
  });

  final double width;
  final double height;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  final DateScheme dateScheme;
  double get dateScale => dateScheme.scale(width);

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<CalendarTimer>();
    final viewer = context.watch<CalendarViewer>();
    final date = viewer.asDate + dateScheme.beg;
    final config = CalendarConfig.of(context)!;
    final offset = config.view.indicatorRadius;
    final length = (width - offset) / dateScheme.count;
    final color = config.view.indicatorColor
        ?? Theme.of(context).primaryColor;
    return TimerBuilder.periodic(
      config.view.indicatorPeriod,
      builder: (context) {
        final now = DateTime.now();
        final time = now.time % Time.fromHour(timeScheme.beg);
        final day = now.date % date;
        final dx = ((day / dateScheme.count).round()) * offset;
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned(
                left: day * length - timer.scroll * width + dx,
                top: time / timeScale,
                height: 0.0,
                width: length,
                child: CustomPaint(
                  size: Size.infinite,
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
            ],
          ),
        );
      },
    );
  }
}
