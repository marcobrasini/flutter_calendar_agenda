import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/event.dart';
import '../../controller.dart';
import '../../const.dart';
import '../../config.dart';


typedef DragOffsetCallback = void Function(Event event, Offset localPosition);


class DragPage extends StatefulWidget {

  const DragPage({
    super.key,
    required this.onAccept,
    this.edgeDelay = dragEdgeDelay,
    this.edgeSpace = dragEdgeSpace,
  });

  final DragOffsetCallback onAccept;
  final Duration edgeDelay;
  final double edgeSpace;

  @override
  State<DragPage> createState() => _DragPageState();
}

class _DragPageState extends State<DragPage> {
  Timer? _edgeTimer;
  int? _activeEdge;

  @override
  void dispose() {
    _edgeTimer?.cancel();
    super.dispose();
  }

  Offset position(DragTargetDetails<Event> details) {
    final box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(details.offset);
  }

  int? _onEdge(Offset position, BoxConstraints constraints) {
    final config = CalendarConfig.of(context)!;
    switch (config.view.swipeDirection) {
      case Axis.vertical:
        if (position.dy <= widget.edgeSpace) return -1;
        if (position.dy >= constraints.maxHeight - widget.edgeSpace) return 1;
        break;
      case Axis.horizontal:
        if (position.dx <= widget.edgeSpace) return -1;
        if (position.dx >= constraints.maxWidth - widget.edgeSpace) return 1;
        break;
    }
    return null;
  }

  void _onMove(DragTargetDetails<Event> details, BoxConstraints constraints) {
    final edge = _onEdge(position(details), constraints);
    if (edge == _activeEdge) return;
    _edgeTimer?.cancel();
    _activeEdge = edge;
    if (edge != null) {
      _edgeTimer = Timer(widget.edgeDelay, () {
        final controller = context.read<CalendarController>();
        (edge < 0) ? controller.last() : controller.next();
        _activeEdge = null;
      });
    }
  }

  void _onLeave() {
    _edgeTimer?.cancel();
    _activeEdge = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DragTarget<Event>(
          builder: (context, candidateData, rejectedData)
              => const SizedBox.expand(),
          onMove: (details) => _onMove(details, constraints),
          onLeave: (_) => _onLeave(),
          onAcceptWithDetails: (details) {
            _onLeave();
            final box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.offset);
            widget.onAccept(details.data, localPosition);
          },
        );
      },
    );
  }
}
