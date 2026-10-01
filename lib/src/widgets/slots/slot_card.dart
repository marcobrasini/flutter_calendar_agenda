import 'package:calendar/src/config.dart';
import 'package:calendar/src/const.dart';
import 'package:calendar/src/modifier.dart';
import 'package:calendar/src/widgets/slots/slot_event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/fixture.dart';


class SlotCard extends StatelessWidget {
  const SlotCard({
    super.key,
    required this.event,
    this.onEventSwipedLeft,
    this.onEventSwipedRight,
    this.width,
    this.height,
  });

  final Event event;
  final ModifyCallback? onEventSwipedLeft;
  final ModifyCallback? onEventSwipedRight;
  final double? width;
  final double? height;
  Fixture get fixture => event as Fixture;
  bool get left => onEventSwipedLeft != null;
  bool get right => onEventSwipedRight != null;

  DismissDirection get swipe {
    if (left && right)  return DismissDirection.horizontal;
    if (left)   return DismissDirection.startToEnd;
    if (right)  return DismissDirection.endToStart;
    return DismissDirection.none;
  }

  SwipeCard? get leftCard => left ? SwipeCard.left() : null;

  SwipeCard? get rightCard => right ? SwipeCard.right() : null;

  @override
  Widget build(BuildContext context) {
    final modifier = context.read<CalendarModifier>();
    final config = CalendarConfig.of(context).event;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(config.eventPadding),
      child: Material(
        elevation: 1.0,
        borderRadius: BorderRadius.all(Radius.circular(config.eventRounded)),
        clipBehavior: Clip.antiAlias,
        color: scheme.surfaceContainerLow,
        child: Dismissible(
          key: ValueKey(event.hashCode),
          direction: swipe,
          background: right ? rightCard : leftCard,
          secondaryBackground: left ? leftCard : rightCard,
          dismissThresholds: const {
            DismissDirection.startToEnd: 0.70,
            DismissDirection.endToStart: 0.70,
          },
          movementDuration: config.eventDuration,
          confirmDismiss: (direction) async {
            switch (direction) {
              case DismissDirection.startToEnd:
                onEventSwipedRight?.call(event, fixture);
                modifier.reset();
              case DismissDirection.endToStart:
                onEventSwipedLeft?.call(event, fixture);
                modifier.reset();
              default:
                break;
            }
            return false;
          },
          child: Container(
            width: width,
            height: height,
            color: scheme.surfaceContainerLow,
            child: AnimatedContainer(
              duration: config.eventDuration,
              curve: Curves.easeOutCubic,
              child: SlotEvent(
                event: event,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


enum SwipeRole {
  left,
  right,
}

class SwipeCard extends StatelessWidget {
  final SwipeRole _role;
  const SwipeCard._(this._role);

  const SwipeCard.left()  : this._(SwipeRole.left);
  const SwipeCard.right() : this._(SwipeRole.right);

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    return switch (_role) {
      SwipeRole.left => config.leftSwipeBuilder?.call(context),
      SwipeRole.right => config.rightSwipeBuilder?.call(context),
    } ?? SizedBox.expand();
  }
}