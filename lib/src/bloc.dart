import 'package:built_value/built_value.dart';
import 'package:no_bloc/src/bloc_monitor.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// The central class behind this library
///
/// It is responsible for processing all the events and broadcasting corresponding
/// changes made to the state.
/// [R] is the type which subclasses [Bloc]
/// [S] is the type of [value] which this bloc broadcasts. [S] must implement equality
abstract class Bloc<R, S> {
  static bool checkIfImplementsEquality = true;
  final BlocMonitor _monitor;
  StateError _error;
  bool _isBusy = true;
  BehaviorSubject<S> _state;
  S _value;

  /// [initialState] is the state which is set at initialization. if its null, the initial state is set to busy.
  Bloc({S initialState, BlocMonitor monitor})
      : _value = initialState,
        _monitor = monitor {
    _monitor?.onInit('$R', _value);
    if (initialState != null) assert(implementsEquality(initialState));
    if (_value != null) {
      _isBusy = false;
    }
  }

  /// Broadcast Stream to which all builders listen
  ///
  /// This stream is created only when there is a listener, and is automatically cleaned
  /// when there are no listeners are left. State change broadcasts are discarded when there
  /// are no listeners.
  Stream<S> get state {
    _monitor?.onStreamListener('$R');
    if (_state == null) {
      if (_value == null) {
        _state = BehaviorSubject<S>();
      } else {
        _state = BehaviorSubject.seeded(value);
      }

      _state.onCancel = () {
        if (!_state.hasListener) {
          _monitor?.onStreamDispose('$R');
          // no need to close, because we don't have any listeners and this is the only reference (so GC will handle clean up)
          _state = null;
        }
      };
    }

    return _state.stream;
  }

  S get value {
    assert(_value != null, 'value cannot be used before it is set (did you forgot to set initialState)');
    return _value;
  }

  bool get isBusy => _isBusy;

  bool get hasError => _error != null;

  StateError get error => _error;

  /// Called to calculate the new state
  ///
  /// This function takes [currentState] and the planned [update] state
  /// and returns the state which would be broadcast and will become the current state
  ///
  /// Originally it just discards the current state and returns the [update] as the next state.
  /// This behavior can of course be overridden
  @protected
  S nextState(S currentState, S update) {
    return update;
  }

  /// Called by blocs (subclasses) when the state is updated
  ///
  /// [isBusy] and [error] are cleared whenever the state is updated
  /// Optional argument [event] is the name of event which is calling [setState]
  @protected
  void setState(S state, {String event}) {
    assert(state != null);
    assert(implementsEquality(state));
    _monitor?.onEvent('$R', _value, state, event: event);
    _isBusy = false;
    _error = null;
    final next = nextState(_value, state);

    // only broadcast if the state has actually changed
    if (next != _value) {
      _value = next;
      if (_state != null) {
        _state.add(_value);
        _monitor?.onBroadcast('$R', _value, event: event);
      }
    }
  }

  /// Called by blocs (subclasses) when an error occurs
  ///
  /// [isBusy] is cleared whenever an [error] is set
  /// Optional argument [event] is the name of event which is calling [setError]
  @protected
  void setError(StateError error, {String event}) {
    assert(error != null);
    if (_error == error) return;
    _monitor?.onError('$R', error, event: event);
    _isBusy = false;
    _error = error;
    _state?.add(null);
  }

  /// Called by blocs (subclasses) when the updated state isn't available immediately
  ///
  /// This should be used when a bloc is waiting for an async operation (e.g. a network call)
  /// [error] is cleared whenever [isBusy] is set
  /// Optional argument [event] is the name of event which is calling [setError]
  @protected
  void setBusy({String event}) {
    if (_isBusy) return;
    _monitor?.onBusy('$R', event: event);
    _isBusy = true;
    _error = null;
    _state?.add(null);
  }
}

/// Just a utility function to make sure if the state type implements equality (by default dart classes only support referential equality).
///
/// This library will not work if equality is not implemented. If you are manually overriding == and hashCode for your classes
/// instead of using [Equatable] or [Built], then you have to set [Bloc.checkIfImplementsEquality] to false, to avoid getting false errors.
bool implementsEquality(value) {
  return (!Bloc.checkIfImplementsEquality || value is num || value is String || value is DateTime || value is bool || value is Equatable || value is Built);
}
