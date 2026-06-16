import 'package:flutter/material.dart';


extension MyColor on Color {

  Color dimmer(double dim) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness(
        (hsl.lightness - dim).clamp(0.0, 1.0)
      ).toColor();
  }

}