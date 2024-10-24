import 'dart:async';

extension DoOnFirstDataExtension<T> on Stream<T> {
  Stream<T> doOnFirstData(
      void Function(T event) onFirstData,
      ) {
    var isFirstData = true;
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) {
          if (isFirstData) {
            isFirstData = false;
            try {
              onFirstData(data);
            } catch (error, stackTrace) {
              sink.addError(error, stackTrace); //add error to stream
              return;
            }
          }
          sink.add(data);
        },
        handleError: (error, stackTrace, sink) {
          sink.addError(error, stackTrace);
        },
        handleDone: (sink) {
          sink.close();
        },
      ),
    );
  }
}