import 'dart:ui';
import 'enums.dart';

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
