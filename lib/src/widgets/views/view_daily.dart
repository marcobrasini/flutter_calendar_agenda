import 'package:calendar/src/utils/datetime.dart';
import 'package:flutter/material.dart';
import '../components/header_time.dart';
import '../frames/frame_daily.dart';
import '../../enums.dart';


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

  void onPageTap(Time tapped) {
    Time time = (widget.timeRound != null)
        ? tapped.round(widget.timeRound!)
        : tapped;
    print(widget.date & time);
  }

  double timeWidth(BuildContext context) {
    final style = widget.timeStyle ?? DefaultTextStyle.of(context).style;
    final layout = TextPainter(
      text: TextSpan(text: Time(0, 0).format(widget.timeFormat), style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return layout.width + (widget.timePadding ?? 0) * 2;
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
        final timeSlots = widget.toHour - widget.fromHour;
        final sizeHeight = (widget.rate == 0)
            ? constraints.maxHeight - margin
            : 60 * timeSlots * widget.rate;
        final sizeWidth = constraints.maxWidth;
        final dateWidth = sizeWidth - offset;
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
        final dayPage = SingleChildScrollView(
          child:Row(
            children: [
              timeHeader,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: offset / 2
                  ),
                  child: dayFrame,
                ),
              ),
            ],
          ),
        );
        return dayPage;
      },
    );
  }
}

