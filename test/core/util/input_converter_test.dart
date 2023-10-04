import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;
  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringtoUnsignedInt', () {
    test(
      'should retun an integer when the string represents an unsigned integer',
      () async {
        // arrange
        const str = "123";
        // act
        final result = inputConverter.stringToUnsignedInteger(str);
        // assert
        expect(
          result,
          equals(
            const Right(123),
          ),
        );
      },
    );
    test(
      'should return a failure when the string is not represents an integer',
      () async {
        // arrange
        const str = "comolokko";
        // act
        final result = inputConverter.stringToUnsignedInteger(str);
        // assert
        expect(
          result,
          equals(
            Left(
              InvalidInpuFailure(),
            ),
          ),
        );
      },
    );
    test(
      'should return a failure when the string represents a negative integer',
      () async {
        // arrange
        const str = '-1';
        // act
        final result = inputConverter.stringToUnsignedInteger(str);
        // assert
        expect(
          result,
          equals(
            Left(
              InvalidInpuFailure(),
            ),
          ),
        );
      },
    );
  });
}
