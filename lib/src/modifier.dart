import 'dart:async';
import 'package:calendar/src/widgets/calendar_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'widgets/slots/slot_layout.dart';
import 'data/fixture.dart';
import 'viewer.dart';
import 'enums.dart';
import 'const.dart';


class CalendarModifier extends ChangeNotifier {

  CalendarModifier({
    this.onEventDragged,
    this.onEventResized,
    DragCallback? onDragStart,
    DragCallback? onDragMove,
    DragCallback? onDragEnd,
    VoidCallback? onDragCancel,
    DragCallback? onResizeStart,
    DragCallback? onResizeMove,
    DragCallback? onResizeEnd,
    VoidCallback? onResizeCancel,
    required this.swipingDirection,
    required this.slidingDirection,
    this.swipeMargin = viewSwipeMargin,
    this.slideMargin = viewSlideMargin,
  }) : _startCallbacks = {
    SlotAction.dragging: onDragStart,
    SlotAction.resizing: onResizeStart,
  },
  _moveCallbacks = {
    SlotAction.dragging: onDragMove,
    SlotAction.resizing: onResizeMove,
  },
  _endCallbacks = {
    SlotAction.dragging: onDragEnd,
    SlotAction.resizing: onResizeEnd,
  },
  _cancelCallbacks = {
    SlotAction.dragging: onDragCancel,
    SlotAction.resizing: onResizeCancel,
  };

  final DropRegistry registry = DropRegistry();
  final ModifyCallback? onEventDragged;
  final ModifyCallback? onEventResized;
  final Map<SlotAction, DragCallback?> _startCallbacks;
  final Map<SlotAction, DragCallback?> _moveCallbacks;
  final Map<SlotAction, DragCallback?> _endCallbacks;
  final Map<SlotAction, VoidCallback?> _cancelCallbacks;

  //
  int? _pointer;
  SlotAction _action = SlotAction.none;
  ResizeSide _resize = ResizeSide.none;
  Offset? _initialOffset;   // global position of the pointer at the start
  Offset? _actualOffset;    // global position of the pointer at each move
  Offset? _localOffset;     // local position of the pointer in the expanded box
  Offset? _boxOffset;       // local position of the box offset before expansion
  SlotLayout? _layout;
  Rect _container = Rect.zero;
  bool _editing = false;

  SlotAction get action => _action;
  SlotLayout? get layout => _layout;
  Rect get container => _container;
  Offset? get initialOffset => _initialOffset;
  Offset? get actualOffset => _actualOffset;
  Offset? get localOffset => _localOffset;
  Offset get boxOffset => _boxOffset ??= _content!.globalToLocal(_initialOffset!) - _localOffset!;

  Offset get dragged => (_actualOffset != null && _initialOffset != null)
      ? _actualOffset! - _initialOffset!
      : Offset.zero;
  bool get editing => _editing
      && _layout != null
      && _initialOffset != null
      && _actualOffset != null
      && _localOffset != null;
  bool get recording => _pointer != null
      && _initialOffset != null
      && _actualOffset != null
      && _localOffset != null;
  bool get modifying => _layout != null
      && _action != SlotAction.none
      && recording;
  bool get isResizing => modifying && _action == SlotAction.resizing;
  bool get isDragging => modifying && _action == SlotAction.dragging;

  GlobalKey? _viewport;
  RenderBox? get viewport => _viewport?.currentContext?.findRenderObject() as RenderBox?;
  void attachViewport(GlobalKey viewport) => _viewport = viewport;
  bool get hasViewport => (viewport != null)
      ? (viewport!.attached && viewport!.hasSize)
      : false;

  RenderBox? _content;
  void attachContent(RenderBox? box) => _content = box;
  bool get hasContent => (_content != null)
      ? (_content!.attached && _content!.hasSize)
      : false;

  //
  CalendarViewer? _viewer;
  final Axis? swipingDirection;
  final double swipeMargin;
  Timer? _swipeTimer;
  int _swipeStep = 0;
  void attachSwiper(CalendarViewer viewer) => _viewer = viewer;
  bool get hasViewer => (_viewer != null) ? true : false;
  //
  ScrollController? _slider;
  final Axis? slidingDirection;
  final double slideMargin;
  Timer? _slideTimer;
  double _slideSpace = 0;
  double _slideStart = 0;
  void attachSlider(ScrollController slider) => _slider = slider;
  bool get hasSlider => (_slider != null) ? _slider!.hasClients : false;
  double get slided => (hasSlider) ? _slider!.offset - _slideStart : 0.0;

  Fixture? get dropped {
    if (_layout == null || _actualOffset == null) return null;
    final center = _content!.localToGlobal(_container.center);
    final corner = _content!.localToGlobal(_container.topLeft);
    final drop = registry.at(center);
    if (drop == null || !drop.delegate.accepts(_layout!.event)) return null;
    final area = drop.globalToLocal(corner) & _container.size;
    return drop.delegate.resolve(area, drop.size, _layout!.event);
  }

  //
  void enter(int pointer, Offset global, Offset local) {
    _pointer = pointer;
    _initialOffset = global;
    _actualOffset = global;
    _localOffset = local;
  }

  void take(SlotLayout layout, SlotAction action, [ResizeSide side = ResizeSide.none]) {
    _layout = layout;
    _action = action;
    _resize = side;
    notifyListeners();
  }

  void clear() {
    _pointer = null;
    _initialOffset = null;
    _actualOffset = null;
    _localOffset = null;
    _boxOffset = null;
  }

  void free() {
    _layout = null;
    _action = SlotAction.none;
    _resize = ResizeSide.none;
    notifyListeners();
  }

  void reset() {
    free();
    clear();
    _slidingStop();
    _swipingStop();
    _removePointerRoutes();
  }

  //
  double _slidingEdge() {
    double space = 0;
    final local = viewport!.globalToLocal(_actualOffset!);
    switch (slidingDirection!) {
      case Axis.vertical:
        final height = viewport!.size.height;
        final offset = (isDragging) ? _localOffset! : Offset.zero;
        final delta = (isDragging) ? _container.height : 0.0;
        final top = (local - offset).dy;
        final bottom = top + delta;
        if (top < slideMargin) {
          space = -(slideMargin - top);
        } else if (bottom > height - slideMargin) {
          space = bottom - (height - slideMargin);
        }
      case Axis.horizontal:
        final width = viewport!.size.width;
        final left = (local - _localOffset!).dx;
        final right = left + _container.width;
        if (left < slideMargin) {
          space = -(slideMargin - left);
        } else if (right > width - slideMargin) {
          space = right - (width - slideMargin);
        }
    }
    return space;
  }

  void _sliding() {
    if (hasViewport && slidingDirection != null) {
      _slideSpace = _slidingEdge();
      (_slideSpace != 0) ? _slidingStart() : _slidingStop();
    }
  }

  void _slidingStart() {
    if (_slideTimer != null) return;
    _slideTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      final position = _slider!.position;
      final offset = (position.pixels + _slideSpace);
      _slider!.jumpTo(offset.clamp(0.0, position.maxScrollExtent));
      _boxOffset = null;
      set(boxOffset & _layout!.container.size);
      notifyListeners();
    });
  }

  void _slidingStop() {
    _slideTimer?.cancel();
    _slideTimer = null;
    _slideSpace = 0.0;
  }

  //
  int swipingEdge() {
    final local = viewport!.globalToLocal(_actualOffset!);
    switch (swipingDirection!) {
      case Axis.horizontal:
        final width = viewport!.constraints.maxWidth;
        if (local.dx <= swipeMargin) return -1;
        if (local.dx >= width - swipeMargin) return 1;
      case Axis.vertical:
        final height = viewport!.constraints.maxHeight;
        if (local.dy <= swipeMargin) return -1;
        if (local.dy >= height - swipeMargin) return 1;
    }
    return 0;
  }

  void _swiping() {
    if (hasViewport && swipingDirection != null) {
      _swipeStep = swipingEdge();
      (_swipeStep != 0) ? _swipingStart() : _swipingStop();
    }
  }

  void _swipingStart() {
    if (_swipeTimer != null) return;
    _swipeTimer = Timer.periodic(viewSwipeDelay * 2, (_) {
      _viewer!.swipe((_swipeStep < 0)
          ? CalendarSwipe.backward
          : CalendarSwipe.forward
      );
    });
  }

  void _swipingStop() {
    _swipeTimer?.cancel();
    _swipeTimer = null;
    _swipeStep = 0;
  }

  //
  void start() {
    if (_action == SlotAction.none) return;
    if (recording) {
      _startCallbacks[_action]?.call(_layout!.event);
      _initialOffset = _actualOffset;
      _container = boxOffset & _layout!.container.size;
      if (hasSlider) _slideStart = hasSlider ? _slider!.offset : 0;
      _attachPointerRoutes();
      notifyListeners();
    }
  }

  void move() {
    set(boxOffset & _layout!.container.size);
    if (hasViewer && hasViewport) _swiping();
    if (hasSlider && hasViewport) _sliding();
    notifyListeners();
  }

  void end() {
    final fixture = dropped;
    if (_layout != null && fixture != null) {
      switch (_action) {
        case SlotAction.dragging: onEventDragged?.call(_layout!.event, fixture);
        case SlotAction.resizing: onEventResized?.call(_layout!.event, fixture);
        case SlotAction.none: break;
      }
    }
    reset();
    notifyListeners();
  }

  void set(Rect container) {
    switch (_action) {
      case SlotAction.dragging:
        _container = container.translate(dragged.dx, dragged.dy);
      case SlotAction.resizing:
        final delta = switch (_resize) {
          ResizeSide.before || ResizeSide.after => dragged.dy,
          _ => 0.0,
        };
        switch (_resize) {
          case ResizeSide.before:
            _container = Rect.fromLTWH(
              container.left, container.top + delta,
              container.width, container.height - delta,
            );
          case ResizeSide.after:
            _container = Rect.fromLTWH(
              container.left, container.top,
              container.width, container.height + delta,
            );
          default: return;
        }
      default: return;
    }
  }

  //
  void _pointerRoutes(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _actualOffset = event.position;
      _moveCallbacks[_action]?.call(_layout!.event);
      move();
    } else if (event is PointerUpEvent) {
      _actualOffset = event.position;
      _endCallbacks[_action]?.call(_layout!.event);
      end();
    } else if (event is PointerCancelEvent) {
      _cancelCallbacks[_action]?.call();
      reset();
    }
  }

  void _attachPointerRoutes() {
    if (_editing && _action == SlotAction.dragging) return;
    _editing = true;
    if (_pointer != null) {
      GestureBinding.instance.pointerRouter.addRoute(
        _pointer!, _pointerRoutes,
      );
    }
  }

  void _removePointerRoutes() {
    _editing = false;
    if (_pointer != null) {
      GestureBinding.instance.pointerRouter.removeRoute(
        _pointer!, _pointerRoutes,
      );
    }
  }

  //
  @override
  void dispose() {
    _removePointerRoutes();
    _slidingStop();
    _swipingStop();
    super.dispose();
  }
}