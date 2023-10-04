import 'package:dartz/dartz.dart';
import 'package:number_trivia/core/error/failure.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      final integerValue = int.parse(str);
      if (integerValue < 0) throw const FormatException();
      return Right(integerValue);
    } on FormatException {
      return Left(InvalidInpuFailure());
    }
  }
}

class InvalidInpuFailure extends Failure {}
