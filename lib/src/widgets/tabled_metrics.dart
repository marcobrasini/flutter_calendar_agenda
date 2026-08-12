import 'dart:async';

import 'package:calendar/src/enums.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


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

Map<CalendarView, OffsetConverter> converterView(
    Size size,
    TimeScheme? timeScheme,
    DateScheme? dateScheme,
    WeekScheme? weekScheme,
) => {
  CalendarView.daily: (DateTime datetime, Offset local) {
    final timeScale = timeScheme?.scale(size.height) ?? 0.0;
    final step = timeScheme?.round ?? 1;
    final minutes = (local.dy * timeScale / step).round() * step;
    return datetime.date & Time(timeScheme?.beg ?? 0, minutes);
  },
  CalendarView.weekly: (DateTime datetime, Offset local) {
    final dateScale = dateScheme?.scale(size.width) ?? 0.0;
    final timeScale = timeScheme?.scale(size.height) ?? 0.0;
    final step = timeScheme?.round ?? 1;
    final days = (local.dx * dateScale).floor() + (dateScheme?.beg ?? 0);
    final minutes = (local.dy * timeScale / step).round() * step;
    return (datetime.date + days) & Time(timeScheme?.beg ?? 0, minutes);
  },
  CalendarView.monthly: (DateTime datetime, Offset local) {
    final dateScale = dateScheme?.scale(size.width) ?? 0.0;
    final weekScale = weekScheme?.scale(size.height) ?? 0.0;
    final days = (local.dx * dateScale).floor() + (dateScheme?.beg ?? 0);
    final weeks = (local.dy * weekScale).floor() + (weekScheme?.beg ?? 0);
    return datetime.date + (days + weeks * DateTime.daysPerWeek);
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
  double width = double.infinity;
  double height = double.infinity;
  bool _measuring = false;

  int get dateBeg => dateScheme?.beg ?? 0;
  int get timeBeg => timeScheme?.beg ?? 0;
  int get weekBeg => weekScheme?.beg ?? 0;
  int get dateCount => dateScheme?.count ?? 0;
  int get timeCount => timeScheme?.count ?? 0;
  int get weekCount => weekScheme?.count ?? 0;
  int get dateStep => dateScheme?.step ?? 0;
  int get timeStep => timeScheme?.step.minutes ?? 0;
  double get dateScale => dateScheme?.scale(width) ?? 0.0;
  double get timeScale => timeScheme?.scale(height) ?? 0.0;
  double get weekScale => weekScheme?.scale(height) ?? 0.0;
  double get dateSpace => width / (dateScheme?.count ?? 0.0);
  double get timeSpace => height / (timeScheme?.count ?? 0.0);
  double get weekSpace => height / (weekScheme?.count ?? 0.0);

  OffsetConverter get converter => converterView(
      Size(width, height), timeScheme, dateScheme, weekScheme)[view]!;
  IndexConverter get indexer => indexerView(dateScheme!)[view]!;
  SnapConverter? get snapper => snapperView(dateScheme!)[view];
  double get caching => switch(direction) {
    Axis.horizontal => width,
    Axis.vertical   => height,
  };

  void refresh() {
    if (_measuring) return;
    _measuring = true;
    scheduleMicrotask(() {
      _measuring = false;
      notifyListeners();
    });
  }

  void resize(double w, double h) {
    if (w == width && h == height) return;
    width = w;
    height = h;
    _metrics.clear();
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

  double? size(int index) => _metrics[index]?.extent;

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
