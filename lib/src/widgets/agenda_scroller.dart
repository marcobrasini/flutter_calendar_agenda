import 'package:calendar/src/config.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/widgets/agenda_metrics.dart';
import 'package:calendar/src/widgets/agenda_metrics.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:calendar/src/viewer.dart';
import 'package:calendar/src/widgets/agenda_tile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';


typedef ScrollBuilder = AgendaTile Function(GlobalKey, DateTime);


class AgendaScroller extends StatefulWidget {
  const AgendaScroller({
    super.key,
    required this.direction,
    required this.controller,
    required this.metrics,
    required this.builder,
    required this.breakpoint,
  });

  final Axis direction;
  final CalendarController controller;
  final AgendaMetrics metrics;
  final ScrollBuilder builder;
  final double breakpoint;

  CalendarScroll get scrolling => controller.scroll;

  @override
  State<AgendaScroller> createState() => _AgendaScrollerState();
}

class _AgendaScrollerState extends State<AgendaScroller> {
  static final Key _centerKey = UniqueKey();
  late final CalendarViewer _viewer;
  late final CalendarEvents _source;
  late Date _today;

  @override
  void initState() {
    super.initState();
    _viewer = context.read<CalendarViewer>();
    _source = context.read<CalendarEvents>();
    _today = _viewer.asDate;
  }

  int _minIndex = 0;
  int _maxIndex = 0;
  bool get _sequential => widget.scrolling == CalendarScroll.sequential;
  bool get _continuous => widget.scrolling == CalendarScroll.continuous;
  Date get _maxDate => _today + (_maxIndex * widget.metrics.dateScheme.step);
  Date get _minDate => _today + (_minIndex * widget.metrics.dateScheme.step);
  DateTime get recorded => widget.metrics.indexer(_viewer.datetime, 0);
  DateTime get scrolled => widget.controller.datetime;

  final ValueNotifier<double> _offset = ValueNotifier(0);
  double get _strain => _offset.value;
  bool get _head => _strain < 0;
  bool get _tail => _strain > 0;
  CalendarSwipe? get _swipe {
    if (_head) return CalendarSwipe.backward;
    if (_tail) return CalendarSwipe.forward;
    return null;
  }

  bool _busy = false;
  bool _armed = false;
  double get _hung => (_strain.abs() / widget.breakpoint).clamp(0.0, 1.0);

  final _todo = {
    CalendarSwipe.backward: false,
    CalendarSwipe.forward:  false,
  };
  bool get _done => _todo[_swipe] ?? false;

  int? findNext() {
    final dates = _source.dates;
    final start = _maxIndex;
    while (dates.contains(_maxDate)) {
      _maxIndex++;
      for (int i = 0; i < widget.metrics.dateScheme.count; i++) {
        if (_source.forDate(_maxDate + i).isNotEmpty) {
          return _maxIndex;
        }
      }
    }
    _maxIndex = start;
    return null;
  }

  int? findLast() {
    final dates = _source.dates;
    final start = _minIndex;
    while (dates.contains(_minDate)) {
      _minIndex--;
      for (int i = 0; i < widget.metrics.dateScheme.count; i++) {
        if (_source.forDate(_minDate + i).isNotEmpty) {
          return _minIndex;
        }
      }
    }
    _minIndex = start;
    return null;
  }

  void _repaint(VoidCallback fn) {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(fn);
      });
    } else {
      setState(fn);
    }
  }

  bool _scroll(ScrollNotification notification) {
    if (_continuous || notification.depth != 0) return false;
    if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails == null) return false;
      final pull = _scrollOverside(notification.metrics);
      if (pull != _strain) setState(() => _offset.value = pull);
      if (_armed && _hung < 0.5) _armed = false;
      if (!_armed && !_done && _hung >= 1.0) {
        _armed = true;
        _scrollLoading(_swipe!);
      }
    } else if (notification is ScrollEndNotification) {
      if (_strain != 0) _scrollReset();
    }
    return false;
  }

  double _scrollOverside(ScrollMetrics m) {
    if (m.pixels < m.minScrollExtent) return m.pixels - m.minScrollExtent;
    if (m.pixels > m.maxScrollExtent) return m.pixels - m.maxScrollExtent;
    return 0;
  }

  void _scrollLoading(CalendarSwipe swipe) {
    if (_busy) return; _busy = true;
    final found = swipe == CalendarSwipe.backward ? findLast() : findNext();
    _busy = false;
    _repaint(() {
      if (found == null) _todo[_swipe!] = true;
    });
  }

  void _scrollReset() {
    _repaint(() {
      _offset.value = 0;
      _armed = false;
    });
  }

  Widget _build(int index) {
    final metric = widget.metrics.metric(index);
    final datetime = widget.metrics.indexer(scrolled, index);
    final snap = widget.metrics.snapper?.call(datetime) ?? true;
    return MeasuredTile(
      axis: widget.direction,
      child: widget.builder(metric.key, datetime),
      onExtent: (extent) => widget.metrics.set(index, extent, snap),
    );
  }

  Widget _buildAnchor(CalendarSwipe swipe) {
    final scheme = Theme.of(context).colorScheme;
    final exhausted = _todo[swipe] ?? false;
    return Positioned(
      top: swipe == CalendarSwipe.backward ? 0 : null,
      bottom: swipe == CalendarSwipe.forward ? 0: null,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: ValueListenableBuilder<double>(
          valueListenable: _offset,
          builder: (context, strain, child) {
            final active = switch(swipe) {
              CalendarSwipe.backward  => strain < 0,
              CalendarSwipe.forward   => strain > 0,
            };
            return Opacity(
              opacity: active ? _hung : 0.0,
              child: Transform.scale(
                scale: 0.5 + 0.5 * _hung,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Icon(
              exhausted ? Icons.remove : switch(swipe) {
                CalendarSwipe.backward  => Icons.keyboard_double_arrow_up,
                CalendarSwipe.forward   => Icons.keyboard_double_arrow_down,
              },
              color: exhausted ? scheme.outline : scheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      center: _centerKey,
      physics: _sequential
          ? AgendaSnapPhysics(
            metrics: widget.metrics,
            parent: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
          )
          : null,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: (_continuous) ? null : _minIndex.abs(),
                (context, index) => _build(-(index + 1)),
          ),
        ),
        SliverList(
          key: _centerKey,
          delegate: SliverChildBuilderDelegate(
            childCount: 1,
                (context, index) => _build(index),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: (_continuous) ? null : _maxIndex,
                (context, index) => _build((index + 1)),
          ),
        ),
      ],
    );
    return (_sequential) ? NotificationListener<ScrollNotification>(
      onNotification: _scroll,
      child: Stack(
        children: [
          _buildAnchor(CalendarSwipe.backward),
          scrollView,
          _buildAnchor(CalendarSwipe.forward),
        ],
      ),
    ) : scrollView;
  }
}


class AgendaSnapPhysics extends ScrollPhysics {
  const AgendaSnapPhysics({
    required this.metrics,
    this.fling = kMinFlingVelocity,
    super.parent,
  });

  final AgendaMetrics metrics;
  final double fling;

  @override
  AgendaSnapPhysics applyTo(ScrollPhysics? ancestor) => AgendaSnapPhysics(
    metrics: metrics,
    fling: fling,
    parent: buildParent(ancestor),
  );

  double? _target(ScrollMetrics position, double velocity) {
    final bounds = metrics.around(position.pixels);
    final prev = bounds.prev;
    final next = bounds.next;
    if (prev == null && next == null) return null;

    // Blocco più alto del viewport: lo snap impedirebbe di leggerne il fondo.
    final extent = bounds.extent;
    if (extent != null && extent > position.viewportDimension) return null;

    double? target;
    if (velocity.abs() > fling) {
      target = velocity > 0 ? next : prev;
    }
    target ??= switch ((prev, next)) {
      (final p?, final n?) =>
      (position.pixels - p).abs() <= (n - position.pixels).abs() ? p : n,
      (final p?, null) => p,
      (null, final n?) => n,
      _ => null,
    };
    return target?.clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // Fuori range: lascia il rimbalzo al parent, così il pull-to-load resta intatto.
    if (position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }
    final target = _target(position, velocity);
    if (target == null) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    if ((target - position.pixels).abs() < tolerance.distance &&
        velocity.abs() < tolerance.velocity) {
      return null;
    }
    return ScrollSpringSimulation(
      spring, position.pixels, target, velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}