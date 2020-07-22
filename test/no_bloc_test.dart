import 'package:no_bloc/no_bloc.dart';
import 'package:test/test.dart';

class BroadcastPrinter extends BlocMonitor {
  @override
  void onBroadcast(String blocName, state, {String event}) {
    print('[$blocName] broadcast: $state ($event)');
  }
}

class CounterBloc extends Bloc<CounterBloc, int> {
  CounterBloc(int initialState)
      : super(initialState: initialState, monitor: BroadcastPrinter());

  void increment() => setState(value + 1, event: 'increment');

  void decrement() => setState(value - 1, event: 'decrement');
}

void main() {
  testBloc<CounterBloc, int>(
    'counter should work',
    bloc: () async => CounterBloc(0),
    expectBefore: (bloc) async => expect(bloc.isBusy, false),
    expectAfter: (bloc) async => expect(bloc.hasError, false),
    timeout: Duration(seconds: 1),
    expectedStates: emitsInOrder([0, 1, 2, 1]),
    job: (bloc) async {
      bloc.increment();
      bloc.increment();
      bloc.decrement();
    },
  );

  testBloc<CounterBloc, int>(
    'setting busy should not change value',
    bloc: () async => CounterBloc(0),
    expectBefore: (bloc) async => expect(bloc.isBusy, false),
    expectAfter: (bloc) async {
      expect(bloc.value, 1);
      expect(bloc.isBusy, true);
    },
    timeout: Duration(seconds: 1),
    expectedStates: emitsInOrder([0, 1]),
    job: (bloc) async {
      bloc.increment();
      // ignore: invalid_use_of_protected_member
      bloc.setBusy();
    },
  );

  testBloc<CounterBloc, int>(
    'setting error should not change value',
    bloc: () async => CounterBloc(0),
    expectBefore: (bloc) async => expect(bloc.isBusy, false),
    expectAfter: (bloc) async {
      expect(bloc.value, 1);
      expect(bloc.hasError, true);
    },
    timeout: Duration(seconds: 1),
    expectedStates: emitsInOrder([0, 1]),
    job: (bloc) async {
      bloc.increment();
      // ignore: invalid_use_of_protected_member
      bloc.setError(StateError('error'));
    },
  );
}
