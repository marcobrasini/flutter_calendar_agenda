import 'package:flutter/material.dart';
import '../components/header_daily.dart';
import '../components/slot_event.dart';
import '../pages/page_gesture.dart';
import '../../utils/datetime.dart';
import '../../mixin.dart';
import '../../data/event.dart';
import '../../data/source.dart';


class DailyPage extends StatefulWidget with TimeScheme {

  const DailyPage({
    super.key,
    required this.width,
    required this.height,
    required this.padding,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    required this.dateFormat,
    required this.datePadding,
    this.dateTextStyle,
    this.dateBackground,
  });

  final double width;
  final double height;
  final double padding;
  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  double get timeScale => minutes / height;
  final String dateFormat;
  final double datePadding;
  final TextStyle? dateTextStyle;
  final Color? dateBackground;

  @override
  State<DailyPage> createState() => _DailyPageState();
}


class _DailyPageState extends State<DailyPage> {
  late Date date;

  @override
  void initState() {
    date = Date.now();
    super.initState();
  }

  void _next() => setState(() {date += 1;});
  void _last() => setState(() {date -= 1;});


  int y(Event event) => event.start.time % Time.fromHour(widget.begHour);

  @override
  Widget build(BuildContext context) {
    final source = CalendarSource.of(context);
    final events = source.forDate(date);
    final headerPage = DailyHeader(
      date: date,
      width: widget.width,
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
                    child: EventSlot(
                      event: event,
                      width: widget.width,
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
