import 'package:no_bloc/no_bloc.dart';
import 'package:test/test.dart';

class CounterBloc extends Bloc<CounterBloc, int> {
  CounterBloc(int initState) : super(initialState: initState);

  void increment() => setState(value + 1);

  void decrement() => setState(value - 1);
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
}
