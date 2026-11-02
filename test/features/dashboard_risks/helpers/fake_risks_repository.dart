import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/entities/risk.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/repositories/risks_repository.dart';

import '../fixtures/risks_fixture.dart';

class FakeRisksRepository implements RisksRepository {
  List<Risk> risks = [...expectedRisks];
  Failure? failure;
  Completer<void>? gate;

  @override
  Future<Either<Failure, List<Risk>>> getRisks() async {
    await gate?.future;
    return failure != null ? Left(failure!) : Right(risks);
  }
}
