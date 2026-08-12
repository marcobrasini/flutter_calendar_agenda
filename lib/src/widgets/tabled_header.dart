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
    this.controller,
  });

  final TabledMetrics metrics;
  final TextConfig config;
  final CalendarController? controller;

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
          datePadding: config.padding,
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
        return (controller != null && controller!.hasClients)
            ? ListenableBuilder(
              listenable: controller!,
              builder: (context, _) {
                final date = controller!.datetime.date;
                return ClipRect(
                  child: SizedBox(
                    width: metrics.width,
                    height: metrics.height,
                    child: AnimatedBuilder(
                      animation: controller!,
                      builder: (context, _) {
                        double fraction = controller!.offset / metrics.width;
                        final base = fraction.floor();
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [base, base + 1].map((i) =>
                              Positioned(
                                left: (i - fraction) * metrics.width,
                                top: 0,
                                width: metrics.width,
                                height: metrics.height,
                                child: Row(
                                  children: slots(date + i * metrics.dateStep),
                                ),
                              ),
                          ).toList(),
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
