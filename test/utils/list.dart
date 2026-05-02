import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/utils/list.dart';


void main() {

  group('List<int>', () {

    test('positive shift', () {
      final list = [0,1,2,3,4];
      expect(list.roll(0), list);
      expect(list.roll(1), [4,0,1,2,3]);
      expect(list.roll(2), [3,4,0,1,2]);
      expect(list.roll(3), [2,3,4,0,1]);
      expect(list.roll(4), [1,2,3,4,0]);
      expect(list.roll(5), [0,1,2,3,4]);
    });

    test('negative shift', () {
      final list = [0,1,2,3,4];
      expect(list.roll(0), list);
      expect(list.roll(-1), [1,2,3,4,0]);
      expect(list.roll(-2), [2,3,4,0,1]);
      expect(list.roll(-3), [3,4,0,1,2]);
      expect(list.roll(-4), [4,0,1,2,3]);
      expect(list.roll(-5), [0,1,2,3,4]);
    });

  });
}