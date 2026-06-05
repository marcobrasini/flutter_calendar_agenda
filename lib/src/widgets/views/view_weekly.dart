import 'package:flutter/material.dart';
import '../tools/header_time.dart';
import '../frames/frame_weekly.dart';
import '../pages/page_weekly.dart';
import '../../utils/datetime.dart';
import '../../context.dart';
import '../../config.dart';
import '../../mixin.dart';


class WeeklyView extends StatelessWidget with DateScheme, TimeScheme {

  const WeeklyView({
    super.key,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    required this.timeRatio,
    this.timeRound,
    //
    this.cornerWidget,
  });

  // TimeHeader attributes
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  final double timeRatio;
  final int? timeRound;
  final Widget? cornerWidget;

  void onPageTap(int tappedDay, int tappedMinute) {
    // Date date = week.mon + tappedDay;
    Time time = Time(begHour, tappedMinute);
    if (timeRound != null) {
      time = time.round(timeRound!);
    }
    print(time);
  }

  @override
  Widget build(BuildContext context) {
    final viewConfig = CalendarConfig.of(context)!.view;
    return LayoutBuilder(
      builder: (context, constraints) {
        final timeMargin = context.timeMargin();
        final timeOffset = context.timeOffset();
        final dateOffset = context.dateOffset();
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
        );
        final weekFrame = WeeklyFrame(
          width: pageWidth,
          height: pageHeight,
          header: headerFrame,
          padding: timeMargin/2,
          begDay: begDay,
          endDay: endDay,
          dateStep: dateStep,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
          weeklyTap: onPageTap,
        );
        final weekPage = WeeklyPage(
          width: pageWidth,
          height: pageHeight,
          padding: timeMargin/2,
          begDay: begDay,
          endDay: endDay,
          dateStep: dateStep,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
        );
        final weekView = Row(
          children: [
            Column(
              children: [
                if (viewConfig.showHeader) cornerFrame,
                timeHeader,
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  weekFrame,
                  weekPage,
                ]
              ),
            ),
          ],
        );
        return SingleChildScrollView(
          child: weekView,
        );
      },
    );
  }
}
