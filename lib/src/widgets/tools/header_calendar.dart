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
    return Container(
      color: Theme.of(context).primaryColorLight,
      child: Row(
        children: [
          if (showButtons) IconButton(
              onPressed: last,
              icon: Icon(Icons.arrow_left,
                color: header.textStyle?.color,
                size: header.textStyle?.fontSize,
              )
          ),
          Expanded(
            child: Center(
                child: Text(
                  title,
                  style: header.textStyle,
                )
            ),
          ),
          if (showButtons) IconButton(
              onPressed: next,
              icon: Icon(Icons.arrow_right,
                color: header.textStyle?.color,
                size: header.textStyle?.fontSize,
              )
          ),
        ],
      ),
    );
  }
}
