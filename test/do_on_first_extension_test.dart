import 'dart:async';
import 'package:rx_pack/rx_pack.dart';
import 'package:rx_pack/src/do_on_first_extension.dart';
import 'package:test/test.dart';

void main() {
  test('do only one time', () async {
    var callCount = 0;
    final controller = StreamController<int>();
    final stream = controller.stream.doOnFirstData((data) {
      callCount++;
    });

    final collectedData = <int>[];
    stream.listen(collectedData.add);

    controller.add(1);
    controller.add(2);
    controller.add(3);
    await controller.close();

    expect(callCount, 1);
    expect(collectedData, [1, 2, 3]);
  });

  test('onFirstData получает правильное первое значение', () async {
    int? firstData;
    final controller = StreamController<int>();
    final stream = controller.stream.doOnFirstData((data) {
      firstData = data;
    });

    final collectedData = <int>[];
    stream.listen(collectedData.add);

    controller.add(42);
    controller.add(100);
    await controller.close();

    expect(firstData, 42);
    expect(collectedData, [42, 100]);
  });

  test('Исключение в onFirstData попадает в результирующий стрим', () async {
    final controller = StreamController<int>();
    final stream = controller.stream.doOnFirstData((data) {
      throw Exception('Ошибка в onFirstData');
    });

    final errors = <Object>[];
    final collectedData = <int>[];
    stream.listen(
      collectedData.add,
      onError: errors.add,
    );

    controller.add(1);
    controller.add(2);
    await controller.close();

    expect(errors.length, 1);
    expect(errors.first.toString(), contains('Ошибка в onFirstData'));
    expect(collectedData, [2]);
  });

  test('Ошибки из исходного стрима проходят через doOnFirstData', () async {
    final controller = StreamController<int>();
    final stream = controller.stream.doOnFirstData((data) {});

    final errors = <Object>[];
    final collectedData = <int>[];
    stream.listen(
      collectedData.add,
      onError: errors.add,
    );

    controller.add(1);
    controller.addError(Exception('Ошибка из исходного стрима'));
    controller.add(2);
    await controller.close();

    expect(errors.length, 1);
    expect(errors.first.toString(), contains('Ошибка из исходного стрима'));
    expect(collectedData, [1, 2]);
  });

  test('Стрим корректно закрывается', () async {
    final controller = StreamController<int>();
    final stream = controller.stream.doOnFirstData((data) {});

    var isDone = false;
    stream.listen(
          (_) {},
      onDone: () {
        isDone = true;
      },
    );

    controller.add(1);
    await controller.close();

    expect(isDone, isTrue);
  });
}