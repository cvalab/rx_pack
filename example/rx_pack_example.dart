import 'package:rx_pack/rx_pack.dart';

void main() {
  final stream = Stream.fromIterable([1, 2, 3, 4]).map((event) {
    print('emit $event');
    return event;
  });

  stream.withPrevious().listen((value) {
    print(value); // Output 1, 2, 3
  });
}
