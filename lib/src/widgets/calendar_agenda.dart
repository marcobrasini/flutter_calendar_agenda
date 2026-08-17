import 'package:calendar/calendar.dart';
import 'package:calendar/src/modifier.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:calendar/src/viewer.dart';
import 'package:calendar/src/widgets/agenda_registry.dart';
import 'package:calendar/src/widgets/agenda_scroller.dart';
import 'package:calendar/src/widgets/agenda_tile.dart';
import 'package:calendar/src/widgets/slots/slot_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar/src/enums.dart';


class CalendarAgenda extends StatefulWidget {
  const CalendarAgenda({
    super.key,
    required this.callbacks,
    required this.scrolling,
    this.dateScheme,
  });

  final CalendarScroll scrolling;
  final CallbackScheme callbacks;
  final DateScheme? dateScheme;

  @override
  State<CalendarAgenda> createState() => _CalendarAgendaState();
}

class _CalendarAgendaState extends State<CalendarAgenda> {
  final GlobalKey _viewportKey = GlobalKey();
  late final CalendarViewer _viewer;
  AgendaRegistry? _registry;

  @override
  void initState() {
    super.initState();
    _viewer =  context.read<CalendarViewer>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modifier = context.read<CalendarModifier>();
      final viewport = _viewportKey.currentContext?.findRenderObject();
      final content = _viewer.controller.key.currentContext?.findRenderObject();
      modifier.attachViewport(viewport as RenderBox);
      modifier.attachContent(content as RenderBox);
    });
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
        return Stack(
          key: _viewportKey,
          children: [
            AgendaScroller(
              key: _viewer.controller.key,
              direction: Axis.vertical,
              registry: registry,
              builder: (datetime, until) => AgendaTile(
                datetime: datetime,
                dateScheme: widget.dateScheme,
                callbacks: widget.callbacks,
                width: pageWidth,
                until: until,
              ),
            ),
            Builder(builder: (context) {
              final modifier = context.watch<CalendarModifier>();
              return SizedBox(
                width: pageWidth,
                height: pageHeight,
                child: (modifier.editing)
                    ? SlotEditor(
                      layout: modifier.layout!,
                    )
                    : SizedBox.shrink(),
              );
            }),
          ],
        );
      },
    );
  }
}
