import 'package:flutter/material.dart';
import '../../data/event.dart';
import '../../const.dart';


class SlotLayout {
  final Event event;
  final Rect container;
  final Rect content;
  final double padding;
  bool expanded;
  int level;
  int split;
  int order;
  int span;

  SlotLayout({
    required this.event,
    required this.container,
    required this.content,
    this.expanded = false,
    this.padding = eventSlotPadding,
    this.level = 0,
    this.order = 0,
    this.split = 1,
    this.span = 0,
  });

  double get top => container.top;
  double get height => container.height;
  double get left => (expanded)
      ? 0.0
      : container.left + order * column + offset;
  double get width => (expanded)
      ? container.width
      : column + span * column - offset;
  double get offset => level * eventOffset;
  double get column => container.width / split;

  Rect get rendered => (expanded)
      ? container
      : Rect.fromLTWH(left, top, width, height);

  Rect get safe => Rect.fromLTWH(
    left, top, width,
    content.height + 2 * padding,
  );
}