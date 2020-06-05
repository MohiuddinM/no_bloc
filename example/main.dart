import 'package:no_bloc/no_bloc.dart';

class CounterBloc extends Bloc<CounterBloc, int> {
  CounterBloc() : super(initialState: 0);

  void increment() => setState(value + 1);

  void decrement() => setState(value - 1);
}

void main() {
  final bloc = CounterBloc();

  bloc.state.listen((s) => print(s));

  bloc.increment();
  bloc.decrement();
}
