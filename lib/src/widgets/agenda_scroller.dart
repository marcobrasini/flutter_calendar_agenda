import 'package:calendar/src/config.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/widgets/tabled_metrics.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:calendar/src/viewer.dart';
import 'package:calendar/src/widgets/agenda_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';


typedef ScrollBuilder = AgendaTile Function(GlobalKey, DateTime);


class AgendaMetrics {

  final Map<int, WidgetMetrics> _metrics = {};
  final dateScheme = DateScheme.weekly();
  final snapper = null;

  dynamic indexer(dynamic datetime, int index) {
    return datetime + index;
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
      // if (index > 0) _measureForward();
      // if (index < 0) _measureBackward();
    }
  }
}


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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = metric.key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final snap = widget.metrics.snapper?.call(datetime) ?? true;
        final size = switch (widget.direction) {
          Axis.horizontal => box.size.width,
          Axis.vertical => box.size.height,
        };
        widget.metrics.set(index, size, snap);
      }
    });
    return widget.builder(metric.key, datetime);
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
          ? const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())
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
