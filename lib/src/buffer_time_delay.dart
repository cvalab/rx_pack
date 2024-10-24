import 'dart:async';

// Work like bufferTime() operator, but with initial delay
//Input Stream:   A----B--C-------D------E----F--G---|
//                     |       |        |         |
//                     v       v        v         v
// Timers Start:     [Initial][Duration][Duration][End]
// Flush Times (s):    2        7        12       End
//
// Output Stream:  -----[A]-------[B,C]------[D,E,F]---[G]|
extension BufferTimeExtension<T> on Stream<T> {
  Stream<List<T>> bufferTimeDelay(
    Duration duration, {
    Duration initialDelay = Duration.zero,
  }) {
    return transform(StreamTransformer<T, List<T>>((input, cancelOnError) {
      final controller = StreamController<List<T>>();
      final List<T> buffer = [];
      StreamSubscription<T>? subscription;
      Timer? timer;

      void flushBuffer() {
        if (buffer.isNotEmpty) {
          controller.add(List<T>.from(buffer));
          buffer.clear();
        }
      }

      void startTimer(Duration delay) {
        timer?.cancel();
        timer = Timer(delay, () {
          flushBuffer();
          startTimer(duration);
        });
      }

      controller
        ..onListen = () {
          //Timer does not start here

          subscription = input.listen(
            (data) {
              buffer.add(data);

              //Run the timer when the first data arrives
              if (timer == null) {
                startTimer(initialDelay);
              }
            },
            onError: controller.addError,
            onDone: () {
              // Send the remaining data when the stream is closed
              flushBuffer();
              controller.close();
            },
            cancelOnError: cancelOnError,
          );
        }
        ..onPause = () {
          subscription?.pause();
          timer?.cancel();
          timer = null;
        }
        ..onResume = () {
          subscription?.resume();
          //Resume the timer only if it was stopped
          if (timer == null && buffer.isNotEmpty) {
            startTimer(duration);
          }
        }
        ..onCancel = () async {
          await subscription?.cancel();
          timer?.cancel();
          timer = null;
        };

      return controller.stream.listen(null);
    }));
  }
}
