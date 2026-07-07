// import 'package:calendar/src/source.dart';
// import 'package:flutter/material.dart';
// import '../tools/slot_date.dart';
// import '../tools/tile_event.dart';
// import '../../utils/datetime.dart';
// import '../../data/source.dart';
// import '../../config.dart';
//
//
// class SlotPage extends StatelessWidget {
//   const SlotPage({
//     super.key,
//     required this.date,
//     required this.width,
//     required this.height,
//   });
//
//   final Date date;
//   final double width;
//   final double height;
//
//   @override
//   Widget build(BuildContext context) {
//     final dateConfig = CalendarConfig.of(context)!.date!;
//     final source = context.watch<CalendarSource>();
//     final events = source.forDate(date);
//     return DateSlot(
//       date: date,
//       width: width,
//       height: height,
//       dateFormat: dateConfig.format,
//       datePadding: dateConfig.padding,
//       dateTextStyle: dateConfig.textStyle,
//       dateBackground: dateConfig.background,
//       dateWidget: events.isEmpty ? null : Column(
//         mainAxisSize: MainAxisSize.min,
//         children: events.map((e) => EventTile(
//           event: e,
//           width: width,
//         )) .toList(),
//       ),
//     );
//   }
// }
