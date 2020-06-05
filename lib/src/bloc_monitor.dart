/// Callbacks which are sent by the blocs, can be used for debugging or side effects
/// [T] is the type of state value
/// [name] is the name of bloc, which sent the event
abstract class BlocMonitor<T> {
  void onInit(String name, T initState) {}

  void onStreamListener(String name) {}

  void onStreamDispose(String name) {}

  void onEvent(String name, T currentState, {String event}) {}

  void onBroadcast(String name, T state, {String event}) {}

  void onBusy(String name, {String event}) {}

  void onError(String name, StateError error, {String event}) {}
}
