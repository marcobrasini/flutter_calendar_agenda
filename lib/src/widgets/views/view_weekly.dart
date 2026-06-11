import 'package:calendar/src/widgets/pages/page_viewer.dart';
import 'package:calendar/src/widgets/tools/header_weekly.dart';
import 'package:flutter/material.dart';
import '../tools/header_time.dart';
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
    required this.callbacks,
    //
    this.cornerWidget,
  });

  final DateScheme dateScheme;
  final TimeScheme timeScheme;
  final CallbackScheme callbacks;
  final Widget? cornerWidget;

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
                WeeklyHeader(
                  width: pageWidth,
                  scheme: dateScheme,
                ),
              ]
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
                        builder: (date) => WeeklyPage(
                          week: date.toWeek,
                          width: pageWidth,
                          height: pageHeight,
                          timeScheme: timeScheme,
                          dateScheme: dateScheme,
                          callbacks: callbacks,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
