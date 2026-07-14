import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/event.dart';
import '../../const.dart';


class SlotLayout {
  final Event event;
  Rect container;
  double content;
  double padding;
  double? parent;
  int split;
  int order;

  SlotLayout({
    required this.event,
    required this.container,
    this.content = 0.0,
    this.padding = 0.0,
    this.order = 0,
    this.split = 1,
  });

  bool get isExpanded => (parent == null) && order == 0 && split == 1;

  double get top => container.top;
  double get left => (parent ?? container.left) + order * column + offset;
  double get width => column - offset;
  double get height => container.height;
  double get column => (container.right - (parent ?? container.left)) / split;
  double get offset => (parent == null || order > 0) ? 0.0 : side;
  double get side => min(container.width/eventSlotOffsetRatio, eventSlotOffset);

  Rect get rendered => Rect.fromLTWH(left, top, width, height);

  Rect get safe => Rect.fromLTWH(
    left, top, width, content + 2 * padding,
  );

  static List<SlotLayout> layouts(List<SlotLayout> input) {
    final results = <SlotLayout>[];
    for (SlotLayout layout in input) {
      for (final other in results) {
        if (layout.container.overlaps(other.container)) {
          if (layout.container.overlaps(other.safe)) {
            other.split += 1;
            layout.split = other.split;
            layout.order = other.order + 1;
          } else {
            layout.parent = other.left;
          }
        }
      }
      results.add(layout);
      }
    return results;
  }
}