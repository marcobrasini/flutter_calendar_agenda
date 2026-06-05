import 'package:flutter/material.dart';
import '../components/header_weekly.dart';
import '../components/slot_event.dart';
import '../pages/page_gesture.dart';
import '../../utils/datetime.dart';
import '../../mixin.dart';
import '../../data/event.dart';
import '../../data/source.dart';


class WeeklyPage extends StatefulWidget with DateScheme, TimeScheme {

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
    required this.dateFormat,
    required this.datePadding,
    this.dateTextStyle,
    this.dateBackground,
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
  final String dateFormat;
  final double datePadding;
  final TextStyle? dateTextStyle;
  final Color? dateBackground;

  @override
  State<WeeklyPage> createState() => _WeeklyPageState();
}


class _WeeklyPageState extends State<WeeklyPage> {
  late Week week;

  @override
  void initState() {
    week = Week.now();
    super.initState();
  }

  void _next() => setState(() {week += 1;});
  void _last() => setState(() {week -= 1;});

  int x(Event event) => event.start.weekday - widget.begDay;
  int y(Event event) => event.start.time % Time.fromHour(widget.begHour);

  @override
  Widget build(BuildContext context) {
    final source = CalendarSource.of(context);
    final events = source.forWeek(week);
    final headerPage = WeeklyHeader(
      week: week,
      width: widget.width,
      begDay: widget.begDay,
      endDay: widget.endDay,
      dateStep: widget.dateStep,
      background: widget.dateBackground,
      dateFormat: widget.dateFormat,
      datePadding: widget.datePadding,
      dateTextStyle: widget.dateTextStyle,
    );
    return Column(
      children: [
        headerPage,
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            vertical: widget.padding,
          ),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                for (var event in events)
                  Positioned(
                    top: y(event) / widget.timeScale,
                    left: x(event) / widget.dayScale,
                    child: EventSlot(
                      event: event,
                      width: 1 / widget.dayScale,
                      height: event.duration.inMinutes / widget.timeScale,
                    ),
                  ),
                SwipePage(
                  last: _last,
                  next: _next,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
