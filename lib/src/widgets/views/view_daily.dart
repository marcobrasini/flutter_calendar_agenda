import 'package:flutter/material.dart';
import '../tools/header_daily.dart';
import '../tools/header_time.dart';
import '../pages/page_daily.dart';
import '../pages/page_viewer.dart';
import '../../utils/datetime.dart';
import '../../context.dart';
import '../../config.dart';
import '../../utils/schemes.dart';


class DailyView extends StatelessWidget {

  const DailyView({
    super.key,
    required this.timeScheme,
    //
    this.cornerWidget,
  });

  final TimeScheme timeScheme;
  final Widget? cornerWidget;

  // void onPageTap(int tapped) {
  //   Time time = Time(timeScheme.beg, tapped);
  //   if (timeScheme.round != null) {
  //     time = time.round(timeScheme.round!);
  //   }
  //   print(time);
  // }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
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
        return Column(
          children: [
            if (config.view.showHeader) Row(
              children: [
                SizedBox(
                  width: timeOffset,
                  height: dateOffset,
                  child: cornerWidget,
                ),
                DailyHeader(
                  width: pageWidth,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView (
                child: Row (
                  children: [
                    TimeHeader(
                      width: timeOffset,
                      height: pageHeight,
                      scheme: timeScheme,
                    ),
                    SizedBox(
                      width: pageWidth,
                      height: pageHeight,
                      child: ViewerPage(
                        direction: config.view.swipeDirection,
                        builder: (date) => DailyPage(
                          date: date.date,
                          width: pageWidth,
                          height: pageHeight,
                          timeScheme: timeScheme,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        );
      },
    );
  }
}
