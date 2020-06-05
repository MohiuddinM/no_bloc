import 'package:no_bloc/no_bloc.dart';
import 'package:test/test.dart';

class CalcBloc extends Bloc<CalcBloc, int> {
  CalcBloc(int initState) : super(initialState: initState);

  void add(int i) => setState(value + i);

  void sub(int i) => setState(value - i);
}

void main() {
  test('stream should emit correct state', () {
    final bloc = CalcBloc(0);

    expectLater(bloc.state, emitsInOrder([0, 1, 2, 3, 4]));

    bloc.add(1);
    bloc.add(1);
    bloc.add(1);
    bloc.sub(-1);
  });

  test('stream should be set initialState if provided', () async {
    final bloc = CalcBloc(0);

    expect(await bloc.state.first, 0);
  });

  test('stream should set busy if initialState is null', () async {
    final bloc = CalcBloc(null);

    expect(bloc.isBusy, true);
  });
}
