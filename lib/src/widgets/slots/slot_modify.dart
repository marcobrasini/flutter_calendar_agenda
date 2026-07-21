import 'package:flutter/material.dart';
import '../../enums.dart';


@immutable
class SlotModifier {
  const SlotModifier({
    required this.selected,
    required this.editing,
    required this.container,
    required this.action,
  });

  final bool selected;
  final bool editing;
  final Rect? container;
  final SlotAction? action;

  @override
  bool operator ==(Object other) => identical(this, other) || (
      other is SlotModifier
          && other.selected == selected
          && other.editing == editing
          && other.action == action
          && other.container == container);

  @override
  int get hashCode => Object.hash(selected, editing, action, container);
}
