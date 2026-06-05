import 'package:calendar/src/const.dart';
import 'package:flutter/material.dart';


typedef SwipeCallback = void Function();


class SwipePage extends StatefulWidget {
  const SwipePage({
    super.key,
    required this.last,
    required this.next,
  });

  final SwipeCallback last;
  final SwipeCallback next;

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  Offset _startPosition = Offset.zero;
  Offset _endPosition = Offset.zero;
  bool _isDragging = false;
  double get _horizontal => _endPosition.dx - _startPosition.dx;
  double get _vertical => _endPosition.dy - _startPosition.dy;


  void _onHorizontalDragStart(DragStartDetails details) {
    _startPosition = details.localPosition;
    _isDragging = true;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _endPosition = details.localPosition;
    if (_isDragging) {
      final velocity = details.velocity.pixelsPerSecond.dx;
      if (velocity.abs() > swipeSpeed) {
        if (_horizontal > swipeLength) {
          widget.last();
        } else if (_horizontal < -swipeLength) {
          widget.next();
        }
      }
    }
    _isDragging = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragEnd: _onHorizontalDragEnd,
    );
  }
}
