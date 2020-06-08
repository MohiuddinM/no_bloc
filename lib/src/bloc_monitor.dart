/// Callbacks which are sent by the blocs, can be used for debugging or side effects
/// [T] is the type of state value
/// [name] is the name of bloc, which sent the event
abstract class BlocMonitor<T> {
  /// Called when the bloc is being initialized
  /// Will be called even if initial state is null (isBusy = true)
  void onInit(String name, T initState) {}

  /// Called when a builder starts listening to this bloc's broadcasts
  void onStreamListener(String name) {}

  /// Called when the internal stream of the bloc is being disposed (because it has no more listeners)
  void onStreamDispose(String name) {}

  /// Called when bloc calls the [setState] method
  void onEvent(String name, T currentState, {String event}) {}

  /// Called when the bloc broadcasts a new state to the connected builders
  void onBroadcast(String name, T state, {String event}) {}

  /// Called whenever the bloc is set to busy
  void onBusy(String name, {String event}) {}

  /// Called whenever the bloc encounters an error
  void onError(String name, StateError error, {String event}) {}
}
