import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Runs [act] (awaiting it if async) and returns every state [cubit] emitted.
Future<List<S>> emissionsOf<S>(
  Cubit<S> cubit,
  FutureOr<void> Function() act,
) async {
  final states = <S>[];
  final sub = cubit.stream.listen(states.add);
  await act();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}
