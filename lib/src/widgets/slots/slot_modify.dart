import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/color.dart';
import '../../modifier.dart';
import '../../config.dart';
import '../../const.dart';
import '../../enums.dart';
import 'slot_layout.dart';
import 'slot_event.dart';


typedef EventBuilder = Widget Function(BuildContext);


class EditableSlot extends StatelessWidget {
  const EditableSlot({
    super.key,
    required this.layout,
    this.builder,
  });

  final SlotLayout layout;
  final EventBuilder? builder;
  final double radius = 10.0;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final offset = config.view.indicatorRadius;
    final modifier = context.watch<CalendarModifier>();
    final layout = modifier.layout!;
    final container = modifier.container;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => modifier.end(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: container.left + offset,
            top: container.top,
            width: container.width,
            height: container.height,
            child: GestureDetector(
              onLongPress: () {
                modifier.take(modifier.layout!, SlotAction.dragging);
                modifier.start();
              },
              child: EventSlot(layout: layout, selected: true),
            ),
          ),
          if (modifier.isResizing) Positioned(
              left: container.left + container.width / 2 - radius + offset,
              top: container.top - radius,
              width: 2 * radius,
              height: 2 * radius,
              child: GestureDetector(
                onLongPress: () {
                  modifier.take(
                      modifier.layout!, SlotAction.resizing, ResizeSide.before
                  );
                  modifier.start();
                },
                child: Listener(
                  onPointerDown: (pointerEvent) {
                    final box = context.findRenderObject() as RenderBox;
                    modifier.enter(
                        pointerEvent.pointer,
                        pointerEvent.position,
                        box.globalToLocal(pointerEvent.position)
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: layout.event.color.dimmer(eventSlotLineDimmed),
                    ),
                  ),
                ),
              )
          ),
          if (modifier.isResizing) Positioned(
              left: container.left + container.width / 2 - radius + offset,
              top: container.top + container.height - radius,
              width: 2 * radius,
              height: 2 * radius,
              child: GestureDetector(
                onLongPress: () {
                  modifier.take(
                      modifier.layout!, SlotAction.resizing, ResizeSide.after
                  );
                  modifier.start();
                },
                child: Listener(
                  onPointerDown: (pointerEvent) {
                    final box = context.findRenderObject() as RenderBox;
                    modifier.enter(
                        pointerEvent.pointer,
                        pointerEvent.position,
                        box.globalToLocal(pointerEvent.position),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: layout.event.color.dimmer(eventSlotLineDimmed),
                    ),
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }
}