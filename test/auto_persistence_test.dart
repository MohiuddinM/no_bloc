import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:no_bloc/no_bloc.dart';
import 'package:test/test.dart';

class BlocPrinter extends BlocMonitor {
  @override
  void onEvent(String blocName, currentState, update, {String event}) {
    print('[$blocName] currentState: $currentState, update: $update ($event)');
  }

  @override
  void onBroadcast(String blocName, state, {String event}) {
    print('[$blocName] broadcast: $state ($event)');
  }
}

class CounterBloc extends AutoPersistedBloc<CounterBloc, int> {
  final int counterNumber;

  CounterBloc({@required this.counterNumber, int initialState}) : super(initialState: initialState, tag: counterNumber, monitor: BlocPrinter());

  void increment() => setState(value + 1, event: 'increment');

  void decrement() => setState(value - 1, event: 'decrement');
}

class MockPersistenceService extends Mock implements PersistenceService {}

void main() {
  HivePersistenceService.runningInTest = true;
  HivePersistenceService.databaseDirectory = '.';

  final counter1 = MockPersistenceService();
  final counter2 = MockPersistenceService();

  tearDownAll(() {});

  testBloc<CounterBloc, int>(
    'bloc should work with hive persistence',
    expectBefore: (bloc) async {
      expect(bloc.isBusy, true);
    },
    expectAfter: (bloc) async {},
    bloc: () async => CounterBloc(counterNumber: 1, initialState: 0),
    expectedStates: emitsInOrder([0, 1, 0]),
    job: (bloc) async {
      bloc.increment();
      bloc.decrement();
    },
  );

  test('bloc should recover initial state', () async {
    PersistenceService.use((name) => name == 'CounterBloc.1' ? counter1 : counter2);
    when(counter1.get<int>(any)).thenAnswer((realInvocation) async => 1);
    when(counter2.get<int>(any)).thenAnswer((realInvocation) async => 2);

    final bloc1 = CounterBloc(counterNumber: 1);
    final bloc2 = CounterBloc(counterNumber: 2);

    expect(bloc1.isBusy, true);
    expect(bloc2.isBusy, true);
    expect(() => bloc1.value, throwsA(TypeMatcher<AssertionError>()));
    expect(() => bloc2.value, throwsA(TypeMatcher<AssertionError>()));

    await Future.delayed(Duration(seconds: 1));

    expect(bloc1.value, 1);
    expect(bloc2.value, 2);

    verify(counter1.get(any)).called(1);
    verify(counter2.get(any)).called(1);
  });
}
