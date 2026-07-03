import 'package:calendar/src/modifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../slots/slot_event.dart';
import '../slots/slot_layout.dart';


class DropPage extends StatefulWidget {
  const DropPage({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  State<DropPage> createState() => _DropPageState();
}

class _DropPageState extends State<DropPage> {
  final GlobalKey _boxKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modifier = context.read<CalendarModifier>();
      modifier.attachRenderer(
            () => _boxKey.currentContext?.findRenderObject() as RenderBox?,
      );
      modifier.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final modifier = context.watch<CalendarModifier>();
    return SizedBox(
      key: _boxKey,
      width: widget.width,
      height: widget.height,
      child: (!modifier.drawing)
          ? const SizedBox.shrink()
          : IgnorePointer(
        child: _Feedback(
          boxKey: _boxKey,
          layout: modifier.layout!,
          globalPosition: modifier.globalOffset!,
          grabOffset: modifier.localOffset!,
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.boxKey,
    required this.layout,
    required this.globalPosition,
    required this.grabOffset,
  });

  final GlobalKey boxKey;
  final SlotLayout layout;
  final Offset globalPosition;
  final Offset grabOffset;

  @override
  Widget build(BuildContext context) {
    final box = boxKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) {
      return const SizedBox.shrink();
    }
    final local = box.globalToLocal(globalPosition - grabOffset);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: local.dx - layout.left,
          top: local.dy,
          width: layout.container.width,
          height: layout.container.height,
          child: Material(
            child: EventSlot(
                layout: layout,
                resizing: true,
            ),
          ),
        ),
      ],
    );
  }
}
