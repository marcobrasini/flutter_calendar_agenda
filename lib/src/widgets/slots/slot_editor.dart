import 'package:calendar/src/context.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/color.dart';
import '../../modifier.dart';
import '../../const.dart';
import '../../enums.dart';
import 'slot_layout.dart';
import 'slot_event.dart';


typedef EventBuilder = Widget Function(BuildContext);


class SlotEditor extends StatelessWidget {
  static const double shift = 0.3;
  static const double radius = 12.0;
  static const double hitRadius = 24.0;

  const SlotEditor({
    super.key,
    required this.layout,
    this.offset = Offset.zero,
    this.builder,
  });

  final SlotLayout layout;
  final Offset offset;
  final EventBuilder? builder;


  Widget _handle({
    required BuildContext context,
    required CalendarModifier modifier,
    required ResizeSide side,
    required Color color,
    required Offset center,
  }) {
    return Positioned(
      left: center.dx - hitRadius,
      top: center.dy - hitRadius,
      width: 2 * hitRadius,
      height: 2 * hitRadius,
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          EagerGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                () => EagerGestureRecognizer(),
                (_) {},
          ),
        },
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) {
            print(e);
            final box = context.findRenderObject() as RenderBox;
            modifier.enter(e.pointer, e.position, box.globalToLocal(e.position));
            modifier.take(modifier.layout!, SlotAction.resizing, side);
            modifier.start();
          },
          child: Center(
            child: Container(
              width: 2 * radius,
              height: 2 * radius,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modifier = context.watch<CalendarModifier>();
    final eventConfig = context.config.eventConfig();
    final colors = context.colors;
    final dimmer = (colors.brightness == Brightness.light)
        ?  eventSlotLineDimmed
        : -eventSlotLineDimmed;
    final layout = modifier.layout!;
    final container = modifier.container;
    final left = container.left + offset.dx;
    final top = container.top + offset.dy;
    final handleColor = layout.event.color.dimmer(dimmer);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => modifier.end(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: left,
            top: top,
            width: container.width,
            height: container.height,
            child: GestureDetector(
              onLongPress: () {
                modifier.take(modifier.layout!, SlotAction.dragging);
                modifier.start();
              },
              child: SlotEvent(event: layout.event, selected: true),
            ),
          ),
          if (modifier.isResizing)
            _handle(
              context: context,
              modifier: modifier,
              side: ResizeSide.before,
              color: handleColor,
              center: Offset(
                left + container.width * (0.5 + shift),
                top + eventConfig.eventMargin,
              ),
            ),
          if (modifier.isResizing)
            _handle(
              context: context,
              modifier: modifier,
              side: ResizeSide.after,
              color: handleColor,
              center: Offset(
                left + container.width * (0.5 - shift),
                top + container.height - eventConfig.eventMargin,
              ),
            ),
        ],
      ),
    );
  }
}
