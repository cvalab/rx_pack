import 'dart:async';

import 'package:rx_pack/rx_pack.dart';
import 'package:test/test.dart';


void main() {
  group('withPrevious Extension Tests', () {
    test('Should emit previous values after the first emission', () async {
      final stream = Stream.fromIterable([1, 2, 3, 4]);
      final result = await stream.withPrevious().toList();

      expect(result, equals([1, 2, 3]));
    });

    test('Should not emit any value if the stream has only one element', () async {
      final stream = Stream.fromIterable([1]);
      final result = await stream.withPrevious().toList();

      expect(result, isEmpty);
    });

    test('Should handle an empty stream', () async {
      final stream = Stream<int>.empty();
      final result = await stream.withPrevious().toList();

      expect(result, isEmpty);
    });

    test('Should work with different data types', () async {
      final stream = Stream.fromIterable(['a', 'b', 'c']);
      final result = await stream.withPrevious().toList();

      expect(result, equals(['a', 'b']));
    });

    test('Should handle streams with errors gracefully', () async {
      final controller = StreamController<int>();

      controller.add(1);
      controller.addError(Exception('Test exception'));
      controller.add(2);
      controller.close();

      final result = <int>[];
      final errors = <Exception>[];

      await controller.stream.withPrevious().listen(
        result.add,
        onError: errors.add,
      ).asFuture();

      expect(result, equals([1]));
      expect(errors.length, equals(1));
      expect(errors.first.toString(), equals('Exception: Test exception'));
    });

    test('Should work with a single subscription stream', () async {
      final controller = StreamController<int>();
      final stream = controller.stream.withPrevious();

      controller.add(1);
      controller.add(2);
      controller.add(3);
      controller.close();

      final result = await stream.toList();

      expect(result, equals([1, 2]));
    });

    test('Should handle a broadcast stream', () async {
      final stream = Stream.fromIterable([1, 2, 3, 4]).asBroadcastStream();
      final result1 = await stream.withPrevious().toList();
      final result2 = await stream.withPrevious().toList();

      expect(result1, equals([1, 2, 3]));
      expect(result2, equals([1, 2, 3]));
    });
  });
}
