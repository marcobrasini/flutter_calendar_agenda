import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class WidgetMetrics with Diagnosticable {
  final GlobalKey key;
  double? offset;
  double? extent;
  bool snap = false;

  WidgetMetrics(this.key);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GlobalKey>('key', key));
    properties.add(DoubleProperty('offset', offset));
    properties.add(DoubleProperty('size', extent));
  }
}

//
// typedef ExtentCallback = void Function(double extent);
//
// class WidgetMeasured extends SingleChildRenderObjectWidget {
//   const WidgetMeasured({
//     super.key,
//     required this.axis,
//     required this.onExtent,
//     required super.child,
//   });
//
//   final Axis axis;
//   final ExtentCallback onExtent;
//
//   @override
//   RenderObject createRenderObject(BuildContext context) =>
//       _RenderMeasuredTile(axis, onExtent);
//
//   @override
//   void updateRenderObject(BuildContext context, _RenderMeasuredTile ro) {
//     ro..axis = axis..onExtent = onExtent;
//   }
// }
//
// class _RenderMeasuredTile extends RenderProxyBox {
//   _RenderMeasuredTile(this.axis, this.onExtent);
//
//   Axis axis;
//   ExtentCallback onExtent;
//   double? _last;
//
//   @override
//   void performLayout() {
//     super.performLayout();
//     final extent = axis == Axis.vertical ? size.height : size.width;
//     if (_last != extent) {
//       _last = extent;
//       onExtent(extent);
//     }
//   }
// }