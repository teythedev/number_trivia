import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';

import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateNiceMocks(
  [
    MockSpec<HttpClient>(),
  ],
)
void main() {
  late MockHttpClient mockHttpClient;
  late NumberTriviaRemoteDataSourceImpl numberTriviaRemoteDataSourceImpl;

  setUp(() {
    mockHttpClient = MockHttpClient();
    numberTriviaRemoteDataSourceImpl = NumberTriviaRemoteDataSourceImpl(
      httpClient: mockHttpClient,
    );
  });
}
