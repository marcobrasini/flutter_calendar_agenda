import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../modifier.dart';
import '../source.dart';
import '../const.dart';
import 'tabled_frame.dart';
import 'tabled_paged.dart';
import 'tabled_listed.dart';
import 'tabled_metrics.dart';

class TabledSlot extends StatelessWidget {
  const TabledSlot({
    super.key,
    required this.date,
    required this.metrics,
    this.offset = Offset.zero,
    this.active,
  });

  final Date date;
  final TabledMetrics metrics;
  final DateFilter? active;
  final Offset offset;
  TimeScheme? get timeScheme => metrics.timeScheme;
  DateScheme? get dateScheme => metrics.dateScheme;
  double get width => metrics.frameWidth - offset.dx;
  double get height => metrics.frameHeight - offset.dy;
  Size get size => Size(width, height);

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarEvents>();
    final modifier = context.read<CalendarModifier>();
    final space = width / metrics.dateCount;
    return Stack(
      children: [
        TabledFrame(
          key: ValueKey(date),
          width: width,
          height: height,
          offset: offset,
          timeScheme: timeScheme,
          dateScheme: dateScheme,
        ),
        if (timeScheme != null)
          for (int i = metrics.dateBeg; i < metrics.dateEnd; i++)
            Positioned(
              top: offset.dy,
              left: offset.dx + (i - metrics.dateBeg) * space,
              width: space,
              height: height,
              child: TabledPaged(
                key: ValueKey(date + i),
                date: date + i,
                width: space,
                height: height,
                timeScheme: timeScheme!,
              ),
            )
        else
          Positioned(
            top: offset.dy,
            left: offset.dx,
            width: width,
            height: height,
            child: TabledListed(
              date: date,
              metrics: metrics,
            ),
          ),
      ],
    );
  }
}
