import 'package:flutter/material.dart';
import '../utils/datetime.dart';
import '../scroller.dart';
import 'tabled_metrics.dart';
import 'tabled_listed.dart';

class TabledAllDay extends StatelessWidget {
  const TabledAllDay({
    super.key,
    required this.metrics,
    required this.scroller,
  });

  final TabledMetrics metrics;
  final CalendarScroller? scroller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ListenableBuilder(
        listenable: metrics,
        builder: (context, _) {
          if (scroller == null || !scroller!.hasClients) {
            return SizedBox.shrink();
          }
          return AnimatedBuilder(
            animation: scroller!,
            builder: (context, _) {
              final date = scroller!.datetime.date;
              final fraction = scroller!.offset / metrics.width;
              final base = fraction.floor();
              return Stack(
                children: [
                  for (final i in [base, base + 1])
                    Positioned(
                      left: (i - fraction) * metrics.width,
                      top: 0,
                      bottom: 0,
                      width: metrics.width,
                      child: TabledListed(
                        date: date + i * metrics.dateStep,
                        metrics: metrics,
                        filter: (e) => e.isMultiDay,
                        header: false,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
