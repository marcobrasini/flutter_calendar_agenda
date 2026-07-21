import 'package:calendar/src/data/fixture.dart';
import 'package:flutter/material.dart';

import 'data/event.dart';
import 'enums.dart';

//
typedef SlotCallback<T extends Event> = void Function(T);
typedef PageCallback<T extends Event> = void Function(DateTime);
typedef FrameCallback<T extends Event> = void Function(Offset, [T?]);
//
typedef DragCallback<T extends Event> = void Function(T);
typedef CreateCallback<T extends Event> = void Function(Fixture);
typedef ModifyCallback<T extends Event> = void Function(T, Fixture);
typedef DeleteCallback<T extends Event> = void Function(T);
//
typedef EventBuilder<T extends Event> = Widget Function(BuildContext, T);
typedef ScrollBuilder = Widget Function(int);
typedef PageBuilder = Widget Function(DateTime);

const initialHour = 0;
const finalHour = Duration.hoursPerDay;
const stepHour = TimeStep.minutes60;

const initialDay = 0;
const finalDay = 7;

const initialWeek = 0;
const finalWeek = 6;

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
const timeHeaderRound = 15;
const timeHeaderRatio = 1.0;
const timeHeaderPadding = 4.0;

const lineFrameColor = Color(0xFFE0E0E0);
const lineFrameStyle = LineStyle.solid;
const lineFrameOffsetX = 0.0;
const lineFrameOffsetY = 0.0;
const lineFrameWidth = 1.0;
const dashFrameWidth = 4.0;
const dashFrameSpace = 4.0;
//
const viewSwipeDelay = Duration(milliseconds: 500);
const viewSwipeMargin = 20.0;
const viewSlideMargin = 40.0;

const timeIndicatorPeriod = Duration(minutes: 1);
const timeIndicatorLineWidth = 1.5;
const timeIndicatorPointRadius = 4.5;

const eventSlotOffset = 20.0;
const eventSlotOffsetRatio = 8;
const eventSlotLineDimmed = 0.25;
const eventSlotLineWidth = 2.5;
const eventDraggableSlotAlpha = 127;
const eventSlotPadding = 4.0;
const eventSlotRounded = 4.0;
const eventSlotDuration = Duration(milliseconds: 200);
