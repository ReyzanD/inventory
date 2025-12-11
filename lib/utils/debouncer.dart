import 'dart:async';

class Debouncer {
  Timer? _timer;

  void call(void Function() action, {int milliseconds = 500}) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}