import 'package:calendar/src/data/source.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/pages/page_daily.dart';
import 'package:flutter/material.dart';
import '../components/header_time.dart';
import '../frames/frame_daily.dart';
import '../../enums.dart';
import '../../context.dart';


class DailyView extends StatefulWidget {
  // TimeHeader attributes
  final Date date;
  final int fromHour;
  final int toHour;
  final int step;
  final double rate;
  final String timeFormat;
  final double? timePadding;
  final TextStyle? timeStyle;
  final Color? timeBackground;
  // LinePainter attributes
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffset;
  final double? lineLength;
  final double? dashedWidth;
  final double? dashedSpace;
  final int? timeRound;

  const DailyView({
    super.key,
    required this.date,
    this.fromHour = 0,
    this.toHour = 24,
    this.step = 60,
    this.rate = 1.0,
    this.timeFormat = "HH:mm",
    this.timePadding,
    this.timeStyle,
    this.timeBackground,
    this.lineColor = const Color(0xFFE0E0E0),
    this.lineStyle = LineStyle.solid,
    this.lineWidth = 1.0,
    this.lineOffset = 0.0,
    this.lineLength,
    this.dashedWidth,
    this.dashedSpace,
    this.timeRound,
  });

  @override
  State<DailyView> createState() => _DailyViewState();
}


class _DailyViewState extends State<DailyView> {

  void onPageTap(int tapped) {
    Time time = Time.fromMinutes(tapped);
    if (widget.timeRound != null) {
      time = time.round(widget.timeRound!);
    }
    print(widget.date & time);
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
        final timeMargin = context.timeMargin(widget.timeStyle);
        final timeOffset = context.timeWidth(
            widget.timeFormat, widget.timeStyle, widget.timePadding
        );
        final timeSlots = widget.toHour - widget.fromHour;
        final sizeHeight = (widget.rate == 0)
            ? constraints.maxHeight - timeMargin
            : 60 * timeSlots * widget.rate;
        final sizeWidth = constraints.maxWidth;
        final dateWidth = sizeWidth - timeOffset;
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
        final dayFrame = DailyFrame(
          dailyTap: onPageTap,
          width: dateWidth,
          height: sizeHeight,
          timeSlots: timeSlots,
          timeScale: 60 * timeSlots / sizeHeight,
          lineStyle: widget.lineStyle,
          lineColor: widget.lineColor,
          lineWidth: widget.lineWidth,
          lineOffset: widget.lineOffset - (widget.timePadding ?? 0)/2,
          dashedSpace: widget.dashedSpace,
          dashedWidth: widget.dashedWidth,
        );
        final dayPage = DailyPage(
          date: widget.date,
          events: source.forDate(widget.date),
          width: dateWidth,
          height: sizeHeight,
          timeScale: 60 * timeSlots / sizeHeight,
          fromHour: widget.fromHour,
        );
        final dayView = Row(
          children: [
            timeHeader,
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: timeMargin / 2
                ),
                child: Stack(
                  children: [
                    dayFrame,
                    dayPage,
                  ],
                ),
              ),
            ),
          ],
        );
        return (widget.rate == 0) ? dayView : SingleChildScrollView(
          child: dayView,
        );
      },
    );
  }
}

