import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import '../utils/schemes.dart';
import '../metrics.dart';


typedef SnapPredicate = bool Function(dynamic datetime);


class AgendaMetrics {
  final Map<int, WidgetMetrics> _metrics = {};
  final Map<int, double> _offsets = {0: 0.0};
  final dateScheme = DateScheme.weekly();
  SnapPredicate? snapper;

  int _maxValid = 0;   // offset validi in [_minValid, _maxValid]
  int _minValid = 0;

  dynamic indexer(dynamic datetime, int index) => datetime + index;

  WidgetMetrics find(GlobalKey key) =>
      _metrics.values.singleWhere((m) => m.key == key);

  WidgetMetrics metric(int index) =>
      _metrics.putIfAbsent(index, () => WidgetMetrics(GlobalKey()));

  double? extentOf(int index) => _metrics[index]?.extent;

  /// Bordo iniziale del tile [index] in coordinate di scroll.
  /// Restituisce null se un extent nel mezzo non è ancora stato misurato.
  double? offsetOf(int index) {
    if (index > 0) {
      while (_maxValid < index) {
        final extent = extentOf(_maxValid);
        if (extent == null) return null;
        _offsets[_maxValid + 1] = _offsets[_maxValid]! + extent;
        _maxValid++;
      }
    } else if (index < 0) {
      while (_minValid > index) {
        final extent = extentOf(_minValid - 1);
        if (extent == null) return null;
        _offsets[_minValid - 1] = _offsets[_minValid]! - extent;
        _minValid--;
      }
    }
    return _offsets[index];
  }

  void set(int index, double size, [bool snap = true]) {
    final metric = _metrics[index];
    if (metric != null && metric.extent != size) {
      metric.extent = size;
      metric.snap = snap;
      _invalidate(index);
    }
  }

  void _invalidate(int index) {
    if (index >= 0 && _maxValid > index) {
      for (int i = index + 1; i <= _maxValid; i++) {
        _offsets.remove(i);
      }
      _maxValid = index;
    }
    if (index < 0 && _minValid <= index) {
      for (int i = _minValid; i < index; i++) {
        _offsets.remove(i);
      }
      _minValid = index + 1;
    }
  }

  /// Bordi agganciabili che racchiudono [pixels], più l'estensione
  /// del blocco compreso fra i due.
  ({double? prev, double? next, double? extent}) around(double pixels) {
    double? prev, next;
    for (final index in _metrics.keys) {
      if (!(_metrics[index]?.snap ?? false)) continue;
      final o = offsetOf(index);
      if (o == null) continue;
      if (o <= pixels + precisionErrorTolerance && (prev == null || o > prev)) {
        prev = o;
      }
      if (o >= pixels - precisionErrorTolerance && (next == null || o < next)) {
        next = o;
      }
    }
    return (
    prev: prev,
    next: next,
    extent: (prev != null && next != null) ? next - prev : null,
    );
  }
}


typedef ExtentCallback = void Function(double extent);

class MeasuredTile extends SingleChildRenderObjectWidget {
  const MeasuredTile({
    super.key,
    required this.axis,
    required this.onExtent,
    required super.child,
  });

  final Axis axis;
  final ExtentCallback onExtent;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasuredTile(axis, onExtent);

  @override
  void updateRenderObject(BuildContext context, _RenderMeasuredTile ro) {
    ro..axis = axis..onExtent = onExtent;
  }
}

class _RenderMeasuredTile extends RenderProxyBox {
  _RenderMeasuredTile(this.axis, this.onExtent);

  Axis axis;
  ExtentCallback onExtent;
  double? _last;

  @override
  void performLayout() {
    super.performLayout();
    final extent = axis == Axis.vertical ? size.height : size.width;
    if (_last != extent) {
      _last = extent;
      onExtent(extent);
    }
  }
}