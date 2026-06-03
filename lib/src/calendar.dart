import 'package:calendar/src/const.dart';
import 'package:calendar/src/widgets/views/view_monthly.dart';
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
  final int begHour;
  final int endHour;
  final int timeStep;
  final int begDay;
  final int endDay;
  final int dateStep;
  final int begWeek;
  final int endWeek;
  final int weekStep;
  //
  final double timeRatio;
  final String timeFormat;
  final double timePadding;
  final TextStyle? timeTextStyle;
  final Color? timeBackground;
  //
  final String dateFormat;
  final double datePadding;
  final TextStyle? dateTextStyle;
  final Color? dateBackground;
  //
  final String dayFormat;
  final String weekFormat;
  final double weekPadding;
  final TextStyle? weekTextStyle;
  final Color? weekBackground;
  //
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;
  //
  final TextStyle? headerTextStyle;

  const Calendar({
    super.key,
    required this.view,
    required this.source,
    this.begHour = initialHour,
    this.endHour = finalHour,
    this.timeStep = stepHour,
    this.begDay = initialDay,
    this.endDay = finalDay,
    this.dateStep = stepDay,
    this.begWeek = initialWeek,
    this.endWeek = finalWeek,
    this.weekStep = stepWeek,
    //
    this.timeRatio = timeHeaderRatio,
    this.timeFormat = timeHeaderFormat,
    this.timePadding = timeHeaderPadding,
    this.timeTextStyle,
    this.timeBackground,
    //
    this.dateFormat = dateHeaderFormat,
    this.datePadding = dateHeaderPadding,
    this.dateTextStyle,
    this.dateBackground,
    //
    this.dayFormat = dayHeaderFormat,
    this.weekFormat = weekHeaderFormat,
    this.weekPadding = textHeaderPadding,
    this.weekTextStyle,
    this.weekBackground,
    //
    this.lineStyle = lineFrameStyle,
    this.lineColor = lineFrameColor,
    this.lineWidth = lineFrameWidth,
    this.lineOffsetX = lineFrameOffsetX,
    this.lineOffsetY = lineFrameOffsetY,
    this.dashedWidth,
    this.dashedSpace,
    //
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
          begHour: widget.begHour,
          endHour: widget.endHour,
          timeStep: widget.timeStep,
          timeRatio: widget.timeRatio,
          timeFormat: widget.timeFormat,
          timePadding: widget.timePadding,
          lineStyle: widget.lineStyle,
          lineColor: widget.lineColor,
          lineWidth: widget.lineWidth,
          lineOffset: widget.lineOffsetX,
          dashedWidth: widget.dashedWidth,
          dashedSpace: widget.dashedSpace,
        );
      case CalendarView.weekly:
        return WeeklyView(
          week: dateTime,
          begDay: widget.begDay,
          endDay: widget.endDay,
          dateStep: widget.dateStep,
          begHour: widget.begHour,
          endHour: widget.endHour,
          timeStep: widget.timeStep,
          timeRatio: widget.timeRatio,
          timeFormat: widget.timeFormat,
          timePadding: widget.timePadding,
          timeTextStyle: widget.timeTextStyle,
          timeBackground: widget.timeBackground,
          dateFormat: widget.dateFormat,
          datePadding: widget.datePadding,
          dateTextStyle: widget.dateTextStyle,
          dateBackground: widget.dateBackground,
          lineStyle: widget.lineStyle,
          lineColor: widget.lineColor,
          lineWidth: widget.lineWidth,
          lineOffsetX: widget.lineOffsetX,
          lineOffsetY: widget.lineOffsetY,
          dashedWidth: widget.dashedWidth,
          dashedSpace: widget.dashedSpace,
        );
      case CalendarView.monthly:
        return MonthlyView(
          month: dateTime,
          begWeek: widget.begWeek,
          endWeek: widget.endWeek,
          weekStep: widget.weekStep,
          begDay: widget.begDay,
          endDay: widget.endDay,
          dateStep: widget.dateStep,
          weekFormat: widget.weekFormat,
          weekPadding: widget.weekPadding,
          weekTextStyle: widget.weekTextStyle,
          weekBackground: widget.weekBackground,
          dateFormat: widget.dayFormat,
          datePadding: widget.datePadding,
          dateTextStyle: widget.dateTextStyle,
          dateBackground: widget.dateBackground,
          lineColor: widget.lineColor,
          lineStyle: widget.lineStyle,
          lineWidth: widget.lineWidth,
          lineOffsetX: widget.lineOffsetX,
          lineOffsetY: widget.lineOffsetY,
          dashedWidth: widget.dashedWidth,
          dashedSpace: widget.dashedSpace,
        );
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
