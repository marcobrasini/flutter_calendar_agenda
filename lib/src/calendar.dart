import 'package:calendar/src/const.dart';
import 'package:flutter/material.dart';
import 'widgets/views/view_daily.dart';
import 'widgets/views/view_weekly.dart';
import 'widgets/components/header_calendar.dart';
import 'utils/datetime.dart';
import 'data/source.dart';
import 'enums.dart';


class Calendar extends StatefulWidget {
  final CalendarView view;
  final Source source;
  final int fromHour;
  final int toHour;
  final int fromDay;
  final int toDay;
  final TextStyle? headerTextStyle;

  const Calendar({
    super.key,
    required this.view,
    required this.source,
    this.fromHour = initialHour,
    this.toHour = finalHour,
    this.fromDay = initialDay,
    this.toDay = finalDay,
    this.headerTextStyle,
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late dynamic dateTime;

  void last() => setState(() {dateTime -= 1;});

  void next() => setState(() {dateTime += 1;});

  String title() {
    switch (widget.view) {
      case CalendarView.daily:
        return dateTime.format("d MMMM yyyy");
      case CalendarView.weekly:
        final start = dateTime.mon.format("dd/MM/yyyy");
        final stop = dateTime.sun.format("dd/MM/yyyy");
        return "$start ── $stop";
      case CalendarView.monthly:
        return dateTime.format("MMMM yyyy");
    }
  }

  Widget page() {
    switch (widget.view) {
      case CalendarView.daily:
        return DailyView(
          date: dateTime,
          fromHour: widget.fromHour,
          toHour: widget.toHour,
          timePadding: 8.0,
        );
      case CalendarView.weekly:
        return WeeklyView(
          week: dateTime,
          fromHour: widget.fromHour,
          toHour: widget.toHour,
          fromDay: widget.fromDay,
          toDay: widget.toDay,
          timePadding: 8.0,
        );
      case CalendarView.monthly:
        return Placeholder();
    }
  }

  @override
  void initState() {
    switch (widget.view) {
      case CalendarView.daily:
        dateTime = Date.now();
        break;
      case CalendarView.weekly:
        dateTime = Week.now();
        break;
      case CalendarView.monthly:
        dateTime = Month.now();
        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CalendarSource(
      source: widget.source,
      child: Column(
        children: [
          CalendarHeader(
            title: title(),
            last: last,
            next: next,
            textStyle: widget.headerTextStyle,
          ),
          Expanded(
            child: page(),
          ),
        ],
        // ),
      ),
    );
  }
}
