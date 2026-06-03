import 'package:calendar/src/const.dart';
import 'package:calendar/src/data/source.dart';
import 'package:calendar/src/mixin.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/pages/page_daily.dart';
import 'package:flutter/material.dart';
import '../components/header_time.dart';
import '../frames/frame_daily.dart';
import '../../enums.dart';
import '../../context.dart';


class DailyView extends StatefulWidget with TimeScheme {

  const DailyView({
    super.key,
    required this.date,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    // TimeHeader attributes
    required this.timeRatio,
    required this.timeFormat,
    this.timePadding,
    this.timeTextStyle,
    this.timeBackground,
    // LinePainter attributes
    required this.lineColor,
    required this.lineStyle,
    required this.lineWidth,
    required this.lineOffset,
    this.dashedWidth,
    this.dashedSpace,
    this.timeRound,
  });

  final Date date;
  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  final double timeRatio;
  // TimeHeader attributes
  final String timeFormat;
  final double? timePadding;
  final TextStyle? timeTextStyle;
  final Color? timeBackground;
  // LinePainter attributes
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffset;
  final double? dashedWidth;
  final double? dashedSpace;
  final int? timeRound;

  @override
  State<DailyView> createState() => _DailyViewState();
}


class _DailyViewState extends State<DailyView> {

  void onPageTap(int tapped) {
    Time time = Time(widget.begHour, tapped);
    if (widget.timeRound != null) {
      time = time.round(widget.timeRound!);
    }
    print(widget.date & time);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final timeMargin = context.timeMargin(widget.timeTextStyle);
        final timeOffset = context.timeWidth(
            widget.timeFormat, widget.timeTextStyle, widget.timePadding
        );
        //
        final sizeHeight = (widget.timeRatio == 0)
            ? constraints.maxHeight - timeMargin
            : widget.minutes * widget.timeRatio;
        final sizeWidth = constraints.maxWidth - timeOffset;
        //
        final timeHeader = TimeHeader(
          begHour: widget.begHour,
          endHour: widget.endHour,
          timeStep: widget.timeStep,
          height: sizeHeight,
          timeFormat: widget.timeFormat,
          timePadding: widget.timePadding,
          timeTextStyle: widget.timeTextStyle,
          background: widget.timeBackground,
        );
        final dayFrame = DailyFrame(
          width: sizeWidth,
          height: sizeHeight,
          begHour: widget.begHour,
          endHour: widget.endHour,
          timeStep: widget.timeStep,
          lineStyle: widget.lineStyle,
          lineColor: widget.lineColor,
          lineWidth: widget.lineWidth,
          lineOffsetX: widget.lineOffset - (widget.timePadding ?? 0)/2,
          lineOffsetY: widget.lineOffset,
          dashedSpace: widget.dashedSpace,
          dashedWidth: widget.dashedWidth,
          dailyTap: onPageTap,
        );
        final dayPage = DailyPage(
          date: widget.date,
          width: sizeWidth,
          height: sizeHeight,
          begHour: widget.begHour,
          endHour: widget.endHour,
          timeStep: widget.timeStep,
        );
        final dayView = Row(
          children: [
            timeHeader,
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: timeMargin / 2,
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
        return (widget.timeRatio == 0) ? dayView : SingleChildScrollView(
          child: dayView,
        );
      },
    );
  }
}

