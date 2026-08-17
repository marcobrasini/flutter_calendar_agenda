import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../utils/schemes.dart';
import '../viewer.dart';
import '../enums.dart';


class SnapPoint {
  const SnapPoint(this.offset, this.datetime);
  final double offset;
  final dynamic datetime;
}


class AgendaRegistry {
  AgendaRegistry({
    required this.viewer,
    required this.dateScheme,
    required this.direction,
  });

  final CalendarViewer viewer;
  final DateScheme? dateScheme;
  final Axis direction;

  final Set<RenderRegistry> _anchors = {};
  List<SnapPoint> _sorted = const [];
  double _height = double.infinity;
  double _width = double.infinity;
  bool _rendering = true;
  bool _scheduled = false;

  double get width => _width;
  double get height => _height;

  int get dateBeg => dateScheme?.beg ?? 0;
  int get dateStep => dateScheme?.step ?? 0;
  int? get dateCount => dateScheme?.count;

  double get caching => switch(direction) {
    Axis.horizontal => _width,
    Axis.vertical   => _height,
  };

  dynamic indexer(dynamic datetime, int index) => datetime + index;

  void add(RenderRegistry a) {
    _anchors.add(a);
    invalidate();
  }

  void remove(RenderRegistry a) {
    _anchors.remove(a);
    invalidate();
  }

  void invalidate() {
    _rendering = true;
    if (_scheduled) return; _scheduled = true;
    SchedulerBinding.instance..addPostFrameCallback((_) {
      _scheduled = false;
      if (_rendering) _rebuild();
    })..scheduleFrame();
  }

  void _rebuild() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase != SchedulerPhase.idle &&
        phase != SchedulerPhase.postFrameCallbacks) {
      invalidate();
      return;
    }
    final points = <SnapPoint>[];
    for (final box in _anchors) {
      if (!box.snap || !box.attached || !box.hasSize) continue;
      final viewport = RenderAbstractViewport.maybeOf(box);
      if (viewport != null) {
        final offset = viewport.getOffsetToReveal(box, 0.0).offset;
        if (offset.isFinite) points.add(SnapPoint(offset, box.datetime));
      }
    }
    points.sort((a, b) => a.offset.compareTo(b.offset));
    final unique = <SnapPoint>[];
    for (final point in points) {
      if (unique.isEmpty || point.offset - unique.last.offset > precisionErrorTolerance) {
        unique.add(point);
      }
    }
    _sorted = unique;
    _rendering = false;
  }

  void resize(double width, double height) {
    if (_width == width && _height == height) return;
    this.._width = width.._height = height;
    invalidate();
  }

  int index(double limit) {
    if (_sorted.isEmpty) return -1;
    int lo = 0, hi = _sorted.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_sorted[mid].offset <= limit) { lo = mid + 1; } else { hi = mid; }
    }
    return (lo - 1).clamp(0, _sorted.length - 1);
  }

  double offset(int index) => _sorted[index].offset;

  DateTime datetime(int index) => _sorted[index].datetime;

  SnapPoint? find(DateTime datetime) => _sorted.where(
          (snap) => snap.datetime == datetime
  ).singleOrNull;

  SnapPoint? snap(double pixels) {
    final i = index(pixels);
    return (i < 0) ? null : _sorted[i];
  }

  SnapPoint? next(DateTime datetime) {
    final snap = find(datetime);
    if (snap == null) return null;
    final i = _sorted.indexOf(snap);
    return (i < _sorted.length) ? _sorted[i + 1] : null;
  }

  SnapPoint? last(DateTime datetime) {
    final snap = find(datetime);
    if (snap == null) return null;
    final i = _sorted.indexOf(snap);
    return (i == 0) ? null : _sorted[i - 1];
  }

  SnapPoint? swipe(CalendarSwipe swipe) => switch(swipe) {
    CalendarSwipe.backward => last(viewer.datetime),
    CalendarSwipe.forward =>  next(viewer.datetime),
  };
}


class WidgetRegistry extends SingleChildRenderObjectWidget {
  const WidgetRegistry({
    super.key,
    required super.child,
    required this.registry,
    required this.datetime,
    this.snap = true,
  });

  final AgendaRegistry registry;
  final dynamic datetime;
  final bool snap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderRegistry(registry, datetime, snap);

  @override
  void updateRenderObject(BuildContext context, RenderRegistry renderObject) {
    renderObject..registry = registry..datetime = datetime..snap = snap;
  }
}


class RenderRegistry extends RenderProxyBox {
  RenderRegistry(this._registry, this._dateTime, this._snap);

  AgendaRegistry _registry;
  DateTime _dateTime;
  bool _snap;

  DateTime get datetime => _dateTime;
  set datetime(DateTime value) {
    if (value == _dateTime) return;
    _dateTime = value;
    _registry.invalidate();
  }

  bool get snap => _snap;
  set snap(bool value) {
    if (value == _snap) return;
    _snap = value;
    _registry.invalidate();
  }

  AgendaRegistry get registry => _registry;
  set registry(AgendaRegistry value) {
    if (identical(value, _registry)) return;
    if (attached) { _registry.remove(this); value.add(this); }
    _registry = value;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _registry.add(this);
  }

  @override
  void detach() {
    _registry.remove(this);
    super.detach();
  }

  @override
  void performLayout() {
    super.performLayout();
    _registry.invalidate();
  }
}