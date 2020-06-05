import 'dart:async';

import 'package:hive/hive.dart';

typedef PersistenceServiceBuilder = PersistenceService Function(String name);

abstract class PersistenceService {
  static PersistenceServiceBuilder _builder;

  static void use(PersistenceServiceBuilder builder) {
    _builder = builder;
  }

  factory PersistenceService(String name) {
    assert(name != null);
    return _builder == null ? HivePersistenceService(name) : _builder(name);
  }

  Future<void> set(String key, value);

  Future<T> get<T>(String key);

  Future<void> clear();
}

class HivePersistenceService implements PersistenceService {
  static String databaseDirectory;
  final _box = Completer<Box>();

  HivePersistenceService(name) {
    _initialize(name, databaseDirectory);
  }

  void _initialize(name, String directory) async {
    assert(directory != null);
    Hive.init(directory);
    _box.complete(Hive.openBox(name));
  }

  @override
  Future<S> get<S>(String key) async {
    PersistenceService.use((name) => HivePersistenceService(name));
    final box = await _box.future;
    final value = box.get(key);
    assert(value is S || value == null, 'the type you are trying to get is not the same as what you saved');
    return value as S;
  }

  bool _isPrimitiveOrSerializable(value) {
    final type = value.runtimeType;
    if (type == num || type == String || type == DateTime || type == bool) {
      return true;
    }

    try {
      value.toJson();
      return true;
    } on NoSuchMethodError {
      return false;
    }
  }

  operator [](Object key) {
    // TODO: implement []
    throw UnimplementedError();
  }

  void operator []=(key, value) {
    // TODO: implement []=
  }

  void remove(Object key) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future<void> set(String key, value) async {
    assert(value != null);
    assert(_isPrimitiveOrSerializable(value));
    final box = await _box.future;
    return box.put(key, value);
  }

  @override
  Future<void> clear() async {
    final box = await _box.future;
    await box.clear();
  }
}
