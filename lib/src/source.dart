import 'package:flutter/material.dart';
import 'utils/datetime.dart';
import 'data/event.dart';


extension CalendarDate on Date {
  Date get start => this;
  Date get stop => this;
}


extension CalendarWeek on Week {
  Date get start => mon;
  Date get stop => sun;
}


extension CalendarMonth on Month {
  Date get start => first.weekStart.date;
  Date get stop => last.weekEnd.date;
}


class CalendarEvents extends ChangeNotifier {
  CalendarEvents({
    List<Event>? events,
    this.cacheRange = 1,
  }) :  _events = {for (final e in (events ?? const [])) e.id!: e},
        _cache = {};

  final Map<String, Event> _events;
  final Map<Date, List<Event>> _cache;
  final int cacheRange;
  Date? cacheFrom, cacheTo;

  void load(Date from, Date to) {
    if (cacheFrom == null || cacheTo == null) {
      _fetch(from, to);
      cacheFrom = from;
      cacheTo = to;
    } else if (from < cacheFrom! || to > cacheTo!) {
      shift(from, cacheFrom!);
      shift(cacheTo!, to);
      cacheFrom = from;
      cacheTo = to;
    }
  }

  void shift(Date from, Date to) {
    if (from == to) return;
    (from < to) ? _fetch(from, to) : _loose(to, from);
  }

  void clear() {
    _cache.clear();
    _events.clear();
    cacheFrom = null;
    cacheTo = null;
  }

  void set(Iterable<Event> events) {
    _cache.clear();
    _events..clear()..addAll({for (final event in events) event.id!: event});
    cacheFrom = null;
    cacheTo = null;
  }

  bool sync(Iterable<Event> events) {
    final next = {for (final e in events) e.id!: e};
    final removed = _del(_events.values.where((e) => !next.containsKey(e.id)).toList());
    final modified = _put(next.values.where((e) => _events.containsKey(e.id)).toList());
    final inserted = _add(next.values.where((e) => !_events.containsKey(e.id)).toList());
    return removed || modified || inserted;
  }

  bool _add(Iterable<Event> events) {
    bool changed = false;
    for (final event in events) {
      _events.putIfAbsent(event.id!, () {
        _inject(event);
        changed = true;
        return event;
      });
    }
    return changed;
  }

  bool _put(Iterable<Event> events) {
    bool changed = false;
    for (final event in events) {
      _events.update(event.id!, (other) {
        if (other == event) return other;
        _cancel(other);
        _inject(event);
        changed = true;
        return event;
      });
    }
    return changed;
  }

  bool _del(Iterable<Event> events) {
    bool changed = false;
    for (final event in events) {
      if (_events.remove(event.id!) case final other?) {
        _cancel(other);
        changed = true;
      }
    }
    return changed;
  }

  Event? find(String id) => _events[id];

  static List<Event> sort(List<Event> events) {
    events.sort((a, b) {
      final startSort = a.start.compareTo(b.start);
      if (startSort != 0) return startSort;
      return b.duration.compareTo(a.duration);
    });
    return events;
  }

  List<Event> get events => _events.values.toList();

  List<Date> get dates {
    final keys = _cache.keys.toList();
    keys.sort((a, b) => a.compareTo(b));
    return keys;
  }

  bool get built => cacheFrom != null && cacheTo != null;

  // ── Query pubbliche ─────────────────────────────────────────────────────

  List<Event> forDate(Date date) {
    load((date - cacheRange).toMonth.start, (date + cacheRange).toMonth.stop);
    return _cache[date] ?? const [];
  }

  // ── Prefetch ────────────────────────────────────────────────────────────

  void _fetch(Date from, Date to) {
    final instances = events.expand((e) => e.expand(from, to)).toList();
    for (var date = from; date < to; date += 1) {
      _cache.putIfAbsent(date, () => List.unmodifiable(
        sort(instances.where((e) => e.spans(date, date + 1)).toList()),
      ));
    }
  }

  void _loose(Date from, Date to) {
    for (var date = from; date < to; date += 1) {
      _cache.remove(date);
    }
  }

  void _inject(Event event) {
    if (!built) return;
    for (final e in event.expand(cacheFrom, cacheTo)) {
      for (final date in e.dates) {
        if (date < cacheFrom! || date >= cacheTo!) continue;
        _cache[date] = List.unmodifiable(sort([...?_cache[date], e]));
      }
    }
  }

  void _cancel(Event event) {
    for (final entry in _cache.entries.toList()) {
      if (entry.value.any((e) => event.owns(e))) {
        _cache[entry.key] = List.unmodifiable(
            entry.value.where((e) => !event.owns(e))
        );
      }
    }
  }

  // ── Mutazioni ───────────────────────────────────────────────────────────
  void insertEvents(Iterable<Event> events, [bool notify = true]) {
    if (_add(events) && notify) notifyListeners();
  }

  void modifyEvents(Iterable<Event> events, [bool notify = true]) {
    if (_put(events) && notify) notifyListeners();
  }

  void removeEvents(Iterable<Event> events, [bool notify = true]) {
    if (_del(events) && notify) notifyListeners();
  }

  DateTime? hasBefore(DateTime datetime) {
    final dates = <DateTime>[];
    for (Event event in events) {
      if (event.start.isBefore(datetime)) dates.add(event.start);
    }
    return (dates.isNotEmpty)
        ? dates.reduce((a, b) => a.isAfter(b) ? a : b).weekStart
        : null;
  }

  DateTime? hasAfter(DateTime datetime) {
    final dates = <DateTime>[];
    for (Event event in events) {
      if (event.stop.isAfter(datetime)) dates.add(event.stop);
    }
    return (dates.isNotEmpty)
        ? dates.reduce((a, b) => a.isBefore(b) ? a : b).weekStart
        : null;
  }
}


class CalendarSource<T extends Event> extends CalendarEvents {
  CalendarSource({
    List<T>? events,
    super.cacheRange,
    this.label,
    this.color,
    bool visible = true,
  }) : _visible = visible,
       super(events: events);

  final String? label;
  Color? color;
  bool _visible;
  bool get visible => _visible;
  set visible(bool value) {
    if (_visible == value) return;
    _visible = value;
    notifyListeners();
  }

  @override
  List<T> get events => super.events.cast<T>();

  @override
  T? find(String id) => super.find(id) as T?;
}


class CalendarSources<T extends Event> extends CalendarSource<T> {
  CalendarSources(this._sources) {
    for (final source in _sources) {
      source.addListener(notifyListeners);
    }
  }

  final Set<CalendarSource<T>> _sources;

  List<CalendarSource<T>> get sources => List.unmodifiable(_sources);
  Iterable<CalendarSource<T>> get _active => _sources.where((s) => s.visible);

  CalendarSource<T> source(String label) =>
      _sources.singleWhere((s) => s.label == label);

  bool attach(CalendarSource<T> source) {
    if (_sources.add(source)) {
      source.addListener(notifyListeners);
      return true;
    }
    return false;
  }

  CalendarSource<T>? detach(CalendarSource<T> source) {
    if (_sources.remove(source)) {
      source.removeListener(notifyListeners);
      notifyListeners();
      return source;
    }
    return null;
  }

  @override
  void dispose() {
    for (final source in _sources) {
      source.removeListener(notifyListeners);
    }
    super.dispose();
  }

  // ── Query ───────────────────────────────────────────────────────────────

  @override
  List<T> get events => [for (final s in _active) ...s.events];

  @override
  List<Date> get dates {
    final keys = <Date>{for (final s in _active) ...s.dates}.toList();
    keys.sort((a, b) => a.compareTo(b));
    return keys;
  }

  @override
  bool get built => _active.every((s) => s.built);

  @override
  List<Event> forDate(Date date) {
    load((date - cacheRange).toMonth.start, (date + cacheRange).toMonth.stop);
    return CalendarEvents.sort([for (final s in _active) ...s.forDate(date)]);
  }

  @override
  void load(Date from, Date to) {
    for (var s in _active) {
      s.load(from, to);
    }
  }

  @override
  void clear() {
    for (final s in _sources) {
      s.clear();
    }
    notifyListeners();
  }

  @override
  DateTime? hasBefore(DateTime datetime) {
    final all = [for (final s in _active) s.hasBefore(datetime)].nonNulls;
    return all.isEmpty ? null : all.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  @override
  DateTime? hasAfter(DateTime datetime) {
    final all = [for (final s in _active) s.hasAfter(datetime)].nonNulls;
    return all.isEmpty ? null : all.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  // ── Routing delle mutazioni ─────────────────────────────────────────────

  CalendarSource<T>? owner(String id) {
    for (final source in _sources) {
      if (source.find(id) != null) return source;
    }
    return null;
  }

  @override
  T? find(String id) => owner(id)?.find(id);

  @override
  void set(Iterable<Event> events) => throw UnsupportedError(
      'CalendarSources: usa source(label).set(events)'
  );

  @override
  bool sync(Iterable<Event> events) => throw UnsupportedError(
      'CalendarSources: usa source(label).sync(events)'
  );

  @override
  void insertEvents(Iterable<Event> events, [bool notify = true]) => throw UnsupportedError(
      'CalendarSources: usa source(label).insertEvents(events)'
  );

  @override
  void modifyEvents(Iterable<Event> events, [bool notify = true]) => throw UnsupportedError(
      'CalendarSources: usa source(label).modifyEvents(events)'
  );

  @override
  void removeEvents(Iterable<Event> events, [bool notify = true]) => throw UnsupportedError(
      'CalendarSources: usa source(label).removeEvents(events)'
  );
}
