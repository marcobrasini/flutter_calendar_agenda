import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/header_daily.dart';
import '../tools/header_time.dart';
import '../pages/page_viewer.dart';
import '../pages/page_daily.dart';
import '../pages/page_drag.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../controller.dart';
import '../../modifier.dart';
import '../../context.dart';
import '../../config.dart';


class DailyView extends StatelessWidget {

  const DailyView({
    super.key,
    required this.timeScheme,
    required this.callbacks,
    //
    this.cornerWidget,
  });

  final TimeScheme timeScheme;
  final CallbackScheme callbacks;
  final Widget? cornerWidget;

  // DateTime _dateTime(CalendarController controller, double timeScale, Offset local) {
  //   final step = timeScheme.round ?? 1;
  //   final minutes = (local.dy * timeScale / step).round() * step;
  //   final time = Time.fromHour(timeScheme.beg) + minutes;
  //   return controller.asDate & time;
  // }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final controller = context.read<CalendarController>();

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
                      child: Consumer<CalendarModifier>(
                        builder: (context, modifier, _) {
                          modifier.attachConverter((Offset local) {
                            final step = timeScheme.round ?? 1;
                            final timeScale = timeScheme.scale(pageHeight);
                            final minutes = (local.dy * timeScale / step).round() * step;
                            final time = Time.fromHour(timeScheme.beg) + minutes;
                            return controller.asDate & time;
                          });
                          return Stack(
                            children: [
                              ViewerPage(
                                direction: config.view.swipeDirection,
                                builder: (date) => DailyPage(
                                  date: date.date,
                                  width: pageWidth,
                                  height: pageHeight,
                                  timeScheme: timeScheme,
                                  callbacks: callbacks,
                                ),
                              ),
                              DropPage(
                                width: pageWidth,
                                height: pageHeight,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
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
