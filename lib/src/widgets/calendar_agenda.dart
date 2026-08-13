import 'package:calendar/calendar.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:calendar/src/viewer.dart';
import 'package:calendar/src/widgets/agenda_registry.dart';
import 'package:calendar/src/widgets/agenda_scroller.dart';
import 'package:calendar/src/widgets/agenda_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar/src/enums.dart';


class CalendarAgenda extends StatefulWidget {
  const CalendarAgenda({
    super.key,
    required this.callbacks,
    required this.scrolling,
    this.dateScheme = const DateScheme.weekly(),
  });

  final CalendarScroll scrolling;
  final CallbackScheme callbacks;
  final DateScheme dateScheme;

  @override
  State<CalendarAgenda> createState() => _CalendarAgendaState();
}

class _CalendarAgendaState extends State<CalendarAgenda> {
  late final CalendarViewer _viewer;
  AgendaRegistry? _registry;

  @override
  void initState() {
    super.initState();
    _viewer =  context.read<CalendarViewer>();
  }

  @override
  Widget build(BuildContext context) {
    final registry = _registry ??= AgendaRegistry(
      viewer: _viewer,
      dateScheme: widget.dateScheme,
      direction: Axis.vertical,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageHeight = constraints.maxHeight;
        final pageWidth = constraints.maxWidth;
        registry.resize(pageWidth, pageHeight);
        return AgendaScroller(
          direction: Axis.vertical,
          registry: registry,
          builder: (datetime, until) => AgendaTile(
            datetime: datetime,
            callbacks: widget.callbacks,
            width: pageWidth,
            until: until,
          ),
        );
      },
    );
  }
}
