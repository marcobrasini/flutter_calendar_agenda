import 'dart:math';
import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import '../../utils/datetime.dart';
import '../../context.dart';


class DateSlot extends StatelessWidget {

  const DateSlot({
    super.key,
    this.width,
    this.height,
    required this.date,
    required this.config,
    this.dateWidget,
  });

  final Date date;
  final double? width;
  final double? height;
  final TextConfig config;
  final Widget? dateWidget;

  double get size => min(width ?? double.infinity, height ?? double.infinity);

  @override
  Widget build(BuildContext context) {
    final callbacks = context.config.callbacks;
    return GestureDetector(
      onTap: () => callbacks.onFrameTap?.call(date),
      child: Container(
        width: width,
        height: height,
        color: config.textBackground,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: config.textPadding,
              ),
              child: Text(
                date.format(config.textFormat),
                textAlign: TextAlign.center,
                style: config.textStyle
              ),
            ),
            ?dateWidget,
          ],
        ),
      ),
    );
  }

}