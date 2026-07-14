import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/slot_date.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../viewer.dart';
import '../../config.dart';



class PageHeader extends StatelessWidget {

  const PageHeader({
    super.key,
    required this.width,
    required this.height,
    required this.scheme,
    this.controller,
  });

  final double width;
  final double height;
  final DateScheme scheme;
  final PageController? controller;

  List<Date> dates(Date date) {
    final dateList = <Date>[];
    Date start = date + scheme.beg;
    for (int i = 0 ; i < scheme.count ; i++) {
      dateList.add(start + i);
    }
    return dateList;
  }

  List<Widget> slots(DateTime datetime, dateConfig) {
    final widgets = <Widget>[];
    for (Date date in dates(datetime.date)) {
      widgets.add(Expanded(
          child: DateSlot(
            date: date,
            dateFormat: dateConfig.format,
            datePadding: dateConfig.padding,
            dateTextStyle: dateConfig.textStyle,
            dateBackground: dateConfig.background,
          )
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final dateConfig = CalendarConfig.of(context)!.date!;
    final viewer = context.watch<CalendarViewer>();
    final date = viewer.asDate;
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
                      child: Row(
                        children: slots(date + (i - 1) * scheme.step, dateConfig),
                      ),
                    ),
                ],
              );
            })
            : Row(
          children: slots(date, dateConfig),
        ),
      ),
    );
  }
}
