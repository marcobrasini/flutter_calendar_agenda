import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'widgets/slots/slot_layout.dart';
import 'widgets/calendar_target.dart';
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
  })  : _startCallbacks = {
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

  int? _pointer;
  Offset? _initial;       // global position of the pointer at the start
  Offset? _actual;        // global position of the pointer at each move
  Offset? _local;         // local position of the pointer in the expanded box
  SlotLayout? _layout;
  SlotAction _action = SlotAction.none;
  ResizeSide _resize = ResizeSide.none;
  bool _editing = false;
  Rect _screen = Rect.zero;
  Rect _screenInitial = Rect.zero;
  Rect _container = Rect.zero;
  Rect _containerInitial = Rect.zero;

  Rect get screen => _screen;
  Rect get container => _container;
  SlotAction get action => _action;
  SlotLayout? get layout => _layout;
  Offset? get initial => _initial;
  Offset? get actual => _actual;
  Offset? get local => _local;
  bool get picked =>  _initial != null && _actual != null && _local != null;
  bool get editing => _editing && _layout != null;
  bool get tracking => picked && _pointer != null;
  bool get modifying => tracking && _action != SlotAction.none;
  bool get isResizing => tracking && _action == SlotAction.resizing;
  bool get isDragging => tracking && _action == SlotAction.dragging;
  Offset get dragged => (_actual != null && _initial != null)
      ? _actual! - _initial!
      : Offset.zero;

  GlobalKey? _viewport;
  RenderBox? get viewport =>
      _viewport?.currentContext?.findRenderObject() as RenderBox?;
  void attachViewport(GlobalKey viewport) => _viewport = viewport;
  bool get hasViewport => (viewport != null)
      ? (viewport!.attached && viewport!.hasSize)
      : false;

  RenderBox? _content;
  RenderBox? get content => _content;
  void attachContent(RenderBox? box) => _content = box;
  bool get hasContent => (_content != null)
      ? (_content!.attached && _content!.hasSize)
      : false;
  Offset get _origin => _content!.localToGlobal(_containerInitial.topLeft);
  Offset get _offset => _content!.globalToLocal(_initial!) - _local!;

  Fixture? get dropped {
    if (_layout == null || _actual == null) return null;
    if (_action == SlotAction.dragging) {
      _container = _content!.globalToLocal(_screen.topLeft) & _screen.size;
    }
    final drop = registry.at(_content!.localToGlobal(_container.center));
    if (drop == null || !drop.delegate.accepts(_layout!.event)) return null;
    final corner = _content!.localToGlobal(_container.topLeft);
    final area = drop.globalToLocal(corner) & _container.size;
    return drop.delegate.resolve(area, drop.size, _layout!.event);
  }

  // ── Swiper utility ────────────────────────────────────────────────────────
  CalendarViewer? _viewer;
  final Axis? swipingDirection;
  final double swipeMargin;
  void attachSwiper(CalendarViewer viewer) => _viewer = viewer;
  bool get hasViewer => (_viewer != null) ? true : false;
  Timer? _swipeTimer;
  int _swipeStep = 0;

  // ── Slider utility ────────────────────────────────────────────────────────
  ScrollController? _slider;
  final Axis? slidingDirection;
  final double slideMargin;
  void attachSlider(ScrollController slider) => _slider = slider;
  bool get hasSlider => (_slider != null) ? _slider!.hasClients : false;
  Timer? _slideTimer;
  double _slideSpace = 0;
  double _slideStart = 0;
  double get _slideDelta => (hasSlider) ? _slider!.offset - _slideStart : 0.0;
  Offset get slided => switch (slidingDirection) {
    Axis.horizontal => Offset(_slideDelta, 0.0),
    Axis.vertical   => Offset(0.0, _slideDelta),
    null            => Offset.zero,
  };

  // ── Modifier interface ────────────────────────────────────────────────────
  void enter(int pointer, Offset global, Offset local) {
    _pointer = pointer;
    _initial = global;
    _actual = global;
    _local = local;
  }

  void take(SlotLayout layout, SlotAction action, [
    ResizeSide side = ResizeSide.none,
  ]) {
    _layout = layout;
    _action = action;
    _resize = side;
    notifyListeners();
  }

  void _clear() {
    _pointer = null;
    _initial = null;
    _actual = null;
    _local = null;
  }

  void _free() {
    _layout = null;
    _action = SlotAction.none;
    _resize = ResizeSide.none;
    notifyListeners();
  }

  void reset() {
    _free();
    _clear();
    _slidingStop();
    _swipingStop();
    _removePointerRoutes();
  }

  // ── Sliding event management ──────────────────────────────────────────────
  double _slidingEdge() {
    double space = 0;
    final local = viewport!.globalToLocal(_actual!);
    switch (slidingDirection!) {
      case Axis.vertical:
        final height = viewport!.size.height;
        final offset = (isDragging) ? _local! : Offset.zero;
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
        final left = (local - _local!).dx;
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
      final offset = position.pixels + _slideSpace;
      _slider!.jumpTo(offset.clamp(0.0, position.maxScrollExtent));
      set();
      notifyListeners();
    });
  }

  void _slidingStop() {
    _slideTimer?.cancel();
    _slideTimer = null;
    _slideSpace = 0.0;
  }

  // ── Swiping event management ──────────────────────────────────────────────
  int _swipingEdge() {
    final local = viewport!.globalToLocal(_actual!);
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
      _swipeStep = _swipingEdge();
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

  // ── Start-Move-End setups ─────────────────────────────────────────────────
  void start() {
    if (_action == SlotAction.none) return;
    if (tracking) {
      _startCallbacks[_action]?.call(_layout!.event);
      _initial = _actual;
      if (!(_editing && _action == SlotAction.resizing)) {
        _container = _offset & _layout!.container.size;
      }
      _containerInitial = _container;
      _screenInitial = _origin & _containerInitial.size;
      _screen = _screenInitial;
      _slideStart = hasSlider ? _slider!.offset : 0.0;
      _attachPointerRoutes();
      notifyListeners();
    }
  }

  void move() {
    set();
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

  void set() {
    switch (_action) {
      case SlotAction.dragging:
        _screen = _screenInitial.shift(dragged);
      case SlotAction.resizing:
        final delta = dragged + slided;
        switch (_resize) {
          case ResizeSide.before:
            final top = (_containerInitial.top + delta.dy)
                .clamp(double.negativeInfinity, _containerInitial.bottom);
            _container = Rect.fromLTRB(
              _containerInitial.left, top,
              _containerInitial.right, _containerInitial.bottom,
            );
          case ResizeSide.after:
            final bottom = (_containerInitial.bottom + delta.dy)
                .clamp(_containerInitial.top, double.infinity);
            _container = Rect.fromLTRB(
              _containerInitial.left, _containerInitial.top,
              _containerInitial.right, bottom,
            );
          default:
            return;
        }
      case SlotAction.none:
        return;
    }
  }

  // ── PointerRoutes management ──────────────────────────────────────────────
  void _pointerRoutes(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _actual = event.position;
      _moveCallbacks[_action]?.call(_layout!.event);
      move();
    } else if (event is PointerUpEvent) {
      _actual = event.position;
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

  // ── dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _removePointerRoutes();
    _slidingStop();
    _swipingStop();
    super.dispose();
  }
}