//Time --->
//
// Input Stream:
// ---(1)---(2)---(3)---(4)---|
//
// withPrevious Operator Applied
//
// Output Stream:
// ---------(1)---(2)---(3)---|


//return only previous value
extension WithPreviousExtension<T> on Stream<T> {
  Stream<T> withPrevious() async* {
    T? previous;
    bool hasPrevious = false;

    await for (var value in this) {
      if (hasPrevious) {
        yield previous!;
      }
      previous = value;
      hasPrevious = true;
    }
  }
}