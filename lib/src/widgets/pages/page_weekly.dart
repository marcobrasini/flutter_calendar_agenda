import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/header_weekly.dart';
import '../tools/slot_event.dart';
import '../pages/page_gesture.dart';
import '../../utils/datetime.dart';
import '../../mixin.dart';
import '../../config.dart';
import '../../controller.dart';
import '../../data/event.dart';
import '../../data/source.dart';


class WeeklyPage extends StatelessWidget with DateScheme, TimeScheme {

  const WeeklyPage({
    super.key,
    required this.width,
    required this.height,
    required this.padding,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
  });

  final double width;
  final double height;
  final double padding;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  double get dayScale => days / width;
  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  double get timeScale => minutes / height;

  int x(Event event) => event.start.weekday - begDay;
  int y(Event event) => event.start.time % Time.fromHour(begHour);

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
      begDay: begDay,
      endDay: endDay,
      dateStep: dateStep,
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
                    left: x(event) / dayScale,
                    child: EventSlot(
                      event: event,
                      width: 1 / dayScale,
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
