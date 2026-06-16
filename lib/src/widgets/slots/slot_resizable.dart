import 'package:flutter/material.dart';
import 'slot_layout.dart';
import 'slot_event.dart';


typedef ResizeCallback = void Function();


class SlotResizable extends StatefulWidget {
  const SlotResizable({
    super.key,
    required this.layout,
    this.enabled = true,
    this.onResizeStart,
    this.onResizeMove,
    this.onResizeEnd,
    this.onResizeCancel,
  });

  final SlotLayout layout;
  final bool enabled;
  final ResizeCallback? onResizeStart;
  final ResizeCallback? onResizeMove;
  final ResizeCallback? onResizeEnd;
  final VoidCallback? onResizeCancel;

  @override
  State<SlotResizable> createState() => _SlotResizableState();
}

class _SlotResizableState extends State<SlotResizable> {
  
  
  
  @override
  Widget build(BuildContext context) {
    return EventSlot(layout: widget.layout, resizing: widget.enabled,);
  }
}
