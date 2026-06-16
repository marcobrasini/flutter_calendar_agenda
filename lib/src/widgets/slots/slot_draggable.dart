import 'package:flutter/material.dart';
import 'slot_layout.dart';
import 'slot_event.dart';


typedef DragCallback = void Function(Offset globalPosition);


class SlotDraggable extends StatefulWidget {
  const SlotDraggable({
    super.key,
    required this.layout,
    required this.draggable,
    required this.resizable,
    this.onDragStart,
    this.onDragMove,
    this.onDragEnd,
    this.onDragCancel,
  });

  final SlotLayout layout;
  final bool draggable;
  final bool resizable;
  final DragCallback? onDragStart;
  final DragCallback? onDragMove;
  final DragCallback? onDragEnd;
  final VoidCallback? onDragCancel;

  @override
  State<SlotDraggable> createState() => _SlotDraggableState();
}

class _SlotDraggableState extends State<SlotDraggable> {
  OverlayEntry? _entry;
  Offset _globalPosition = Offset.zero;
  Offset _localPosition = Offset.zero;
  bool _dragging = false;
  bool _opacity = false;

  Widget get slot => EventSlot(
    layout: widget.layout,
    dragging: _opacity,
  );

  Widget get feedback => Positioned(
    left: _globalPosition.dx - _localPosition.dx - widget.layout.left,
    top: _globalPosition.dy - _localPosition.dy,
    width: widget.layout.container.width,
    height: widget.layout.container.height,
    child: IgnorePointer(
      child: Material(
        child: EventSlot(layout: widget.layout),
      ),
    ),
  );

  void _insertOverlay() {
    _entry = OverlayEntry(builder: (_) => feedback);
    Overlay.of(context).insert(_entry!);
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  void _onPointerDown(PointerDownEvent event) {
    _dragging = true;
    setState((){_opacity = false;});
    _globalPosition = event.position;
    if (widget.draggable) {
      _insertOverlay();
      widget.onDragStart?.call(_globalPosition);
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_dragging) return;
    setState((){_opacity = true;});
    _globalPosition = event.position;
    if (widget.draggable && _entry == null) {
      _insertOverlay();
      widget.onDragMove?.call(_globalPosition);
    }
    if (_entry != null) {
      _entry!.markNeedsBuild();
      widget.onDragMove?.call(_globalPosition);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _dragging = false;
    setState((){_opacity = false;});
    _globalPosition = event.position;
    if (_entry != null) {
      _removeOverlay();
      widget.onDragEnd?.call(_globalPosition - _localPosition);
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _dragging = false;
    setState((){_opacity = false;});
    if (_entry != null) {
      _removeOverlay();
      widget.onDragCancel?.call();
    }
  }

  @override
  void initState() {
    super.initState();
    _entry = null;
    _globalPosition = Offset.zero;
    _localPosition = Offset.zero;
    _dragging = false;

  }

  @override
  void didUpdateWidget(SlotDraggable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.draggable && widget.draggable && _dragging && _entry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_dragging && _entry == null) {
          _insertOverlay();
          widget.onDragStart?.call(_globalPosition);
        }
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Listener(
        onPointerDown: (e) {
          final box = context.findRenderObject() as RenderBox;
          _localPosition = box.globalToLocal(e.position);
          _onPointerDown(e);
        },
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: slot,
      ),
    );
  }
}
