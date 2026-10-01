import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';
import '../../utils/datetime.dart';
import '../tabled_metrics.dart';
import '../../scroller.dart';
import '../../viewer.dart';
import '../../config.dart';
import 'pointer_date.dart';
import 'pointer_time.dart';


class TimeIndicator extends StatelessWidget {
  const TimeIndicator({
    super.key,
    required this.metrics,
    required this.scroller,
    required this.direction,
  });

  final TabledMetrics metrics;
  final CalendarScroller scroller;
  final Axis direction;

  Offset? getOffset() {
    if (!scroller.hasClients) return null;
    final now = DateTime.now();
    final date = scroller.datetime.date;
    final days = now.date % date;
    final weeks = (days / metrics.dateStep).floor();
    final tiles = days - weeks * metrics.dateStep;
    final length = metrics.dateSpace;
    final dx = (direction == Axis.horizontal)
        ? tiles * length + scroller.distance - scroller.offset
        : tiles * length;
    final double dy;
    if (metrics.timeScheme != null) {
      final time = now.time % Time.fromHour(metrics.timeBeg);
      dy = (direction == Axis.vertical)
          ? time / metrics.timeScale + scroller.distance - scroller.offset
          : time / metrics.timeScale;
      return Offset(dx, dy);
    }
    if (metrics.weekScheme != null) {
      dy = (direction == Axis.vertical)
          ? weeks / metrics.weekScale - scroller.offset
          : weeks / metrics.weekScale;
      return Offset(dx, dy);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context).clock;
    return TimerBuilder.periodic(
      config.clockPeriod,
      builder: (context) {
        return ListenableBuilder(
          listenable: Listenable.merge([scroller, metrics]),
          builder: (context, _) {
            final length = metrics.dateSpace;
            final offset = getOffset();
            return (offset != null) ? SizedBox(
              width: metrics.width,
              height: metrics.height,
              child: Stack(
                children: [
                  Positioned(
                    left: offset.dx,
                    top: offset.dy,
                    width: length,
                    child: (metrics.timeScheme != null)
                        ? TimePointer(
                      size: Size(length, 0.0),
                    )
                        : DatePointer(
                      date: Date.now(),
                      focus: true,
                    ),
                  ),
                ],
              ),
            ) : SizedBox.shrink();
          },
        );
      },
    );
  }
}
