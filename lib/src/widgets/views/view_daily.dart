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


class DailyView extends StatelessWidget with TimeScheme {

  const DailyView({
    super.key,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    // TimeHeader attributes
    required this.timeRatio,
    required this.timeFormat,
    required this.timePadding,
    this.timeTextStyle,
    this.timeBackground,
    // DateHeader attributes
    required this.dailyFormat,
    required this.dailyPadding,
    this.dailyTextStyle,
    this.dailyBackground,
    // LinePainter attributes
    required this.lineColor,
    required this.lineStyle,
    required this.lineWidth,
    required this.lineOffset,
    this.dashedWidth,
    this.dashedSpace,
    // Interactive callback
    this.timeRound,
    //
    this.cornerWidget,
  });

  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  final double timeRatio;
  // TimeHeader attributes
  final String timeFormat;
  final double timePadding;
  final TextStyle? timeTextStyle;
  final Color? timeBackground;
  // DayHeader attributes
  final String dailyFormat;
  final double dailyPadding;
  final TextStyle? dailyTextStyle;
  final Color? dailyBackground;
  // LinePainter attributes
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffset;
  final double? dashedWidth;
  final double? dashedSpace;
  final int? timeRound;
  final Widget? cornerWidget;



  void onPageTap(int tapped) {
    Time time = Time(begHour, tapped);
    if (timeRound != null) {
      time = time.round(timeRound!);
    }
    print(time);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final timeMargin = context.timeMargin(timeTextStyle);
        final timeOffset = context.timeWidth(
            timeFormat, timeTextStyle, timePadding);
        final dateOffset = context.dateWidth(
            dailyFormat, dailyTextStyle, dailyPadding);
        //
        final pageHeight = (timeRatio == 0)
            ? constraints.maxHeight - timeMargin - dateOffset
            : minutes * timeRatio;
        final pageWidth = constraints.maxWidth - timeOffset;
        //
        final cornerFrame = SizedBox(
          width: timeOffset,
          height: dateOffset,
          child: cornerWidget,
        );
        final headerFrame = SizedBox(
          width: pageWidth,
          height: dateOffset,
        );
        final timeHeader = TimeHeader(
          width: timeOffset,
          height: pageHeight,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
          timeFormat: timeFormat,
          timePadding: timePadding,
          timeTextStyle: timeTextStyle,
          background: timeBackground,
        );
        final dayFrame = DailyFrame(
          width: pageWidth,
          height: pageHeight,
          header: headerFrame,
          padding: timeMargin/2,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
          lineStyle: lineStyle,
          lineColor: lineColor,
          lineWidth: lineWidth,
          lineOffsetX: lineOffset - timePadding/2,
          lineOffsetY: lineOffset,
          dashedSpace: dashedSpace,
          dashedWidth: dashedWidth,
          dailyTap: onPageTap,
        );
        final dayPage = DailyPage(
          width: pageWidth,
          height: pageHeight,
          padding: timeMargin/2,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
          dateFormat: dailyFormat,
          datePadding: dailyPadding,
          dateTextStyle: dailyTextStyle,
          dateBackground: dailyBackground,
        );
        final dayView = Row(
          children: [
            Column(
              children: [
                cornerFrame,
                timeHeader,
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  dayFrame,
                  dayPage,
                ],
              ),
            ),
          ],
        );
        return SingleChildScrollView(
          child: dayView,
        );
      },
    );
  }
}

