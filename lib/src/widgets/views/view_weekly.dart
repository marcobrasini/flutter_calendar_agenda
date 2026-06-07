import 'package:flutter/material.dart';
import '../tools/header_time.dart';
import '../frames/frame_weekly.dart';
import '../pages/page_weekly.dart';
import '../../utils/datetime.dart';
import '../../context.dart';
import '../../config.dart';
import '../../utils/schemes.dart';


class WeeklyView extends StatelessWidget {

  const WeeklyView({
    super.key,
    required this.dateScheme,
    required this.timeScheme,
    this.timeRound,
    //
    this.cornerWidget,
  });

  // TimeHeader attributes
  final DateScheme dateScheme;
  final TimeScheme timeScheme;
  final int? timeRound;
  final Widget? cornerWidget;

  void onPageTap(int tappedDay, int tappedMinute) {
    // Date date = week.mon + tappedDay;
    Time time = Time(timeScheme.beg, tappedMinute);
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
        final pageHeight = (timeScheme.ratio == 0)
            ? constraints.maxHeight - timeMargin - dateOffset
            : timeScheme.minutes * timeScheme.ratio;
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
          scheme: timeScheme,
        );
        final weekFrame = WeeklyFrame(
          width: pageWidth,
          height: pageHeight,
          header: headerFrame,
          padding: timeMargin/2,
          dateScheme: dateScheme,
          timeScheme: timeScheme,
          weeklyTap: onPageTap,
        );
        final weekPage = WeeklyPage(
          width: pageWidth,
          height: pageHeight,
          padding: timeMargin/2,
          dateScheme: dateScheme,
          timeScheme: timeScheme,
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
