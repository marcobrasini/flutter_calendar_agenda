import 'package:calendar/src/const.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:flutter/material.dart';
import '../config.dart';


class AgendaHeader extends StatelessWidget {

  final Date dateStart;
  final Date? dateStop;
  final VoidCallback? onTap;

  const AgendaHeader({
    super.key,
    required this.dateStart,
    this.dateStop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context);
    final format = config.header.format ?? defaultDateFormat;
    return Builder(
        builder: (context) {
          return Row(
            children: [
              if (config.view.showHeaderButton) IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_left),
              ),
              Expanded(
                child: GestureDetector(
                onTap: config.view.showHeaderButton ? onTap : null,
                  child: config.header.builder?.call(
                      context, dateStart, dateStop!
                  ) ?? Padding(
                    padding: EdgeInsetsGeometry.all(config.header.padding),
                    child: Text(
                      dateStart.format(format),
                      style: config.header.textStyle,
                    ),
                  ),
                ),
              ),
              if (config.view.showHeaderButton) IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_right),
              ),
            ],
          );
        }
    );
  }
}
