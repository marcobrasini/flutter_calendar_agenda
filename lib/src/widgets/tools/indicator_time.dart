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

  double get _pageExtent => switch (direction) {
    Axis.horizontal => metrics.width,
    Axis.vertical =>
      (metrics.weekScheme != null) ? metrics.weekSpace : metrics.height,
  };

  Offset? getOffset() {
    if (!scroller.hasClients) return null;
    final now = DateTime.now();
    final days = now.date % scroller.datetime.date;
    final page = (days / metrics.dateStep).floor();
    final tile = days - page * metrics.dateStep;
    final main = page * _pageExtent - scroller.offset;
    final cross = tile * metrics.dateSpace;
    final time = (metrics.timeScheme != null)
        ? (now.time % Time.fromHour(metrics.timeBeg)) / metrics.timeScale
        : 0.0;
    return switch (direction) {
      Axis.horizontal => Offset(main + cross, time),
      Axis.vertical => Offset(cross, main + time),
    };
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
            return (offset != null)
                ? SizedBox(
                    width: metrics.width,
                    height: metrics.height,
                    child: Stack(
                      children: [
                        Positioned(
                          left: offset.dx,
                          top: offset.dy,
                          width: length,
                          child: (metrics.timeScheme != null)
                              ? TimePointer(size: Size(length, 0.0))
                              : DatePointer(
                                  view: metrics.view,
                                  date: Date.now(),
                                  width: length,
                                  height: space,
                                ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink();
          },
        );
      },
    );
  }
}
