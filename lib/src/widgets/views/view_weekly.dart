import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/header_week.dart';
import 'package:calendar/src/widgets/pages/page_weekly.dart';
import 'package:flutter/material.dart';
import '../components/header_time.dart';
import '../frames/frame_weekly.dart';
import '../../enums.dart';


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

  void onPageTap(int tappedDay, Time tappedTime) {
    int day = tappedDay;
    Time time = (widget.timeRound != null)
        ? tappedTime.round(widget.timeRound!)
        : tappedTime;
    time += widget.fromHour * 60;
    print((widget.week.mon + day) & time);
  }

  double timeWidth(BuildContext context) {
    final style = widget.timeStyle ?? DefaultTextStyle.of(context).style;
    final layout = TextPainter(
      text: TextSpan(text: Time(0, 0).format(widget.timeFormat), style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return layout.width + (widget.timePadding ?? 0) * 2;
  }

  double dateWidth(BuildContext context) {
    final style = widget.timeStyle ?? DefaultTextStyle.of(context).style;
    final layout = TextPainter(
      text: TextSpan(text: Date.now().format(widget.dateFormat), style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return layout.height + (widget.datePadding ?? 0) * 2;
  }

  double timeMargin(BuildContext context) {
    final style = widget.timeStyle ?? DefaultTextStyle.of(context).style;
    return style.fontSize! * (style.height ?? 1.5);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final offset = timeWidth(context);
        final margin = timeMargin(context);
        final dateSlots = widget.toDay - widget.fromDay + 1;
        final timeSlots = widget.toHour - widget.fromHour;
        final sizeHeight = (widget.rate == 0)
            ? constraints.maxHeight - margin - dateWidth(context)
            : 60 * timeSlots * widget.rate;
        final sizeWidth = constraints.maxWidth;
        final weekWidth = sizeWidth - offset;
        final dateScale = dateSlots / weekWidth;
        final timeScale = 60 * timeSlots / sizeHeight;
        final timeHeader = TimeHeader(
          fromHour: widget.fromHour,
          toHour: widget.toHour,
          step: widget.step,
          margin: margin,
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
          step: widget.step,
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
          dateSlots: dateSlots,
          timeSlots: timeSlots,
          dateScale: dateScale,
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
          events: [
            Event.make(data: {
              "start": DateTime.now(),
              "stop": DateTime.now().add(Duration(hours: 1)),
              "color": Colors.pink,
              "subject": "Event",
            }),
            Event.make(data: {
              "start": DateTime.now().add(Duration(days: -2, hours: -4)),
              "stop": DateTime.now().add(Duration(days: -2, hours: -3)),
              "color": Colors.green,
              "subject": "Event",
            })
          ],
          width: weekWidth,
          height: sizeHeight,
          fromHour: widget.fromHour,
          dateScale: dateScale,
          timeScale: timeScale,
        );
        return Column(
          children: [
            Row(
              children: [
                SizedBox(width: timeWidth(context)),
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
                            vertical: margin / 2
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

