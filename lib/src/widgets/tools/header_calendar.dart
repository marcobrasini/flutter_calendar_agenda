import 'package:calendar/src/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modifier.dart';
import '../../viewer.dart';
import '../../config.dart';


typedef HeaderCallback = void Function();


class CalendarHeader extends StatelessWidget {

  final bool showButtons;

  const CalendarHeader({
    super.key,
    this.showButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewer = context.watch<CalendarViewer>();
    final modifier = context.watch<CalendarModifier>();
    final header = CalendarConfig.of(context)!.header;
    final color = header.background ?? Theme.of(context).primaryColor;
    final style = header.textStyle ?? TextStyle(
      color: Colors.white,
    );
    return Container(
      color: color,
      child: Row(
        children: [
          if (showButtons) IconButton(
              onPressed: (modifier.isResizing) ? null : () {
                viewer.swipe(CalendarSwipe.backward);
              },
              icon: Icon(Icons.arrow_left,
                color: style.color,
                size: style.fontSize,
              )
          ),
          Expanded(
            child: Center(
                child: Text(
                  viewer.title(context),
                  style: style,
                )
            ),
          ),
          if (showButtons) IconButton(
              onPressed: (modifier.isResizing) ? null : () {
                viewer.swipe(CalendarSwipe.forward);
              },
              icon: Icon(Icons.arrow_right,
                color: style.color,
                size: style.fontSize,
              )
          ),
        ],
      ),
    );
  }
}
