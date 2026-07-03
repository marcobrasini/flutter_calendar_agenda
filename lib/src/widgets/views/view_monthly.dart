import 'package:flutter/material.dart';
import '../tools/header_monthly.dart';
import '../pages/page_viewer.dart';
import '../pages/page_monthly.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../context.dart';
import '../../config.dart';


class MonthlyView extends StatelessWidget {

  const MonthlyView({
    super.key,
    required this.dateScheme,
    required this.weekScheme,
    required this.callbacks,
    // Interactive callback
    this.cornerWidget,
  });


  final DateScheme dateScheme;
  final WeekScheme weekScheme;
  final CallbackScheme callbacks;
  final Widget? cornerWidget;

  void onPageTap(int tappedWeek, int tappedDay) {}

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final dateMargin = context.dateMargin();
        final dateOffset = context.dateOffset();
        final pageHeight = constraints.maxHeight - dateOffset;
        final pageWidth = constraints.maxWidth;
        return Column(
          children: [
            if (config.view.showHeader) MonthlyHeader(
              width: pageWidth,
              scheme: dateScheme,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: pageWidth,
                  height: pageHeight,
                  child: ViewerPage(
                    direction: config.view.swipeDirection,
                    builder: (datetime) => MonthlyPage(
                        month: datetime.toMonth,
                        width: pageWidth,
                        height: pageHeight,
                        dateScheme: dateScheme,
                        weekScheme: weekScheme,
                        callbacks: callbacks,
                      ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}

