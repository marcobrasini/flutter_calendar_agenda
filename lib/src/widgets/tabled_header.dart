import '../scroller.dart';
import 'package:flutter/material.dart';
import 'tools/slot_date.dart';
import '../utils/datetime.dart';
import '../viewer.dart';
import '../config.dart';
import '../const.dart';
import 'tabled_metrics.dart';


class TabledHeader extends StatelessWidget {

  const TabledHeader({
    super.key,
    required this.metrics,
    required this.config,
    this.scroller,
  });

  final TabledMetrics metrics;
  final TextConfig config;
  final CalendarScroller? scroller;

  List<Date> dates([Date? date]) {
    final start = (date ?? Week.weekDays.mon) + metrics.dateBeg;
    return List.generate(metrics.dateCount, (i) => start + i);
  }

  List<Widget> slots(DateTime? datetime) {
    final widgets = <Widget>[];
    for (Date date in dates(datetime?.date)) {
      widgets.add(Expanded(
        child: DateSlot(
          date: date,
          dateFormat: config.format ?? defaultDateFormat,
          datePadding: config.textPadding,
          dateTextStyle: config.textStyle,
          dateBackground: config.background,
        ),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: metrics,
      builder: (context, _) {
        return (scroller != null && scroller!.hasClients)
            ? ListenableBuilder(
              listenable: scroller!,
              builder: (context, _) {
                final date = scroller!.datetime.date;
                return ClipRect(
                  child: Container(
                    width: metrics.width,
                    height: metrics.height,
                    color: config.background,
                    child: AnimatedBuilder(
                      animation: scroller!,
                      builder: (context, _) {
                        double fraction = scroller!.offset / metrics.width;
                        final base = fraction.floor();
                        return Stack(
                          children: [base, base + 1].map((i) => Positioned(
                            left: (i - fraction) * metrics.width,
                            top: 0,
                            width: metrics.width,
                            height: metrics.height,
                            child: Row(
                              children: slots(date + i * metrics.dateStep),
                            ),
                          )).toList(),
                        );
                      },
                    ),
                  ),
                );
              },
            )
            : Row(children: slots(null));
      },
    );
  }
}
