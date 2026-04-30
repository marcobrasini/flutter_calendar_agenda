import 'package:flutter/foundation.dart';


enum PatternType {
  daily,
  weekly,
  monthly,
  yearly,
}


class Pattern with Diagnosticable {

  Pattern({
    required this.since,
    required this.type,
    this.step = 1,
    this.count,
    this.until,
  });

  final PatternType type;
  final DateTime since;
  final int step;
  final int? count;
  final DateTime? until;

  @override
  int get hashCode => Object.hash(since, type, step, count, until);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is Pattern) {
      return other.since == since
          && other.type == type
          && other.step == step
          && other.count == count
          && other.until == until;
    }
    return false;
  }
}



