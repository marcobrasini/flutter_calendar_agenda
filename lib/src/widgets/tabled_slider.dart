import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


/// Mantiene fermo il contenuto che segue quando lo scrollExtent
/// dello sliver figlio cambia mentre la vista è scrollata.
class SliverKeepOffset extends SingleChildRenderObjectWidget {
  const SliverKeepOffset({super.key, required Widget sliver})
      : super(child: sliver);

  @override
  RenderSliverKeepOffset createRenderObject(BuildContext context) =>
      RenderSliverKeepOffset();
}


class RenderSliverKeepOffset extends RenderProxySliver {
  double? _lastExtent;

  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    final geometry = child!.geometry!;
    final last = _lastExtent;
    _lastExtent = geometry.scrollExtent;

    // Correggo solo se la vista è scrollata: in cima lo snap è visibile
    // e il body DEVE spostarsi per fargli spazio.
    if (last != null &&
        geometry.scrollOffsetCorrection == null &&
        geometry.scrollExtent != last &&
        constraints.scrollOffset > 0) {
      final correction = math.max(
        geometry.scrollExtent - last,
        -constraints.scrollOffset,
      );
      if (correction != 0) {
        this.geometry = SliverGeometry(scrollOffsetCorrection: correction);
        return;
      }
    }
    this.geometry = geometry;
  }
}