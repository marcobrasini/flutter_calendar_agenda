import 'package:calendar/src/metrics.dart';
import 'package:calendar/src/widgets/agenda/agenda_header.dart';
import 'package:calendar/src/widgets/agenda/agenda_slot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../source.dart';


class WidgetAgenda extends StatelessWidget {

  const WidgetAgenda({
    super.key,
    required this.date,
    required this.width,
    required this.callbacks,
    required this.dateScheme,
    required this.converter,
  });

  final Date date;
  final double width;
  final CallbackScheme callbacks;
  final OffsetConverter converter;
  final DateScheme dateScheme;

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarEvents>();
    return Stack(
      children: [
        for (int i = dateScheme.beg; i < dateScheme.end; i++)
          Column(
            children: [
              AgendaHeader(date: date + i, width: width),
              AgendaSlot(date: date, width: width, callbacks: callbacks)
            ],
          )
      ],
    );
  }
}
