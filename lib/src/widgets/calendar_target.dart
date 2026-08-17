import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/datetime.dart';
import '../utils/schemes.dart';
import '../data/fixture.dart';


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


class DropWidget extends SingleChildRenderObjectWidget {
  const DropWidget({
    super.key,
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
    renderObject..registry = registry..delegate = delegate;
  }
}


class RenderDrop extends RenderProxyBox {
  RenderDrop(this._registry, this.delegate);

  DropRegistry _registry;
  DropDelegate delegate;

  DropRegistry get registry => _registry;
  set registry(DropRegistry value) {
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
  int get origin => timeScheme.from.hour * Duration.minutesPerHour
      + timeScheme.from.minute;

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
    stop:  at(rect.bottomCenter, size),
  );
}


class TileDropDelegate extends DropDelegate {
  TileDropDelegate(this.date, [this.dateScheme]);
  final Date date;
  final DateScheme? dateScheme;

  @override
  DateTime at(Offset offset, Size size) {
    final dateScale = dateScheme?.scale(size.width) ?? 0.0;
    final days = (offset.dx * dateScale).floor() + (dateScheme?.beg ?? 0);
    return (date + days);
  }

  @override
  Fixture resolve(Rect local, Size size, Fixture fixture) {
    final days = date % fixture.start.date;
    return Fixture(
      start: fixture.start.add(Duration(days: days)),
      stop:  fixture.stop.add(Duration(days: days)),
    );
  }
}