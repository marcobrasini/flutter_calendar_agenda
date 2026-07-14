import 'package:calendar/src/const.dart';
import 'package:calendar/src/data/event.dart';
import 'package:flutter/material.dart';


typedef EventTapCallback = void Function(Event event);


class EventTile extends StatelessWidget {

  const EventTile({
    super.key,
    this.width,
    this.height,
    required this.event,
    this.padding = 4,
    this.radius = 4,
    this.textStyle,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final Event event;
  final double? width;
  final double? height;
  final double radius;
  final double padding;
  final TextStyle? textStyle;
  final EventTapCallback? onTap;
  final EventTapCallback? onDoubleTap;
  final EventTapCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(event),
      onDoubleTap: onDoubleTap == null ? null : () => onDoubleTap!(event),
      onLongPress: onLongPress == null ? null : () => onLongPress!(event),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(radius),
            // right: Radius.circular(radius),
          ),
          color: event.color,
        ),
        child: Text(
          event.subject,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: textSlotLines,
        ),
      ),
    );
  }
}

