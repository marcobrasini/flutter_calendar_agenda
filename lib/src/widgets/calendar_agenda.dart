import 'package:calendar/calendar.dart';
import 'package:calendar/src/config.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:calendar/src/viewer.dart';
import 'package:calendar/src/widgets/agenda_metrics.dart';
import 'package:calendar/src/widgets/agenda_scroller.dart';
import 'package:calendar/src/widgets/agenda_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:calendar/src/enums.dart';


class CalendarAgenda extends StatefulWidget {
  const CalendarAgenda({
    super.key,
    required this.callbacks,
    required this.scrolling,
  });

  final CalendarScroll scrolling;
  final CallbackScheme callbacks;

  @override
  State<CalendarAgenda> createState() => _CalendarAgendaState();
}

class _CalendarAgendaState extends State<CalendarAgenda> {
  late final CalendarViewer _viewer;

  CalendarController get _controller => _viewer.controller;

  @override
  void initState() {
    super.initState();
    _viewer =  context.read<CalendarViewer>();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return AgendaScroller(
          direction: Axis.vertical,
          controller: _controller,
          metrics: AgendaMetrics(),
          breakpoint: CalendarConfig.of(context).event.extent,
          builder: (context, datetime) => AgendaTile(
            datetime: datetime,
            callbacks: widget.callbacks,
            width: constraint.maxWidth,
          ),
        );
      },
    );
  }
}
