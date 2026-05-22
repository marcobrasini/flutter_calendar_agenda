import 'package:calendar/src/widgets/views/view_daily.dart';
import 'package:calendar/src/widgets/views/view_weekly.dart';
import 'package:flutter/material.dart';
import 'widgets/components/header_calendar.dart';
import 'utils/datetime.dart';
import 'enums.dart';


class Calendar extends StatefulWidget {
  final CalendarView view;
  final TextStyle? headerTextStyle;
  const Calendar({
    super.key,
    required this.view,
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
        return "${start} -- ${stop}";
      case CalendarView.monthly:
        return dateTime.format("MMMM yyyy");
    }
  }

  Widget page() {
    switch (widget.view) {
      case CalendarView.daily:
        return DailyView(
          date: dateTime,
          timePadding: 8.0,
        );
      case CalendarView.weekly:
        return WeeklyView(
          week: dateTime,
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
    return Column(
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
    );
  }
}
