import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calendar_agenda/src/context.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../data/fixture.dart';
import '../source.dart';

class DropRegistry {
  final Set<RenderDrop> _zones = {};
  final ValueNotifier<RenderDrop?> hovered = ValueNotifier(null);

  void add(RenderDrop z) => _zones.add(z);
  void remove(RenderDrop z) {
    _zones.remove(z);
    if (identical(hovered.value, z)) hovered.value = null;
  }

  RenderDrop? at(Offset global) {
    RenderDrop? best;
    for (final z in _zones) {
      if (!z.attached || !z.hasSize) continue;
      if (!(Offset.zero & z.size).contains(z.globalToLocal(global))) continue;
      if (best == null || z.depth > best.depth) best = z;
    }
    return best;
  }

  void dispose() => hovered.dispose();
}

class DropWidget extends StatelessWidget {
  const DropWidget({
    super.key,
    required this.child,
    required this.registry,
    required this.delegate,
  });

  final Widget child;
  final DropRegistry registry;
  final DropDelegate delegate;

  @override
  Widget build(BuildContext context) {
    DateTime resolve(Offset local) {
      final box = context.findRenderObject() as RenderBox;
      return delegate.at(local, box.size);
    }

    final callbacks = context.config.callbacks;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) => callbacks.onFrameTap?.call(resolve(d.localPosition)),
      onDoubleTapDown: (d) =>
          callbacks.onFrameDoubleTap?.call(resolve(d.localPosition)),
      onLongPressStart: (d) =>
          callbacks.onFrameLongPress?.call(resolve(d.localPosition)),
      child: _DropZone(registry: registry, delegate: delegate, child: child),
    );
  }
}

class _DropZone extends SingleChildRenderObjectWidget {
  const _DropZone({
    required super.child,
    required this.registry,
    required this.delegate,
  });

  final DropRegistry registry;
  final DropDelegate delegate;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderDrop(registry, delegate);

  @override
  void updateRenderObject(BuildContext context, RenderDrop renderObject) {
    renderObject
      ..registry = registry
      ..delegate = delegate;
  }
}

class RenderDrop extends RenderProxyBox {
  RenderDrop(this._registry, this.delegate);

  DropRegistry _registry;
  DropDelegate delegate;

  DropRegistry get registry => _registry;
  set registry(DropRegistry value) {
    if (identical(value, _registry)) return;
    if (attached) {
      _registry.remove(this);
      value.add(this);
    }
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
}

abstract class DropDelegate {
  bool accepts(Fixture event) => true;
  Fixture resolve(Rect rect, Size size, Fixture fixture);
  DateTime at(Offset offset, Size size);
}

class SlotDropDelegate extends DropDelegate {
  SlotDropDelegate(this.date, this.timeScheme, [this.dateScheme]);
  final Date date;
  final TimeScheme timeScheme;
  final DateScheme? dateScheme;
  int get step => timeScheme.round;
  int get origin =>
      timeScheme.from.hour * Duration.minutesPerHour + timeScheme.from.minute;

  @override
  DateTime at(Offset offset, Size size) {
    final dateScale = dateScheme?.scale(size.width) ?? 0.0;
    final days = (offset.dx * dateScale).floor() + (dateScheme?.beg ?? 0);
    final timeScale = timeScheme.scale(size.height);
    final minutes = origin + (offset.dy * timeScale / step).round() * step;
    final extra = (minutes / Duration.minutesPerDay).floor();
    final within = minutes - extra * Duration.minutesPerDay;
    return (date + days + extra) & Time.fromMinutes(within);
  }

  @override
  Fixture resolve(Rect rect, Size size, Fixture fixture) => Fixture(
    start: at(rect.topCenter, size),
    stop: at(rect.bottomCenter, size),
  );
}

class TileDropDelegate extends DropDelegate {
  TileDropDelegate(this.date, {this.dateScheme, this.forceAllDay = false});

  final Date date;
  final DateScheme? dateScheme;
  final bool forceAllDay;

  @override
  DateTime at(Offset offset, Size size) {
    final dateScale = dateScheme?.scale(size.width) ?? 0.0;
    final days = (offset.dx * dateScale).floor() + (dateScheme?.beg ?? 0);
    return (date + days);
  }

  @override
  Fixture resolve(Rect local, Size size, Fixture fixture) {
    final shift = (dateScheme == null && size.width > 0)
        ? (local.left / size.width).round()
        : 0;
    final days = (date + shift) % fixture.start.date;
    if (forceAllDay) {
      final stopDay =
          fixture.stop.isAfter(fixture.start) &&
              fixture.stop.isAtSameMomentAs(fixture.stop.date)
          ? fixture.stop.date - 1
          : fixture.stop.date;
      final start = fixture.start.date.start;
      final stop = stopDay.end;
      return Fixture(
        start: start.add(Duration(days: days)),
        stop: stop.add(Duration(days: days)),
      );
    }
    return Fixture(
      start: fixture.start.add(Duration(days: days)),
      stop: fixture.stop.add(Duration(days: days)),
    );
  }
}
