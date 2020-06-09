import 'package:no_bloc/no_bloc.dart';

import 'bloc.dart';
import 'persistence_service.dart';

/// If bloc is not a singleton then tags must be provided to differential between different instances, otherwise different instances will overwrite each other
abstract class AutoPersistedBloc<R, S> extends PersistedBloc<R, S> {
  AutoPersistedBloc({S initialState, tag, BlocMonitor monitor}) : super(initialState: initialState, monitor: monitor, tag: tag, autoPersistence: true, recoverStateOnStart: true);
}

abstract class PersistedBloc<R, S> extends Bloc<R, S> {
  final bool autoPersistence;
  final bool recoverStateOnStart;
  final Object tag;

  PersistedBloc({S initialState, BlocMonitor monitor, this.tag, this.autoPersistence = false, this.recoverStateOnStart = false})
      : super(initialState: (autoPersistence && recoverStateOnStart) ? null : initialState, monitor: monitor) {
    if (autoPersistence && recoverStateOnStart) {
      persistenceService.get<S>('value').then((got) {
        if (got == null) {
          if (initialState != null) {
            // if initialState is null then the bloc's is already set to busy
            super.setState(initialState, event: 'initializing');
          }
        } else {
          super.setState(got, event: 'recovered_state');
        }
      });
    }
  }

  PersistenceService get persistenceService => PersistenceService('$R.${tag ?? 0}');

  @override
  void setState(S state, {String event = 'BlocOp'}) {
    super.setState(state, event: event);

    if (value == state && autoPersistence) {
      persistenceService.set('value', value);
    }
  }
}
