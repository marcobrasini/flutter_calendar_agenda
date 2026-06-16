import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';


typedef HeaderCallback = void Function();


class CalendarHeader extends StatelessWidget {

  final String title;
  final HeaderCallback next;
  final HeaderCallback last;
  final bool showButtons;

  const CalendarHeader({
    super.key,
    required this.title,
    required this.last,
    required this.next,
    this.showButtons = true,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: last,
              icon: Icon(Icons.arrow_left,
                color: style.color,
                size: style.fontSize,
              )
          ),
          Expanded(
            child: Center(
                child: Text(
                  title,
                  style: style,
                )
            ),
          ),
          if (showButtons) IconButton(
              onPressed: next,
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
