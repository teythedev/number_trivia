import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List properties = <dynamic>[];

  @override
  List<Object?> get props => properties;
}

//General failure
class ServerFailure extends Failure {}

class CahceFailure extends Failure {}
