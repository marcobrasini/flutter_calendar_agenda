import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/event.dart';
import '../../modifier.dart';
import '../../enums.dart';
import 'slot_layout.dart';
import 'slot_string.dart';
import 'slot_event.dart';


class DailySlot extends StatefulWidget {
  const DailySlot({
    super.key,
    required this.width,
    required this.height,
    required this.events,
    required this.timeScheme,
    required this.callbacks,
  });

  final double width;
  final double height;
  final List<Event> events;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  final CallbackScheme callbacks;

  List<SlotLayout> get layouts {
    final containers = <SlotLayout>[];
    for (final event in events) {
      final containerTop = _yOf(event) / timeScale;
      final containerHeight = event.duration.inMinutes / timeScale;
      final content = StringSlot(string: event.subject, width: width);
      containers.add(SlotLayout(
        event: event,
        container: Rect.fromLTWH(0, containerTop, width, containerHeight),
        content: content.layout,
      ));
    }
    final results = <SlotLayout>[];
    for (SlotLayout layout in containers) {
      for (final other in results) {
        if (layout.container.overlaps(other.container)) {
          if (layout.container.overlaps(other.safe)) {
            other.split += 1;
            layout.split = other.split;
            layout.order = other.order + 1;
          } else {
            layout.level = other.level + 1;
            layout.split = other.split;
            layout.order = other.order;
          }
        } else {
          layout.span = other.split - (layout.order+1);
        }
      }
      results.add(layout);
    }
    return results;
  }

  int _yOf(Event event) => event.start.time % Time.fromHour(timeScheme.beg);

  @override
  State<DailySlot> createState() => _DailySlotState();
}

class _DailySlotState extends State<DailySlot> {
  late final List<SlotLayout> _layouts;

  @override
  void initState() {
    super.initState();
    _layouts = widget.layouts;
  }
  
  bool isDragging(CalendarModifier modifier, SlotLayout layout) =>
      modifier.layout == layout && modifier.drawing 
          && modifier.action == SlotAction.dragging;

  bool isResizing(CalendarModifier modifier, SlotLayout layout) =>
      modifier.layout == layout && modifier.drawing
          && modifier.action == SlotAction.resizing;

  @override
  Widget build(BuildContext context) {
    final modifier = context.watch<CalendarModifier>();
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          for (final layout in _layouts)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: layout.top,
              left: (modifier.layout == layout) ? 0.0 : layout.left,
              width: (modifier.layout == layout) ? widget.width : layout.width,
              onEnd: () => modifier.modify(),
              child: GestureDetector(
                onDoubleTap: () {
                  widget.callbacks.onEventDoubleTap?.call(layout.event);
                  modifier.take(layout, SlotAction.resizing);
                  if (layout.isExpanded) modifier.modify();
                },
                onLongPress: () {
                  widget.callbacks.onEventLongPress?.call(layout.event);
                  modifier.take(layout, SlotAction.dragging);
                  if (layout.isExpanded) modifier.modify();
                },
                onTap: () {
                  widget.callbacks.onEventTap?.call(layout.event);
                  modifier.reset();
                },
                child: (isResizing(modifier, layout))
                    ? SizedBox.shrink()
                    : EventSlot(
                      layout: layout,
                      dragging: isDragging(modifier, layout),
                    ),
              ),
            ),
        ],
      ),
    );
  }
}