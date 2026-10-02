import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tools/slot_date.dart';
import '../utils/datetime.dart';
import '../scroller.dart';
import '../modifier.dart';
import '../context.dart';
import '../enums.dart';
import 'calendar_target.dart';
import 'tabled_metrics.dart';


class TabledHeader extends StatelessWidget {

  const TabledHeader({
    super.key,
    required this.width,
    required this.height,
    required this.metrics,
    this.scroller,
  });

  final double width;
  final double height;
  final TabledMetrics metrics;
  final CalendarScroller? scroller;

  CalendarView get view => metrics.view;

  List<Date> dates([Date? date]) {
    final start = (date ?? Week.weekDays.mon) + metrics.dateBeg;
    return List.generate(metrics.dateCount, (i) => start + i);
  }

  Widget slots(BuildContext context, DateTime? datetime) {
    final modifier = context.read<CalendarModifier>();
    return Row(
      children: [
        for (final date in dates(datetime?.date))
          Expanded(
            child: DropWidget(
              registry: modifier.registry,
              delegate: TileDropDelegate(date),
              child: DateSlot(
                date: date,
                config: (metrics.weekScheme == null)
                    ? context.config.dateConfig(view)
                    : context.config.weekConfig(view),
              ),
            ),
          )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateConfig = (metrics.weekScheme == null)
        ? context.config.dateConfig(view)
        : context.config.weekConfig(view);
    return (scroller != null && scroller!.hasClients)
        ? ListenableBuilder(
          listenable: Listenable.merge([metrics, scroller!]),
          builder: (context, _) {
            final date = scroller!.datetime.date;
            return ClipRect(
              child: Container(
                width: width,
                height: height,
                color: dateConfig.background,
                child: AnimatedBuilder(
                  animation: scroller!,
                  builder: (context, _) {
                    final fraction = scroller!.offset / width;
                    final base = fraction.floor();
                    return Stack(
                      children: [base, base + 1].map((i) => Positioned(
                        left: (i - fraction) * width,
                        top: 0,
                        width: width,
                        height: height,
                        child: slots(context, date + i * metrics.dateStep),
                      )).toList(),
                    );
                  },
                ),
              ),
            );
          }
        )
        : slots(context, null);
  }
}
