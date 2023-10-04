import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../repositories/number_trivia_repository_impl_test.mocks.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
void main() {
  late NumberTrivialocalDataSourceImpl numberTrivialocalDataSourceImpl;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    numberTrivialocalDataSourceImpl = NumberTrivialocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group(
    'getLastNumberTrivia',
    () {
      final tNumberTriviaModel = NumberTriviaModel.fromJson(
        json.decode(
          fixture(
            'trivia_cache.json',
          ),
        ),
      );
      test(
        'should return NumberTriviaModel from SharedPreferences when there is one in the cache',
        () async {
          // arrange
          when(mockSharedPreferences.getString(any)).thenReturn(
            fixture('trivia_cache.json'),
          );
          // act
          final result =
              await numberTrivialocalDataSourceImpl.getLastNumberTrivia();
          // assert
          verify(
            mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA),
          );
          expect(
            result,
            equals(tNumberTriviaModel),
          );
        },
      );
      test(
        'should throw CacheException when there is no one in the cache',
        () async {
          // arrange
          when(mockSharedPreferences.getString(any)).thenReturn(null);
          // act
          final call = numberTrivialocalDataSourceImpl.getLastNumberTrivia;
          // assert
          expect(
            () => call(),
            throwsA(
              const TypeMatcher<CahceException>(),
            ),
          );
        },
      );
    },
  );

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'test');
    test(
      'should call SharedPreferences to cache the data',
      () async {
        // act
        numberTrivialocalDataSourceImpl.cacheNumberTrivia(tNumberTriviaModel);
        // assert
        final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
        verify(
          mockSharedPreferences.setString(
            CACHED_NUMBER_TRIVIA,
            expectedJsonString,
          ),
        );
      },
    );
  });
}
