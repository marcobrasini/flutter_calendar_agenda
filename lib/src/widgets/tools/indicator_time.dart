import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';
import '../../utils/datetime.dart';
import '../../scroller.dart';
import '../../context.dart';
import '../tabled_metrics.dart';
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
    if (metrics.weekScheme == null) return Offset(dx, 0.0);
    dy = (direction == Axis.vertical)
        ? weeks / metrics.weekScale - scroller.offset
        : weeks / metrics.weekScale;
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final clockConfig = context.config.clock;
    return TimerBuilder.periodic(
      clockConfig.clockPeriod,
      builder: (context) {
        return ListenableBuilder(
          listenable: Listenable.merge([scroller, metrics]),
          builder: (context, _) {
            final space = context.dateOffset(metrics.view);
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
                          view: metrics.view,
                          date: Date.now(),
                          width: length,
                          height: space,
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
