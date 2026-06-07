import 'package:flutter/material.dart';
import '../frames/frame_monthly.dart';
import '../pages/page_monthly.dart';
import '../../context.dart';
import '../../utils/schemes.dart';


class MonthlyView extends StatelessWidget {

  const MonthlyView({
    super.key,
    required this.dateScheme,
    required this.weekScheme,
    // Interactive callback
    this.cornerWidget,
  });


  final DateScheme dateScheme;
  final WeekScheme weekScheme;
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
          dateScheme: dateScheme,
          weekScheme: weekScheme,
          monthlyTap: onPageTap,
        );
        final monthPage = MonthlyPage(
          width: pageWidth,
          height: pageHeight,
          padding: dateMargin/2,
          dateScheme: dateScheme,
          weekScheme: weekScheme,
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

