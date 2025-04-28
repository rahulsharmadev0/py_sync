import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

abstract class InMemoryCachedState<T> extends Cubit<T> {
  InMemoryCachedState(super.state, {Duration cacheDuration = const Duration(minutes: 1)});

  @override
  T get state {
    debugPrint('Fetching data from cache: ${super.state}');
    return super.state;
  }

  @override
  void onChange(Change<T> change) {
    debugPrint('Cached changed: ${change.currentState} -> ${change.nextState}');
    super.onChange(change);
  }
}

abstract class CachedState<T> extends HydratedCubit<T> {
  CachedState(super.state, {Duration cacheDuration = const Duration(minutes: 1)});

  @override
  T get state {
    debugPrint('Fetching data from cache: ${super.state}');
    return super.state;
  }

  @override
  void onChange(Change<T> change) {
    debugPrint('Cached changed: ${change.currentState} -> ${change.nextState}');
    super.onChange(change);
  }
}

/// Mixin to provide error handling behavior
mixin ErrorHandlingMixin {
  Future<T> handleErrors<T, R>(
    Future<T> Function() operation, {
    String? errorPrefix,
  }) async {
    try {
      print('[Api] Executing operation: $operation');
      await Future.delayed(const Duration(milliseconds: 500));
      return await operation.call();
    } catch (e) {
      final prefix = errorPrefix != null ? '$errorPrefix: ' : '';
      print('$prefix${e.toString()}');
      throw Exception('$prefix${e.toString()}');
    }
  }
}
