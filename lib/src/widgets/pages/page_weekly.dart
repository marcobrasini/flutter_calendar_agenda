import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/header_weekly.dart';
import '../tools/slot_event.dart';
import '../pages/page_gesture.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../config.dart';
import '../../controller.dart';
import '../../data/event.dart';
import '../../data/source.dart';


class WeeklyPage extends StatelessWidget {

  const WeeklyPage({
    super.key,
    required this.width,
    required this.height,
    required this.padding,
    required this.timeScheme,
    required this.dateScheme,
  });

  final double width;
  final double height;
  final double padding;
  final DateScheme dateScheme;
  final TimeScheme timeScheme;
  double get dateScale => dateScheme.scale(width);
  double get timeScale => timeScheme.scale(height);

  int x(Event event) => event.start.weekday - dateScheme.beg;
  int y(Event event) => event.start.time % Time.fromHour(timeScheme.beg);

  @override
  Widget build(BuildContext context) {
    final viewConfig = CalendarConfig.of(context)!.view;
    final source = CalendarSource.of(context);
    final controller = context.watch<CalendarController>();
    final week = controller.dateTime as Week;
    final events = source.forWeek(week);
    final headerPage = WeeklyHeader(
      week: week,
      width: width,
      scheme: dateScheme,
    );
    return Column(
      children: [
        if (viewConfig.showHeader) headerPage,
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            vertical: padding,
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                for (var event in events)
                  Positioned(
                    top: y(event) / timeScale,
                    left: x(event) / dateScale,
                    child: EventSlot(
                      event: event,
                      width: 1 / dateScale,
                      height: event.duration.inMinutes / timeScale,
                    ),
                  ),
                SwipePage(
                  last: controller.last,
                  next: controller.next,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
