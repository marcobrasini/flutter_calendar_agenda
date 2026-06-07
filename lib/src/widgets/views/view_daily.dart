import 'package:flutter/material.dart';
import '../tools/header_time.dart';
import '../frames/frame_daily.dart';
import '../pages/page_daily.dart';
import '../../utils/datetime.dart';
import '../../context.dart';
import '../../config.dart';
import '../../utils/schemes.dart';


class DailyView extends StatelessWidget {

  const DailyView({
    super.key,
    required this.timeScheme,
    this.timeRound,
    this.cornerWidget,
  });

  final TimeScheme timeScheme;
  final int? timeRound;
  final Widget? cornerWidget;

  void onPageTap(int tapped) {
    Time time = Time(timeScheme.beg, tapped);
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
        final dayFrame = DailyFrame(
          width: pageWidth,
          height: pageHeight,
          header: headerFrame,
          padding: timeMargin/2,
          timeScheme: timeScheme,
          dailyTap: onPageTap,
        );
        final dayPage = DailyPage(
          width: pageWidth,
          height: pageHeight,
          padding: timeMargin/2,
          timeScheme: timeScheme,
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

