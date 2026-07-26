import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'widgets/slots/slot_layout.dart';
import 'utils/datetime.dart';
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
  SlotLayout? _layout;
  Offset? _initialOffset;
  Offset? _actualOffset;
  Offset? _localOffset;
  bool _editing = false;
  Rect _container = Rect.zero;
  Offset? _boxOffset;

  SlotAction get action => _action;
  SlotLayout? get layout => _layout;
  Rect get container => _container;
  Offset? get initialOffset => _initialOffset;
  Offset? get actualOffset => _actualOffset;
  Offset? get localOffset => _localOffset;
  Offset get boxOffset => _boxOffset ??= _renderer!.globalToLocal(_initialOffset!) - _localOffset!;

  Offset get dragged => (_actualOffset != null && _initialOffset != null)
      ? _actualOffset! - _initialOffset!
      : Offset.zero;
  bool get editing => _editing
      && _layout != null
      && _initialOffset != null
      && _actualOffset != null
      && _localOffset != null;
  bool get isRecording => _pointer != null
      && _initialOffset != null
      && _actualOffset != null
      && _localOffset != null;
  bool get isModifying => _layout != null
      && _action != SlotAction.none
      && isRecording;
  bool get isResizing => isModifying && _action == SlotAction.resizing;
  bool get isDragging => isModifying && _action == SlotAction.dragging;

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
  //
  RenderBox?  _renderer;
  void attachRenderer(RenderBox? renderer) =>
      _renderer = renderer;
  bool get hasRenderer => (_renderer != null)
      ? (_renderer!.attached && _renderer!.hasSize)
      : false;

  DateTime Function(Date, Offset)? _converter;
  void attachConverter(DateTime Function(Date, Offset) converter) =>
      _converter = converter;
  bool get hasConverter => _converter != null;
  Fixture get convertSlot {
    return Fixture(
      start: _converter!(_viewer!.start, _container.topCenter),
      stop: _converter!(_viewer!.start, _container.bottomCenter),
    );
  }
  Fixture get convertTile {
    final drop = _converter!(_viewer!.start, _container.center);
    final days = drop.date % _layout!.event.start.date;
    return Fixture(
      start: _layout!.event.start.add(Duration(days: days)),
      stop: _layout!.event.stop.add(Duration(days: days)),
    );
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
    switch (slidingDirection!) {
      case Axis.vertical:
        final height = _renderer!.constraints.maxHeight;
        final local = _renderer!.globalToLocal(_actualOffset!);
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
        final width = _renderer!.constraints.maxWidth;
        final local = _renderer!.globalToLocal(_actualOffset!);
        final left = (local - _localOffset!).dx;
        final right = left + _container.width;
        if (left < slideMargin) {
          space = -(slideMargin - left);
        }
        else if (right > width - slideMargin) {
          space = right - (width - slideMargin);
        }
    }
    return space;
  }

  void _sliding() {
    if (hasRenderer && slidingDirection != null) {
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
    final local = _renderer!.globalToLocal(_actualOffset!);
    switch (swipingDirection!) {
      case Axis.horizontal:
        final width = _renderer!.constraints.maxWidth;
        if (local.dx <= swipeMargin) return -1;
        if (local.dx >= width - swipeMargin) return 1;
      case Axis.vertical:
        final height = _renderer!.constraints.maxHeight;
        if (local.dy <= swipeMargin) return -1;
        if (local.dy >= height - swipeMargin) return 1;
    }
    return 0;
  }

  void _swiping() {
    if (hasRenderer && swipingDirection != null) {
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
    if (isRecording) {
      _startCallbacks[_action]?.call(_layout!.event);
      _container = boxOffset & _layout!.container.size;
      _initialOffset = _actualOffset;
      if (hasSlider) _slideStart = hasSlider ? _slider!.offset : 0;
      _attachPointerRoutes();
      notifyListeners();
    }
  }

  void move() {
    set(boxOffset & _layout!.container.size);
    if (hasViewer) _swiping();
    if (hasSlider) _sliding();
    notifyListeners();
  }

  void end() {
    final fixture = (_layout!.tile) ? convertTile : convertSlot;
    switch (_action) {
      case SlotAction.dragging:
        onEventDragged?.call(_layout!.event, fixture);
        break;
      case SlotAction.resizing:
        onEventResized?.call(_layout!.event, fixture);
        break;
      case SlotAction.none:
        break;
    }
    reset();
    notifyListeners();
  }

  void set(Rect container) {
    switch (_action) {
      case SlotAction.dragging:
        _container = container.translate(dragged.dx, dragged.dy + slided);
      case SlotAction.resizing:
        final delta = dragged.dy + slided;
        switch (_resize) {
          case ResizeSide.before:
            _container = Rect.fromLTWH(
              container.left ,
              container.top + delta,
              container.width,
              container.height - delta,
            );
          case ResizeSide.after:
            _container = Rect.fromLTWH(
              container.left,
              container.top,
              container.width,
              container.height + delta,
            );
          default:
            return;
        }
      default:
        return;
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
    _slider?.dispose();
    _swipingStop();
    _viewer?.dispose();
    super.dispose();
  }
}