import 'package:flutter/material.dart';
import '../frames/frame_monthly.dart';
import '../pages/page_monthly.dart';
import '../../context.dart';
import '../../enums.dart';
import '../../mixin.dart';


class MonthlyView extends StatelessWidget with WeekScheme, DateScheme {

  const MonthlyView({
    super.key,
    required this.begWeek,
    required this.endWeek,
    required this.weekStep,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    // Interactive callback
    this.cornerWidget,
  });

  // TimeHeader attributes
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  @override final int begWeek;
  @override final int endWeek;
  @override final int weekStep;
  final Widget? cornerWidget;

  void onPageTap(int tappedWeek, int tappedDay) {
    print("$tappedWeek $tappedDay");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dateMargin = context.dateMargin();
        final dateOffset = context.dateOffset();
        final pageHeight = constraints.maxHeight - dateOffset;
        final pageWidth = constraints.maxWidth;
        final headerFrame = SizedBox(
          width: pageWidth,
          height: dateOffset,
        );
        final monthFrame = MonthlyFrame(
          width: pageWidth,
          height: pageHeight,
          header: headerFrame,
          padding: dateMargin/2,
          begWeek: begWeek,
          endWeek: endWeek,
          weekStep: weekStep,
          begDay: begDay,
          endDay: endDay,
          dateStep: dateStep,
          monthlyTap: onPageTap,
        );
        final monthPage = MonthlyPage(
          width: pageWidth,
          height: pageHeight,
          padding: dateMargin/2,
          begWeek: begWeek,
          endWeek: endWeek,
          weekStep: weekStep,
          begDay: begDay,
          endDay: endDay,
          dateStep: dateStep,
        );
        final monthView = Stack(
            children: [
              monthFrame,
              monthPage,
            ]
        );
        return SingleChildScrollView(
          child: monthView,
        );
      },
    );
  }
}

