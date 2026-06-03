import 'dart:ui';
import 'enums.dart';

const initialHour = 0;
const finalHour = 24;
const initialDay = DateTime.monday;
const finalDay = DateTime.sunday;

const timeHeaderPadding = 8.0;
const textHeaderPadding = 0.0;
const textLineSpacing = 1.5;

const dayHeaderFormat = "EEE";
const dateHeaderFormat = "EEE\nd";
const timeHeaderFormat = "HH:mm";

const eventMaxLines = 1;

const lineFrameColor = Color(0xFFE0E0E0);
const lineFrameStyle = LineStyle.solid;
const lineFrameOffsetX = 0.0;
const lineFrameOffsetY = 0.0;
const lineFrameWidth = 1.0;
const dashFrameWidth = 4.0;
const dashFrameSpace = 4.0;

const dayMonthSlots = 7;
const weekMonthSlots = 5;