import 'package:calendar/src/context.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/header_week.dart';
import 'package:calendar/src/widgets/pages/page_weekly.dart';
import 'package:flutter/material.dart';
import '../components/header_time.dart';
import '../frames/frame_weekly.dart';
import '../../enums.dart';
import '../../data/source.dart';


class WeeklyView extends StatefulWidget {
  // TimeHeader attributes
  final Week week;
  final int fromDay;
  final int toDay;
  final int fromHour;
  final int toHour;
  final int step;
  final double rate;
  final String dateFormat;
  final String timeFormat;
  final double? datePadding;
  final double? timePadding;
  final TextStyle? dateStyle;
  final TextStyle? timeStyle;
  final Color? dateBackground;
  final Color? timeBackground;
  // LinePainter attributes
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;
  final int? timeRound;

  const WeeklyView({
    super.key,
    required this.week,
    this.fromDay = 1,
    this.toDay = 7,
    this.fromHour = 0,
    this.toHour = 24,
    this.step = 60,
    this.rate = 1.0,
    this.dateFormat = "EEE\nd",
    this.timeFormat = "HH:mm",
    this.datePadding,
    this.timePadding,
    this.dateStyle,
    this.timeStyle,
    this.dateBackground,
    this.timeBackground,
    this.lineColor = const Color(0xFFE0E0E0),
    this.lineStyle = LineStyle.solid,
    this.lineWidth = 1.0,
    this.lineOffsetX = 0.0,
    this.lineOffsetY = 0.0,
    this.dashedWidth,
    this.dashedSpace,
    this.timeRound,
  });

  @override
  State<WeeklyView> createState() => _WeeklyViewState();
}


class _WeeklyViewState extends State<WeeklyView> {

  void onPageTap(int tappedDay, int tappedMinute) {
    int day = tappedDay;
    Time time = Time(0, 0) + tappedMinute;
    if (widget.timeRound != null) {
      time = time.round(widget.timeRound!);
    }
    time += widget.fromHour * 60;
    print((widget.week.mon + day) & time);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final source = CalendarSource.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final dateOffset = context.dateWidth(widget.dateFormat, widget.dateStyle, widget.datePadding);
        final timeOffset = context.timeWidth(widget.timeFormat, widget.timeStyle, widget.timePadding);
        final timeMargin = context.timeMargin(widget.timeStyle);
        final daySlots = widget.toDay - widget.fromDay + 1;
        final timeSlots = widget.toHour - widget.fromHour;
        final sizeHeight = (widget.rate == 0)
            ? constraints.maxHeight - timeMargin - dateOffset
            : 60 * timeSlots * widget.rate;
        final sizeWidth = constraints.maxWidth;
        final weekWidth = sizeWidth - timeOffset;
        final dayScale = daySlots / weekWidth;
        final timeScale = 60 * timeSlots / sizeHeight;
        final timeHeader = TimeHeader(
          fromHour: widget.fromHour,
          toHour: widget.toHour,
          step: widget.step,
          margin: timeMargin,
          height: sizeHeight,
          background: widget.timeBackground,
          timeFormat: widget.timeFormat,
          timePadding: widget.timePadding,
          timeStyle: widget.timeStyle,
        );
        final weekHeader = WeekHeader(
          week: widget.week,
          fromDay: widget.fromDay,
          toDay: widget.toDay,
          width: weekWidth,
          background: widget.dateBackground,
          dateFormat: widget.dateFormat,
          datePadding: widget.datePadding,
          dateStyle: widget.dateStyle,
        );
        final weekFrame = WeeklyFrame(
          weeklyTap: onPageTap,
          width: weekWidth,
          height: sizeHeight,
          daySlots: daySlots,
          timeSlots: timeSlots,
          dayScale: dayScale,
          timeScale: timeScale,
          lineStyle: widget.lineStyle,
          lineColor: widget.lineColor,
          lineWidth: widget.lineWidth,
          lineOffsetX: widget.lineOffsetX - (widget.timePadding ?? 0)/2,
          lineOffsetY: widget.lineOffsetY - (widget.datePadding ?? 0)/2,
          dashedSpace: widget.dashedSpace,
          dashedWidth: widget.dashedWidth,
        );
        final weekPage = WeeklyPage(
          week: widget.week,
          events: source.forWeek(widget.week),
          width: weekWidth,
          height: sizeHeight,
          fromHour: widget.fromHour,
          dayScale: dayScale,
          timeScale: timeScale,
        );
        return Column(
          children: [
            Row(
              children: [
                SizedBox(width: timeOffset),
                weekHeader,
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    timeHeader,
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: timeMargin / 2
                        ),
                        child: Stack(
                            children: [
                              weekFrame,
                              weekPage,
                            ]
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
