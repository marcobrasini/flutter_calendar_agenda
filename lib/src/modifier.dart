import 'dart:async';
import 'package:calendar/src/enums.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'widgets/slots/slot_layout.dart';
import 'widgets/slots/slot_event.dart';
import 'controller.dart';
import 'const.dart';
import 'data/event.dart';
import 'data/fixture.dart';


class CalendarModifier extends ChangeNotifier {

  CalendarModifier({
    this.onEventDragged,
    this.onEventResized,
    this.onDragStart,
    this.onDragMove,
    this.onDragEnd,
    this.onDragCancel,
    this.onResizeStart,
    this.onResizeMove,
    this.onResizeEnd,
    this.onResizeCancel,
  }) : _action = SlotAction.none;

  final ModifyCallback? onEventDragged;
  final ModifyCallback? onEventResized;
  final DragCallback? onDragStart;
  final DragCallback? onDragMove;
  final DragCallback? onDragEnd;
  final VoidCallback? onDragCancel;
  final DragCallback? onResizeStart;
  final DragCallback? onResizeMove;
  final DragCallback? onResizeEnd;
  final VoidCallback? onResizeCancel;

  int? _pointer;
  SlotAction _action;
  SlotLayout? _layout;
  Offset? _globalOffset;
  Offset? _localOffset;
  bool _drawing = false;
  bool get drawing => _drawing && _layout != null
      && _globalOffset != null && _localOffset != null;
  SlotAction get action => _action;
  SlotLayout? get layout => _layout;
  Event? get event => _layout?.event;
  Offset? get globalOffset => _globalOffset;
  Offset? get localOffset => _localOffset;
  bool get isRecording => _pointer != null && _globalOffset != null && _localOffset != null;
  bool get isModifying => _layout != null && _action != SlotAction.none && isRecording;
  bool get isResizing => isModifying && _action == SlotAction.resizing;
  bool get isDragging => isModifying && _action == SlotAction.dragging;

  CalendarController? _controller;
  DateTime Function(Offset)? _converter;
  RenderBox? Function()? _renderer;
  RenderBox? get renderer {
    final box = _renderer?.call();
    return (box != null && box.attached && box.hasSize) ? box : null;
  }

  int? _swipeEdge;
  Timer? _swipeTimer;
  final _swipeMargin = swipeMargin;
  final _swipeDirection = Axis.horizontal;
  int? _scrollEdge;
  final _scrollMargin = 0.0;
  final _scrollDirection = Axis.vertical;

  void attachController(CalendarController controller) {
    _controller = controller;
  }
  void attachRenderer(RenderBox? Function() renderer) {
    _renderer = renderer;
  }
  void attachConverter(DateTime Function(Offset) converter) {
    _converter = converter;
  }

  void reset({bool notify = true}) {
    clear();
    free();
    _removeDraggingRoute();
    _removeResizingRoute();
    if (notify) notifyListeners();
  }

  void enter(int pointer, Offset global, Offset local) {
    _pointer = pointer;
    _globalOffset = global;
    _localOffset = local;
  }
  void clear() {
    _pointer = null;
    _globalOffset = null;
    _localOffset = null;
  }

  void take(SlotLayout layout, SlotAction action) {
    _action = action;
    _layout = layout;
    _drawing = false;
    notifyListeners();
  }
  void free() {
    _action = SlotAction.none;
    _layout = null;
    _drawing = false;
    notifyListeners();
  }

  void modify() {
    switch (_action) {
      case SlotAction.dragging:
        draggingStart();
        break;
      case SlotAction.resizing:
        resizingStart();
        break;
      default:
        return;
    }
    _drawing = true;
    notifyListeners();
  }
  
  void _attachDraggingRoute() {
    if (_pointer != null) {
      GestureBinding.instance.pointerRouter.addRoute(
        _pointer!, _draggingPointerRoutes,
      );
    }
  }

  void _removeDraggingRoute() {
    if (_pointer != null) {
      GestureBinding.instance.pointerRouter.removeRoute(
          _pointer!, _draggingPointerRoutes,
      );
    }
    _swipeTimer?.cancel();
    _swipeTimer = null;
    _swipeEdge = null;
  }

  void _attachResizingRoute() {
    if (_pointer != null) {
      GestureBinding.instance.pointerRouter.addRoute(
        _pointer!, _resizingPointerRoutes,
      );
    }
  }

  void _removeResizingRoute() {
    if (_pointer != null) {
      GestureBinding.instance.pointerRouter.removeRoute(
        _pointer!, _resizingPointerRoutes,
      );
    }
  }

  void _resizingPointerRoutes(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _globalOffset = event.position;
      resizingMove();
    } else if (event is PointerUpEvent) {
      _globalOffset = event.position;
      resizingEnd();
    } else if (event is PointerCancelEvent) {
      onResizeCancel?.call();
      reset();
    }
  }

  void _draggingPointerRoutes(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _globalOffset = event.position;
      draggingMove();
    } else if (event is PointerUpEvent) {
      _globalOffset = event.position;
      draggingEnd();
    } else if (event is PointerCancelEvent) {
      onDragCancel?.call();
      reset();
    }
  }

  void draggingStart() {
    _attachDraggingRoute();
    onDragStart?.call(_layout!.event);
    notifyListeners();
  }

  void draggingSwipe() {
    final box = renderer;
    if (box != null) {
      final edge = swipingEdge(box);
      if (edge != _swipeEdge) {
        _swipeTimer?.cancel();
        _swipeEdge = edge;
        if (edge != null) {
          final resolvedEdge = edge;
          _swipeTimer = Timer(swipeDelay, () {
            (resolvedEdge < 0) ? _controller!.last() : _controller!.next();
            _swipeEdge = null;
          });
        }
      }
    }
  }

  void draggingScroll() {}

  void draggingMove() {
    if (_swipeMargin > 0) draggingSwipe();
    if (_scrollMargin > 0) draggingScroll();
    onDragMove?.call(_layout!.event);
    notifyListeners();
  }

  void draggingEnd() {
    final box = renderer;
    if (isDragging && box != null) {
      final local = box.globalToLocal(_globalOffset! - _localOffset!);
      final start = _converter?.call(local);
      final event = _layout!.event;
      if (start != null && start != event.start) {
        onEventDragged?.call(
          event,
          Fixture(start: start, stop: start.add(event.duration)),
        );
      }
      onDragEnd?.call(_layout!.event);
      notifyListeners();
    }
    reset();
  }

  int? swipingEdge(RenderBox box) {
    final local = box.globalToLocal(_globalOffset!);
    switch (_swipeDirection) {
      case Axis.horizontal:
        if (local.dx <= _swipeMargin) return -1;
        if (local.dx >= box.constraints.maxWidth - _swipeMargin) return 1;
      case Axis.vertical:
        if (local.dy <= _swipeMargin) return -1;
        if (local.dy >= box.constraints.maxHeight - _swipeMargin) return 1;
    }
    return null;
  }

  void resizingStart() {
    _attachResizingRoute();
    onResizeStart?.call(_layout!.event);
    notifyListeners();
  }

  void resizingMove() {
    if (_scrollMargin > 0) resizingScroll();
    onResizeMove?.call(_layout!.event);
    notifyListeners();
  }

  void resizingScroll() {}

  void resizingEnd() {
    final box = renderer;
    if (isResizing && box != null) {
      final local = box.globalToLocal(_globalOffset! - _localOffset!);
      final start = _converter?.call(local);
      final event = _layout!.event;
      if (start != null && start != event.start) {
        onEventDragged?.call(
          event,
          Fixture(start: start, stop: start.add(event.duration)),
        );
      }
      onResizeEnd?.call(_layout!.event);
      notifyListeners();
    }
    reset();
  }

  @override
  void dispose() {
    _removeDraggingRoute();
    _removeResizingRoute();
    super.dispose();
  }
}