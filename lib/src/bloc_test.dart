import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

import 'bloc.dart';

typedef FutureVoidCallback = Future<void> Function();
typedef BlocCallback<R> = Future<void> Function(R);
typedef BlocTestBloc<R> = Future<R> Function();
typedef BlocTestTransform<S, T> = T Function(S);
typedef BlocTestVoidCallback = void Function();

/// R = Type of bloc
/// S = Type of State
void testBloc<R extends Bloc<R, S>, S>(
  String name, {
  FutureVoidCallback setup,
  BlocTestBloc<R> bloc,
  BlocCallback<R> expectBefore,
  BlocCallback<R> expectAfter,
  StreamMatcher expectedStates,
  BlocCallback<R> job,
  BlocTestTransform<S, dynamic> transform,
}) async {
  test(name, () async {
    await setup();
    final _bloc = await bloc();
    final stream = _bloc.state.where((event) => event != null);
    unawaited(expectLater(transform == null ? stream : stream.map((event) => transform(event)), expectedStates));
    if (expectBefore != null) {
      await expectBefore(_bloc);
    }
    await job(_bloc);
    if (expectAfter != null) {
      await expectAfter(_bloc);
    }
  });
}
