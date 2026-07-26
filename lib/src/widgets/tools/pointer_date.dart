import 'package:flutter/material.dart';
import '../../utils/datetime.dart';
import '../../config.dart';


class DatePointer extends StatelessWidget {
  const DatePointer({
    super.key,
    required this.date,
    this.focus = false,
  });

  final Date date;
  final bool focus;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    final color = config.view.indicatorColor
        ?? Theme.of(context).primaryColor;
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: focus ? color : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            date.format("dd"),
            style: TextStyle(
                color: focus ? Colors.white : Colors.black
            ),
          ),
        ),
      ),
    );
  }
}

