import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/event.dart';
import '../../enums.dart';
import '../../const.dart';
import 'slot_layout.dart';
import 'slot_string.dart';
import 'slot_draggable.dart';


class DailySlot extends StatefulWidget {
  const DailySlot({
    super.key,
    required this.width,
    required this.height,
    required this.events,
    required this.timeScheme,
    required this.callbacks,
    required this.onDropped,
  });

  final double width;
  final double height;
  final List<Event> events;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  final CallbackScheme callbacks;
  final LayoutCallback onDropped;

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
  SlotAction _action = SlotAction.none;
  SlotLayout? _expanded;
  Event? _selected;

  @override
  void initState() {
    super.initState();
    _layouts = widget.layouts;
  }

  void _reset() {
    _layouts.map((l) => l.expanded = false);
    setState(() {
      _expanded = null;
      _selected = null;
      _action = SlotAction.none;
    });
  }

  void _expand(SlotLayout layout, [SlotAction action = SlotAction.none]) {
    if (action == SlotAction.resizing) layout.expanded = true;
    setState(() {
      _action = action;
      _expanded = layout;
      _selected = layout.isExpanded ? layout.event : null;
    });
  }

  void _modify(SlotLayout layout) {
    if (_expanded == layout && _selected == null) {
      setState(() {
        _selected = layout.event;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          for (final layout in _layouts)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: layout.top,
              left: (_expanded == layout) ? 0.0 : layout.left,
              width: (_expanded == layout) ? widget.width : layout.width,
              onEnd: () => _modify(layout),
              child: GestureDetector(
                onDoubleTap: () => _expand(layout, SlotAction.resizing),
                onLongPressStart: (_) => _expand(layout, SlotAction.dragging),
                onLongPressEnd: (_) => _reset(),
                onTap: () {
                  widget.callbacks.onEventTap?.call(layout.event);
                  _reset();
                },
                child: SlotDraggable(
                  key: ValueKey(layout.event),
                  layout: layout,
                  draggable: config.event.draggable && (_selected == layout.event),
                  resizable: config.event.resizable,
                  onDragEnd: (position) {
                    widget.onDropped(position, layout.event);
                    layout.expanded = false;
                    _reset();
                  },
                  onDragCancel: () => _reset(),
                )
              ),
            ),
        ],
      ),
    );
  }
}
