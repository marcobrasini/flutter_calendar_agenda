import 'package:calendar/src/context.dart';
import 'package:calendar/src/modifier.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:calendar/src/widgets/pages/page_frame.dart';
import 'package:calendar/src/widgets/scroll/scroll_slot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ScrollWidget extends StatelessWidget {

  const ScrollWidget({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.callbacks,
    required this.timeScheme,
    required this.dateScheme,
    required this.offset,
  });

  final Date date;
  final double width;
  final double height;
  final TimeScheme timeScheme;
  final DateScheme dateScheme;
  double get timeScale => timeScheme.scale(height);
  double get dateScale => dateScheme.scale(width);
  final CallbackScheme callbacks;
  final Offset offset;

  DateTime converter(Date date, Offset local) {
    print("$date, $local");
    final days = (local.dx * dateScale).floor() + dateScheme.beg;
    print(date + days);
    return date + days;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarEvents>();
    context.read<CalendarModifier>().attachConverter(converter);
    final space = width / dateScheme.count;
    final dateOffset = context.dateOffset();
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          PageFrame(
            width: width,
            height: height,
            timeScheme: timeScheme,
            dateScheme: dateScheme,
            onTap: (local, [_]) => callbacks.onFrameTap?.call(converter(date, local)),
            onDoubleTap: (local, [_]) => callbacks.onFrameDoubleTap?.call(converter(date, local)),
            onLongPress: (local, [_]) => callbacks.onFrameLongPress?.call(converter(date, local)),
          ),
          for (int i = dateScheme.beg; i < dateScheme.end; i++)
            Positioned(
              left: (i - dateScheme.beg) * space,
              width: space,
              child: SizedBox(
                width: space,
                height: height,
                child: Column(children: [
                  SizedBox(
                    width: space,
                    height: dateOffset,
                    child: Center(child: Text((date + i).format("dd"))),
                  ),
                  ScrollSlot(
                    date: date + i,
                    width: space,
                    height: height - dateOffset,
                    callbacks: callbacks,
                    offset: offset + Offset((i - dateScheme.beg) * space, dateOffset),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }

}



