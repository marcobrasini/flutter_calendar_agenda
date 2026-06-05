import 'package:calendar/src/utils/datetime.dart';
import 'package:flutter/material.dart';


class DateSlot extends StatelessWidget {

  const DateSlot({
    super.key,
    this.width,
    this.height,
    required this.date,
    required this.dateFormat,
    required this.datePadding,
    this.dateTextStyle,
    this.dateBackground,
    this.dateWidget,
  });

  final Date date;
  final double? width;
  final double? height;
  final String dateFormat;
  final double datePadding;
  final TextStyle? dateTextStyle;
  final Color? dateBackground;
  final Widget? dateWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: dateBackground,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              vertical: datePadding,
            ),
            child: Center (
              child: Text(
                date.format(dateFormat),
                textAlign: TextAlign.center,
                style: dateTextStyle,
              ),
            ),
          ),
          ?dateWidget,
        ],
      ),
    );
  }

}