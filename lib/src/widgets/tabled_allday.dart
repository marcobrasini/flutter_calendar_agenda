import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/datetime.dart';
import '../scroller.dart';
import '../modifier.dart';
import '../context.dart';
import 'calendar_target.dart';
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

  List<Date> dates(Date date) => List.generate(metrics.dateCount, (i) => date + i);

  Widget slots(BuildContext context, Date datetime) {
    final modifier = context.read<CalendarModifier>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final date in dates(datetime.date))
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.config.callbacks.onFrameTap?.call(date),
              child:  DropWidget(
                registry: modifier.registry,
                delegate: TileDropDelegate(date),
                child: TabledListed(
                  key: ValueKey(date),
                  date: date,
                  width: metrics.width / metrics.dateCount,
                  height: null,
                  filter: (e) => e.isAllDay,
                ),
              ),
            ),
          ),
        ]
      );
    }

  // Widget _page(BuildContext context, Date? date) {
  //   final modifier = context.read<CalendarModifier>();
  //   final width = metrics.width / metrics.dateCount;
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       for (final d in dates(date))
  //         DropWidget(
  //           registry: modifier.registry,
  //           delegate: TileDropDelegate(d),
  //           child: TabledListed(
  //             key: ValueKey(d),
  //             date: d,
  //             width: width,
  //             height: null,
  //             filter: (e) => e.isAllDay,
  //           ),
  //         ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ListenableBuilder(
        listenable: metrics,
        builder: (context, _) {
          if (scroller == null || !scroller!.hasClients) return SizedBox.shrink();
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
                      child: slots(context, date + i * metrics.dateStep),
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