import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'slots/slot_editor.dart';
import '../utils/schemes.dart';
import '../modifier.dart';
import '../viewer.dart';
import '../enums.dart';
import 'agenda_registry.dart';
import 'agenda_scroller.dart';
import 'agenda_tile.dart';


class CalendarAgenda extends StatefulWidget {
  const CalendarAgenda({
    super.key,
    required this.scrolling,
    this.dateScheme,
  });

  final CalendarScroll scrolling;
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
      final content = _viewer.scroller.key.currentContext?.findRenderObject();
      modifier.attachViewport(_viewportKey);
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
              key: _viewer.scroller.key,
              direction: Axis.vertical,
              registry: registry,
              builder: (datetime, until) => AgendaTile(
                datetime: datetime,
                dateScheme: widget.dateScheme,
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
