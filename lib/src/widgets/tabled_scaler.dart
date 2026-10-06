import 'package:flutter/widgets.dart';
import '../scaler.dart';


class TabledScaler extends StatelessWidget {
  const TabledScaler({
    super.key,
    required this.scaler,
    required this.bodyTop,
    required this.child,
  });

  final CalendarScaler scaler;
  final double bodyTop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => scaler.down(event, bodyTop),
      onPointerMove: (event) => scaler.move(event, bodyTop),
      onPointerUp: scaler.up,
      onPointerCancel: scaler.up,
      child: child,
    );
  }
}
