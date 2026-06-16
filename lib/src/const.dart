import 'package:calendar/src/data/fixture.dart';
import 'package:flutter/material.dart';

import 'data/event.dart';
import 'enums.dart';

typedef EventCallback = void Function(Event);
typedef FrameCallback = void Function(int, [int]);
typedef LayoutCallback = void Function(Event, Offset);
typedef ModifyCallback = void Function(Event, Fixture);
typedef EventBuilder = Widget Function(Event);


// class Sized extends StatelessWidget {
//   const Sized({
//     super.key,
//     this.top = 0.0,
//     this.left = 0.0,
//     required this.width,
//     required this.height,
//     this.child,
//   });
//   final double top;
//   final double left;
//   final double width;
//   final double height;
//   final Widget? child;
//
//   Rect get box => Rect.fromLTWH(0.0, 0.0, width, height);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       height: height,
//       child: child,
//     );
//   }
// }

const initialHour = 0;
const finalHour = Duration.hoursPerDay;
const stepHour = TimeStep.minutes60;

const initialDay = DateTime.monday;
const finalDay = DateTime.sunday;

const initialWeek = 0;
const finalWeek = 6;

const timeHeaderPadding = 8.0;
const textHeaderPadding = 0.0;
const textHeaderMargin = 0.0;
const textLineSpacing = 1.5;
const textSlotPadding = 4.0;
const textSlotLines = 1;

const dailyHeaderFormat = "d MMMM yyyy";
const dailyHeaderPadding = 0.0;
const dailyDateFormat = "EEEE";
const dailyDatePadding = 0.0;

const weeklyHeaderFormat = "d MMMM yyyy";
const weeklyHeaderPadding = 0.0;
const weeklyDateFormat = "EEE\nd";
const weeklyDatePadding = 0.0;

const monthlyHeaderFormat = "MMMM yyyy";
const monthlyHeaderPadding = 0.0;
const monthlyWeekFormat = "EEE";
const monthlyWeekPadding = 0.0;
const monthlyDateFormat = "d";
const monthlyDatePadding = 0.0;

const timeHeaderFormat = "HH:mm";
const timeHeaderRatio = 1.0;

const lineFrameColor = Color(0xFFE0E0E0);
const lineFrameStyle = LineStyle.solid;
const lineFrameOffsetX = 0.0;
const lineFrameOffsetY = 0.0;
const lineFrameWidth = 1.0;
const dashFrameWidth = 4.0;
const dashFrameSpace = 4.0;

const swipeLength = 50;
const swipeSpeed = 100;
const swipeDuration = Duration(milliseconds: 300);
const dragEdgeSpace = 50.0;
const dragEdgeDelay = Duration(milliseconds: 500);

const timeIndicatorPeriod = Duration(minutes: 1);
const timeIndicatorLineWidth = 1.5;
const timeIndicatorPointRadius = 4.5;

const eventOffset = 20.0;
const eventResizeDelay = Duration(milliseconds: 200);
const eventResizableLineDimmed = 0.25;
const eventResizableLineWidth = 2.5;
const eventDraggableSlotAlpha = 127;
const eventSlotPadding = 4.0;
const eventSlotRounded = 4.0;