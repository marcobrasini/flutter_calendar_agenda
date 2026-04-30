import 'package:flutter/foundation.dart';


enum PatternType {
  daily,
  weekly,
  monthly,
  yearly,
}


class Pattern with Diagnosticable {

  Pattern({
    required this.type,
    required this.since,
    this.frequency = 1,
    this.count,
    this.until,
  });

  final PatternType type;
  final DateTime since;
  final int frequency;
  final int? count;
  final DateTime? until;

}



