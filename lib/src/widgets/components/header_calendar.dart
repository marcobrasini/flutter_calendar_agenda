import 'package:flutter/material.dart';


typedef HeaderCallback = void Function();


class CalendarHeader extends StatelessWidget {

  const CalendarHeader({
    super.key,
    required this.title,
    required this.last,
    required this.next,
    this.textStyle,
  });

  final String title;
  final HeaderCallback next;
  final HeaderCallback last;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColorLight,
      child: Row(
        children: [
          IconButton(
              onPressed: last,
              icon: Icon(Icons.arrow_left,
                color: textStyle?.color,
                size: textStyle?.fontSize,
              )
          ),
          Expanded(
            child: Center(
                child: Text(title,
                  style: textStyle,
                )
            ),
          ),
          IconButton(
              onPressed: next,
              icon: Icon(Icons.arrow_right,
                color: textStyle?.color,
                size: textStyle?.fontSize,
              )
          ),
        ],
      ),
    );
  }
}
