/// Callbacks which are sent by the blocs, can be used for debugging or side effects
///
/// [T] is the type of state value
/// [blocName] is the name of bloc, which sent the event
abstract class BlocMonitor<T> {
  /// Called when the bloc is being initialized
  ///
  /// Will be called even if initial state is null (isBusy = true)
  void onInit(String blocName, T initState) {}

  /// Called when a builder starts listening to this bloc's broadcasts
  void onStreamListener(String blocName) {}

  /// Called when the internal stream of the bloc is being disposed (because it has no more listeners)
  void onStreamDispose(String blocName) {}

  /// Called when bloc calls the [setState] method
  void onEvent(String blocName, T currentState, T update, {String event}) {}

  /// Called when the bloc broadcasts a new state to the connected builders
  void onBroadcast(String blocName, T state, {String event}) {}

  /// Called whenever the bloc is set to busy
  void onBusy(String blocName, {String event}) {}

  /// Called whenever the bloc encounters an error
  void onError(String blocName, StateError error, {String event}) {}
}
