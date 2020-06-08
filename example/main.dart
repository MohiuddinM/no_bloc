import 'package:no_bloc/no_bloc.dart';

class BroadcastPrinter extends BlocMonitor {
  @override
  void onBroadcast(String blocName, state, {String event}) {
    print('[$blocName] broadcast: $state ($event)');
  }
}

class CounterBloc extends Bloc<CounterBloc, int> {
  CounterBloc() : super(initialState: 0, monitor: BroadcastPrinter());

  // event names are optional and only used for debugging purpose
  void increment() => setState(value + 1, event: 'increment');
  void decrement() => setState(value - 1, event: 'decrement');
}

void main() {
  final bloc = CounterBloc();

  bloc.state.listen((s) => print(s));

  bloc.increment();
  bloc.decrement();
}
