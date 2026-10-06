import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../enums.dart';


typedef OffsetConverter = DateTime Function(DateTime, Offset);
typedef IndexConverter = DateTime Function(DateTime, int);
typedef SnapConverter = bool Function(DateTime);


Map<CalendarView, IndexConverter> indexerView(DateScheme dateScheme) => {
  CalendarView.daily:   (datetime, index) {
    return datetime.date + index;
  },
  CalendarView.weekly:  (datetime, index) {
    final start = datetime.weekStart.date + dateScheme.beg;
    return start + index * dateScheme.step;
  },
  CalendarView.monthly: (datetime, index) {
    final start = datetime.weekStart.date + dateScheme.beg;
    return start + index * dateScheme.step;
  },
};

Map<CalendarView, SnapConverter> snapperView(DateScheme dateScheme) => {
  CalendarView.monthly: (datetime) {
    final first = datetime.weekStart.date - dateScheme.beg - 1;
    final last = datetime.weekStart.date - dateScheme.beg + 6;
    return first.month != last.month;
  },
};


class TabledMetrics extends ChangeNotifier {

  TabledMetrics({
    required this.view,
    required this.timeScheme,
    required this.dateScheme,
    required this.weekScheme,
    required this.direction,
  });

  final CalendarView view;
  final TimeScheme? timeScheme;
  final DateScheme? dateScheme;
  final WeekScheme? weekScheme;
  final Axis direction;
  final Map<int, WidgetMetrics> _metrics = {};
  double _width = double.infinity;
  double _height = double.infinity;
  bool _measuring = false;

  double get width => _width;
  double get height => _height;

  int get dateBeg => dateScheme?.beg ?? 0;
  int get timeBeg => timeScheme?.beg ?? 0;
  int get weekBeg => weekScheme?.beg ?? 0;
  int get dateCount => dateScheme?.count ?? 0;
  int get timeCount => timeScheme?.count ?? 0;
  int get weekCount => weekScheme?.count ?? 0;
  int get dateStep => dateScheme?.step ?? 0;
  int get timeStep => timeScheme?.step.minutes ?? 0;
  double get dateScale => dateScheme?.scale(_width) ?? 0.0;
  double get timeScale => timeScheme?.scale(_height) ?? 0.0;
  double get weekScale => weekScheme?.scale(_height) ?? 0.0;
  double get dateSpace => _width / (dateScheme?.count ?? 0.0);
  double get timeSpace => _height / (timeScheme?.count ?? 0.0);
  double get weekSpace => _height / (weekScheme?.count ?? 0.0);

  IndexConverter get indexer => indexerView(dateScheme!)[view]!;
  SnapConverter? get snapper => snapperView(dateScheme!)[view];
  double get caching => switch(direction) {
    Axis.horizontal => _width,
    Axis.vertical   => _height,
  };

  void reset() {
    for (final m in _metrics.values) {
      m
        ..offset = 0.0
        ..extent = null
        ..snap = false;
    }
    refresh();
  }

  void refresh() {
    if (_measuring) return;
    _measuring = true;
    scheduleMicrotask(() {
      _measuring = false;
      notifyListeners();
    });
  }

  void resize(double width, double height) {
    if (_width == width && _height == height) return;
    final axisChanged = switch (direction) {
      Axis.horizontal => _width != width,
      Axis.vertical   => _height != height,
    };
    _width = width;
    _height = height;
    if (axisChanged) _metrics.clear();
    refresh();
  }

  void _measureForward() {
    double cursor = 0.0;
    for (var i = 0;; i++) {
      final m = _metrics[i];
      if (m?.extent == null) break;
      m!.offset = cursor;
      cursor += m.extent!;
    }
  }

  void _measureBackward() {
    double cursor = 0.0;
    for (var i = -1;; i--) {
      final m = _metrics[i];
      if (m?.extent == null) break;
      cursor -= m!.extent!;
      m.offset = cursor;
    }
  }

  void _measure() {
    for (var m in _metrics.values) {
      m.offset = 0.0;
    }
    _measureForward();
    _measureBackward();
  }

  WidgetMetrics find(GlobalKey key) =>
      _metrics.values.singleWhere((m) => m.key == key);

  WidgetMetrics metric(int index) =>
      _metrics.putIfAbsent(index, () => WidgetMetrics(GlobalKey()));

  void set(int index, double size, [bool snap = true]) {
    final metric = _metrics[index];
    if (metric != null && metric.extent != size) {
      metric.extent = size;
      metric.snap = snap;
      if (index > 0) _measureForward();
      if (index < 0) _measureBackward();
    }
  }

  Map<int, double?> get sizes => _metrics
      .map((key, val) => MapEntry(key, val.extent));

  Map<int, double> get offsets => _metrics
      .map((key, val) => MapEntry(key, val.offset));

  Iterable<int> get snaps => _metrics.entries
      .where((entry) => entry.value.snap && entry.value.extent != null)
      .map((entry) => entry.key);

  double offset(int index) => _metrics[index]?.offset ?? double.infinity;

  double? extentOf(int index) => _metrics[index]?.extent;

  int snap(double position) {
    int? best;
    var dist = double.infinity;
    for (final i in snaps) {
      final d = (_metrics[i]!.offset - position).abs();
      if (d < dist) {
        dist = d;
        best = i;
      }
    }
    return best ?? 0;
  }

  void shift(int delta) {
    if (delta == 0) return;
    final variation = offset(delta);
    final shifted = <int, WidgetMetrics>{};
    _metrics.forEach((k, v) {
      v.offset -= variation;
      if (v.offset.abs() <= caching) shifted[k - delta] = v;
    });
    _metrics..clear()..addAll(shifted);
    _measure();
  }

  int get next => snaps.where((i) => i > 0)
      .fold<int?>(null, (a, b) => (a == null || b < a) ? b : a) ?? 0;

  int get last => snaps.where((i) => i < 0)
      .fold<int?>(null, (a, b) => (a == null || b > a) ? b : a) ?? 0;

  int swipe(CalendarSwipe s) => switch (s) {
    CalendarSwipe.forward => next,
    CalendarSwipe.backward => last,
  };
}

class WidgetMetrics with Diagnosticable {
  final GlobalKey key;
  double offset = 0.0;
  double? extent;
  bool snap = false;

  WidgetMetrics(this.key);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GlobalKey>('key', key));
    properties.add(DoubleProperty('offset', offset));
    properties.add(DoubleProperty('size', extent));
  }
}
