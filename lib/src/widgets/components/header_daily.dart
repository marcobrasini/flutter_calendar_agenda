import 'package:flutter/material.dart';
import '../components/slot_date.dart';
import '../../utils/datetime.dart';


class DailyHeader extends StatelessWidget {

  const DailyHeader({
    super.key,
    required this.date,
    required this.dateFormat,
    required this.datePadding,
    this.dateTextStyle,
    this.background,
    this.width,
    this.height,
  });

  final Date date;
  final String dateFormat;
  final double datePadding;
  final TextStyle? dateTextStyle;
  final Color? background;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DateSlot(
        date: date,
        dateFormat: dateFormat,
        datePadding: datePadding,
        dateTextStyle: dateTextStyle,
        dateBackground: background,
      ),
    );
  }
}
