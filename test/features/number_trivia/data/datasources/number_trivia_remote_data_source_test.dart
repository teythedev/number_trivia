import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateNiceMocks(
  [
    MockSpec<http.Client>(),
  ],
)
void main() {
  late MockClient mockClient;
  late NumberTriviaRemoteDataSourceImpl numberTriviaRemoteDataSourceImpl;

  setUp(() {
    mockClient = MockClient();
    numberTriviaRemoteDataSourceImpl = NumberTriviaRemoteDataSourceImpl(
      httpClient: mockClient,
    );
  });

  void setUpMockClientSuccess200() {
    when(
      mockClient.get(
        any,
        headers: anyNamed('headers'),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        fixture('trivia.json'),
        200,
      ),
    );
  }

  void setUpMockClientError404() {
    when(
      mockClient.get(
        any,
        headers: anyNamed('headers'),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        'Something goes wrong',
        404,
      ),
    );
  }

  group(
    "getConcreteNumberTrivia",
    () {
      const tNumber = 1;
      final tNumberTriviaModel = NumberTriviaModel.fromJson(
        json.decode(
          fixture('trivia.json'),
        ),
      );

      test(
        '''should perfom a Get request on a URL with number being 
      the endpoint and with application/json header''',
        () async {
          // arrange
          setUpMockClientSuccess200();
          // act
          numberTriviaRemoteDataSourceImpl.getConcreteNumberTrivia(tNumber);
          // assert
          verify(
            mockClient.get(
              Uri.http(
                'numbersapi.com',
                '/$tNumber',
              ),
              headers: {'Content-Type': 'application/json'},
            ),
          );
        },
      );
      test(
        'should return number trivia when the response code is 200 (success)',
        () async {
          // arrange
          setUpMockClientSuccess200();
          // act
          final result = await numberTriviaRemoteDataSourceImpl
              .getConcreteNumberTrivia(tNumber);
          // assert
          expect(
            result,
            equals(tNumberTriviaModel),
          );
        },
      );

      test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
          // arrange
          setUpMockClientError404();
          // act
          final call = numberTriviaRemoteDataSourceImpl.getConcreteNumberTrivia;
          // assert
          expect(
            () => call(tNumber),
            throwsA(
              const TypeMatcher<ServerException>(),
            ),
          );
        },
      );
    },
  );
  group(
    "getRandomNumberTrivia",
    () {
      final tNumberTriviaModel = NumberTriviaModel.fromJson(
        json.decode(
          fixture('trivia.json'),
        ),
      );

      test(
        '''should perfom a Get request on a URL with number being 
      the endpoint and with application/json header''',
        () async {
          // arrange
          setUpMockClientSuccess200();
          // act
          numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia();
          // assert
          verify(
            mockClient.get(
              Uri.http(
                'numbersapi.com',
                '/random',
              ),
              headers: {'Content-Type': 'application/json'},
            ),
          );
        },
      );
      test(
        'should return number trivia when the response code is 200 (success)',
        () async {
          // arrange
          setUpMockClientSuccess200();
          // act
          final result =
              await numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia();
          // assert
          expect(
            result,
            equals(tNumberTriviaModel),
          );
        },
      );

      test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
          // arrange
          setUpMockClientError404();
          // act
          final call = numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia;
          // assert
          expect(
            () => call(),
            throwsA(
              const TypeMatcher<ServerException>(),
            ),
          );
        },
      );
    },
  );
}
