import 'package:calendar/src/config.dart';
import 'package:calendar/src/controller.dart';
import 'package:calendar/src/modifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


typedef HeaderCallback = void Function();


class CalendarHeader extends StatelessWidget {

  final bool showButtons;

  const CalendarHeader({
    super.key,
    this.showButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalendarController>();
    final modifier = context.watch<CalendarModifier>();
    modifier.attachController(controller);
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
              onPressed: (modifier.isResizing) ? null : controller.last,
              icon: Icon(Icons.arrow_left,
                color: style.color,
                size: style.fontSize,
              )
          ),
          Expanded(
            child: Center(
                child: Text(
                  controller.title(context),
                  style: style,
                )
            ),
          ),
          if (showButtons) IconButton(
              onPressed: (modifier.isResizing) ? null : controller.next,
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
