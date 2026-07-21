import 'package:calendar/calendar.dart';
import 'package:calendar/src/const.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/modifier.dart';
import 'package:calendar/src/widgets/scroll/scroll_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


typedef ScrollBuilder = ScrollWidget Function(GlobalKey, DateTime, Offset);
typedef IndexConverter = DateTime Function(DateTime, int);
typedef SnapConverter = bool Function(DateTime);


class ScrollViewer extends StatefulWidget {

  const ScrollViewer({
    super.key,
    required this.controller,
    required this.direction,
    required this.builder,
    required this.adapter,
    this.snapper,
    this.cache,
  });

  final ScrollController controller;
  final ScrollBuilder builder;
  final IndexConverter adapter;
  final SnapConverter? snapper;
  final double? cache;
  final Axis direction;

  @override
  State<ScrollViewer> createState() => _ScrollViewerState();
}

class _ScrollViewerState extends State<ScrollViewer> {
  static final Key _centerKey = UniqueKey();
  late final SnapMetrics _metrics;
  late final SnapPhysics _physics;
  late DateTime _datetime;
  bool _isSnapping = false;
  final swipes = {
    CalendarSwipe.backward: 0,
    CalendarSwipe.forward: 0,
  };

  @override
  void initState() {
    final viewer = context.read<CalendarViewer>();
    final modifier = context.read<CalendarModifier>();
    modifier.attachSwiper(viewer);
    _metrics = SnapMetrics();
    _physics = SnapPhysics(metrics: _metrics);
    _datetime = widget.adapter(viewer.datetime, 0);
    print(swipes);
    super.initState();
  }

  void updateViewer(int index, DateTime datetime) {
    final viewer = context.read<CalendarViewer>();
    if (widget.adapter(viewer.datetime, 0) != datetime) {
      if (index > 0) {
        while (widget.adapter(viewer.datetime, 0).isBefore(datetime)) {
          viewer.next();
        }
      } else {
        while (widget.adapter(viewer.datetime, 0).isAfter(datetime)) {
          viewer.last();
        }
      }
    }
  }

  bool _scrolling(ScrollNotification notification) {
    if (_isSnapping) return false;
    final (index, offset) = _metrics.snap(notification.metrics.pixels);
    final datetime = widget.adapter(_datetime, index);
    if (datetime != widget.adapter(_datetime, 0)) {
      if (notification is ScrollEndNotification) {
        _isSnapping = true;
        final position = widget.controller.position.pixels;
        widget.controller.jumpTo(position - offset);
        setState(() {
          _datetime = datetime;
          _metrics.shift(index);
        });
        _isSnapping = false;
      }
      updateViewer(index, datetime);
    }
    return false;
  }

  void _animate(CalendarSwipe swipe) {
    if (!widget.controller.hasClients) return;
    final snap = _metrics.swipes[swipe];
    if (snap != null) {
      widget.controller.animateTo(
        _metrics.snapOffset(snap),
        duration: viewSwipeDelay,
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTile(int index) {
    final datetime = widget.adapter(_datetime.date, index);
    final key = _metrics.key(index);
    final tile = widget.builder(key, datetime, Offset(0.0, _metrics.snapOffset(index)));
    if (widget.snapper?.call(datetime) ?? true) {
      _metrics.append(index);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        _metrics._heights[index] = box.size.height;
      }
    });
    print("$index, $datetime");
    return tile;
  }

  @override
  Widget build(BuildContext context) {
    final viewer = context.watch<CalendarViewer>();
    if (viewer.swiping != null) {
      final swipe = viewer.swiping!;
      viewer.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animate(swipe);
      });
    }
    return NotificationListener<ScrollNotification>(
      onNotification: _scrolling,
      child: CustomScrollView(
        controller: widget.controller,
        cacheExtent: widget.cache,
        center: _centerKey,
        physics: _physics,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildTile(-(i + 1)),
            ),
          ),
          SliverList(
            key: _centerKey,
            delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildTile(i),
            ),
          ),
        ],
      ),
    );
  }
}

class SnapMetrics {
  final Map<CalendarSwipe, int?> swipes = {
    CalendarSwipe.forward: null,
    CalendarSwipe.backward: null,
  };
  final Map<int, GlobalKey> _keys = {};
  final Map<int, double> _heights = {};
  final Set<int> _snaps = {};

  GlobalKey key(int index) => _keys.putIfAbsent(index, () => GlobalKey());

  void append(int index) {
    _snaps.add(index);
    if (index > 0 && index < (swipes[CalendarSwipe.forward] ?? double.infinity)) {
      swipes[CalendarSwipe.forward] = index;
    }if (index < 0 && index > (swipes[CalendarSwipe.backward] ?? -double.infinity)) {
      swipes[CalendarSwipe.backward] = index;
    }
  }

  double snapOffset(int index) {
    double offset = 0.0;
    if (index >= 0) {
      for (var i = 0; i < index; i++) {
        offset += _heights[i] ?? 0.0;
      }
    } else {
      for (var i = 0; i > index; i--) {
        offset -= _heights[i - 1] ?? 0.0;
      }
    }
    return offset;
  }

  (int, double) snap(double p) {
    int index = 0;
    double offset = 0.0;
    double distance = double.infinity;
    for (var i in _snaps) {
      final o = snapOffset(i);
      final d = (o - p).abs();
      if (d < distance) {
        index = i;
        offset = o;
        distance = d;
      }
    }
    return (index, offset);
  }

  void shift(int delta) {
    if (delta == 0) return;
    final shiftedHeights = <int, double>{};
    _heights.forEach((k, v) => shiftedHeights[k - delta] = v);
    _heights..clear()..addAll(shiftedHeights);
    final shiftedKeys = <int, GlobalKey>{};
    _keys.forEach((k, v) => shiftedKeys[k - delta] = v);
    _keys..clear()..addAll(shiftedKeys);
    // swipes[CalendarSwipe.forward] = delta;
    // swipes[CalendarSwipe.backward] = delta;
    _snaps..clear()..addAll(_snaps.map((k) => k - delta).toSet());

  }
}

class SnapPhysics extends ScrollPhysics {
  const SnapPhysics({super.parent, required this.metrics});

  final SnapMetrics metrics;

  @override
  bool get allowImplicitScrolling => false;

  @override
  SnapPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapPhysics(
      parent: buildParent(ancestor),
      metrics: metrics,
    );
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final (index, target) = metrics.snap(position.pixels);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: toleranceFor(position),
      );
    }
    return null;
  }
}