import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import '../../utils/datetime.dart';


class AgendaHeader extends StatelessWidget {
  const AgendaHeader({
    super.key,
    required this.date,
    required this.width,
  });

  final Date date;
  final double width;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    return SizedBox(
      width: width,
      child: Text(
        date.format(config.date?.format ?? "EEEE dd"),
      )
    );
  }
}
