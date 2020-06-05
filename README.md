A Dart library to make blocs easy again.

Checkout the flutter version too: 

## Why?
Existing bloc packages require too much "State and Event" boilerplate, and expose underlying Streams complexity.

## Pros 👍
- Easy to use and works out of the box
- Complete abstraction over Streams and Subscriptions
- No more states or events boilerplate bloat (just work with functions)

## Example
Easy Bloc hides all *streams*/*yields*, exposing only simple functions **setState()**, **setBusy()** and **setError()**:

```dart
import 'package:no_bloc/no_bloc.dart';

class CounterBloc extends Bloc {
  void increment() => setState(value + 1);
  void decrement() => setState(value - 1);
}

void main() {
  final bloc = CounterBloc();
  
  bloc.increment();
}
```

&nbsp; 

##### A bit more complex bloc:
```dart
import 'package:no_bloc/no_bloc.dart';

class CounterBloc extends Bloc {
  void increment() async {
    if (value >= 10) {
      setError(StateError('Counter cannot go beyond 10'));
    }
    
    setBusy();
    await makeNetworkCall();
    
    setState(value + 1);
  }

  void decrement() => setState(value - 1);
}

void main() async {
  final bloc = CounterBloc();
  
  await bloc.increment();
}
```


## Contribution ❤
Issues and pull requests are welcome

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
