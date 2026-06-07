import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/header_daily.dart';
import '../tools/slot_event.dart';
import '../pages/page_gesture.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../config.dart';
import '../../controller.dart';
import '../../data/event.dart';
import '../../data/source.dart';

class DailyPage extends StatelessWidget {

  const DailyPage({
    super.key,
    required this.width,
    required this.height,
    required this.padding,
    required this.timeScheme,
  });

  final double width;
  final double height;
  final double padding;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);

  int y(Event event) => event.start.time % Time.fromHour(timeScheme.beg);

  @override
  Widget build(BuildContext context) {
    final viewConfig = CalendarConfig.of(context)!.view;
    final source = CalendarSource.of(context);
    final controller = context.watch<CalendarController>();
    final date = controller.dateTime as Date;
    final events = source.forDate(date);
    final headerPage = DailyHeader(
      date: date,
      width: width,
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
                    child: EventSlot(
                      event: event,
                      width: width,
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
