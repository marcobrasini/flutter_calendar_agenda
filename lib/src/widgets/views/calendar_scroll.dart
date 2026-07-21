import 'package:calendar/src/config.dart';
import 'package:calendar/src/context.dart';
import 'package:calendar/src/modifier.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/scroll/scroll_viewer.dart';
import 'package:calendar/src/widgets/scroll/scroll_widget.dart';
import 'package:calendar/src/widgets/slots/slot_editor.dart';
import 'package:calendar/src/widgets/views/view_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CalendarScroll extends StatefulWidget {
  const CalendarScroll({
    super.key,
    required this.dateScheme,
    required this.callbacks,
  });

  final DateScheme dateScheme;
  final CallbackScheme callbacks;

  @override
  State<CalendarScroll> createState() => _CalendarScrollState();
}

class _CalendarScrollState extends State<CalendarScroll> {
  final _scroller = ScrollController();
  final _keyScroll = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modifier = context.read<CalendarModifier>();
      final renderer = _keyScroll.currentContext?.findRenderObject();
      // modifier.attachRenderer(renderer as RenderBox);
      // modifier.attachSlider(_scroller);
      // modifier.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final dateOffset = context.dateOffset();
        final pageWidth = constraints.maxWidth;
        final pageHeight = constraints.maxHeight - dateOffset;
        final space = pageHeight / 6;
        return Column(
          children: [
            if (config.view.showHeader) SizedBox(
              width: pageWidth,
              height: dateOffset,
              child: ViewHeader(
                width: dateOffset,
                height: pageHeight,
                scheme: widget.dateScheme,
                config: config.week!,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ScrollViewer(
                    controller: _scroller,
                    direction: config.view.swipeDirection,
                    adapter: (datetime, index) => datetime.weekStart.date + index * widget.dateScheme.step,
                    snapper: (datetime) => (datetime.date - 1).month != (datetime.date + 6).month,
                    cache: pageHeight,
                    builder: (key, datetime, offset) => ScrollWidget(
                      key: key,
                      date: datetime.date,
                      width: pageWidth,
                      height: space,
                      callbacks: widget.callbacks,
                      timeScheme: TimeScheme.allDay(),
                      dateScheme: DateScheme.weekly(),
                      offset: offset,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final modifier = context.watch<CalendarModifier>();
                      return SizedBox(
                        width: pageWidth,
                        height: pageHeight,
                        child: (modifier.editing)
                            ? SlotEditor(layout: modifier.layout!)
                            : SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}