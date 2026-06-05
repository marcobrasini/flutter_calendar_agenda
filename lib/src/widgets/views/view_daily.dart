import 'package:flutter/material.dart';
import '../tools/header_time.dart';
import '../frames/frame_daily.dart';
import '../pages/page_daily.dart';
import '../../utils/datetime.dart';
import '../../context.dart';
import '../../config.dart';
import '../../mixin.dart';


class DailyView extends StatelessWidget with TimeScheme {

  const DailyView({
    super.key,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    required this.timeRatio,
    this.timeRound,
    this.cornerWidget,
  });

  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  final double timeRatio;
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
        final dayFrame = DailyFrame(
          width: pageWidth,
          height: pageHeight,
          header: headerFrame,
          padding: timeMargin/2,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
          dailyTap: onPageTap,
        );
        final dayPage = DailyPage(
          width: pageWidth,
          height: pageHeight,
          padding: timeMargin/2,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
        );
        final dayView = Row(
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

