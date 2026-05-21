import 'package:flutter/material.dart';
import 'widgets/components/header_calendar.dart';
import 'widgets/pages/page_daily.dart';
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
        return dateTime.toString();
      case CalendarView.monthly:
        return dateTime.format("MMMM yyyy");
    }
  }

  Widget page() {
    switch (widget.view) {
      case CalendarView.daily:
        return DailyPage(
          textPadding: 16.0,
        );
      case CalendarView.weekly:
        return Placeholder();
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
