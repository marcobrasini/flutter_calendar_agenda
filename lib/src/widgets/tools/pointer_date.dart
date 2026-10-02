import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/datetime.dart';
import '../../context.dart';
import '../../picker.dart';
import '../../enums.dart';


class DatePointer extends StatelessWidget {
  const DatePointer({
    super.key,
    required this.view,
    required this.date,
    required this.width,
    required this.height,
  });

  final CalendarView view;
  final Date date;
  final double width;
  final double height;

  double get size => min(width, height);

  @override
  Widget build(BuildContext context) {
    final config = context.config;
    final dateConfig = config.dateConfig(view);
    final clockConfig = config.clock;
    final picker = context.read<CalendarPicker?>();
    final color = clockConfig.clockColor ?? context.colors.primary;
    return GestureDetector(
      onTap: () => picker?.pick(date),
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          if (date == Date.now()) Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              vertical: dateConfig.textPadding,
            ),
            child: Text(
              date.format(dateConfig.textFormat),
              textAlign: TextAlign.center,
              style: (dateConfig.textStyle ?? const TextStyle()).copyWith(
                color: (context.colors.brightness == Brightness.light)
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

