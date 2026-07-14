import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/slot_date.dart';
import '../../viewer.dart';
import '../../config.dart';


class DailyHeader extends StatelessWidget {

  const DailyHeader({
    super.key,
    required this.width,
    required this.height,
    this.controller,
  });

  final double width;
  final double height;
  final PageController? controller;

  @override
  Widget build(BuildContext context) {
    final dateConfig = CalendarConfig.of(context)!.date!;
    final viewer = context.watch<CalendarViewer>();
    final actual = viewer.asDate;
    return ClipRect(
      child: SizedBox(
        width: width,
        height: height,
        child: (controller != null)
            ? AnimatedBuilder(
            animation: controller!,
            builder: (context, _) {
              double page = 1.0;
              if (controller!.hasClients
                  && controller!.position.haveDimensions) {
                page = controller!.page ?? 1.0;
              }
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (int i in [0, 1, 2])
                    Positioned(
                      left: (i - page) * width,
                      top: 0,
                      width: width,
                      height: height,
                      child: DateSlot(
                        date: actual + (i - 1),
                        dateFormat: dateConfig.format,
                        datePadding: dateConfig.padding,
                        dateTextStyle: dateConfig.textStyle,
                        dateBackground: dateConfig.background,
                      ),
                    ),
                ],
              );
            })
            : DateSlot(
          date: actual,
          dateFormat: dateConfig.format,
          datePadding: dateConfig.padding,
          dateTextStyle: dateConfig.textStyle,
          dateBackground: dateConfig.background,
        ),
      ),
    );
  }
}
