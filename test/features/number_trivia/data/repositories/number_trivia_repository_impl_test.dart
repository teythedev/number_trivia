import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/core/error/failure.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NumberTriviaRemoteDataSource>()])
@GenerateNiceMocks([MockSpec<NumberTrivialocalDataSource>()])
@GenerateNiceMocks([MockSpec<NetworkInfo>()])
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDataSource mockNumberTriviaRemoteDataSource;
  late MockNumberTrivialocalDataSource mockNumberTrivialocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNumberTriviaRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockNumberTrivialocalDataSource = MockNumberTrivialocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockNumberTriviaRemoteDataSource,
      localDataSource: mockNumberTrivialocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group(
    'getContreteNumberTrivia',
    () {
      const tNumber = 1;
      const tNumberTriviaModel = NumberTriviaModel(
        number: 1,
        text: "test",
      );
      const NumberTrivia tNumberTrivia = tNumberTriviaModel;
      test(
        'should check the device is online',
        () async {
          // arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          // act
          await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockNetworkInfo.isConnected);
        },
      );

      runTestsOnline(() {
        test(
          'should return remote data when the call to remote data source is successful',
          () async {
            // arrange
            when(
              mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber),
            ).thenAnswer(
              (_) async => tNumberTriviaModel,
            );
            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);
            // assert
            verify(mockNumberTriviaRemoteDataSource
                .getConcreteNumberTrivia(tNumber));
            expect(
              result,
              equals(
                const Right(tNumberTrivia),
              ),
            );
          },
        );

        test(
          'should cache the data locally when the call to remote data source is successful',
          () async {
            // arrange
            when(
              mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber),
            ).thenAnswer(
              (_) async => tNumberTriviaModel,
            );
            // act
            await repository.getConcreteNumberTrivia(tNumber);
            // assert
            verify(
              mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber),
            );

            verify(
              mockNumberTrivialocalDataSource
                  .cacheNumberTrivia(tNumberTriviaModel),
            );
          },
        );

        test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
            // arrange
            when(
              mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber),
            ).thenThrow(
              ServerException(),
            );
            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);
            // assert
            verify(
              mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber),
            );
            verifyZeroInteractions(mockNumberTrivialocalDataSource);
            expect(
              result,
              equals(
                Left(
                  ServerFailure(),
                ),
              ),
            );
          },
        );
      });
      runTestsOffline(() {
        test(
          'should return last locally cached data when cahce data is present',
          () async {
            // arrange
            when(mockNumberTrivialocalDataSource.getLastNumberTrivia())
                .thenAnswer(
              (_) async => tNumberTriviaModel,
            );
            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);
            // assert
            verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
            verify(mockNumberTrivialocalDataSource.getLastNumberTrivia());
            expect(result, equals(const Right(tNumberTrivia)));
          },
        );

        test(
          'should return CacheFailure when there is no cache data present',
          () async {
            // arrange
            when(mockNumberTrivialocalDataSource.getLastNumberTrivia())
                .thenThrow(
              CahceException(),
            );
            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);
            // assert
            verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
            verify(mockNumberTrivialocalDataSource.getLastNumberTrivia());
            expect(
              result,
              equals(
                Left(
                  CahceFailure(),
                ),
              ),
            );
          },
        );
      });
    },
  );

  group(
    'getRandomNumberTrivia',
    () {
      const tNumberTriviaModel = NumberTriviaModel(
        number: 1,
        text: "test",
      );
      const NumberTrivia tNumberTrivia = tNumberTriviaModel;
      test(
        'should check the device is online',
        () async {
          // arrange
          when(mockNetworkInfo.isConnected).thenAnswer(
            (_) async => true,
          );
          // act
          await repository.getRandomNumberTrivia();
          // assert
          verify(mockNetworkInfo.isConnected);
        },
      );

      runTestsOnline(
        () {
          test(
            'should return random remote data when the call to remote data source is successful',
            () async {
              // arrange
              when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
                  .thenAnswer((_) async => tNumberTriviaModel);
              // act
              final result = await repository.getRandomNumberTrivia();
              // assert
              verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
              expect(
                  result,
                  equals(
                    const Right(tNumberTrivia),
                  ));
            },
          );

          test(
            'should cahce the data locally when the call to remote data source is successfull',
            () async {
              // arrange
              when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
                  .thenAnswer(
                (_) async => tNumberTriviaModel,
              );
              // act
              await repository.getRandomNumberTrivia();
              // assert
              verify(
                mockNumberTriviaRemoteDataSource.getRandomNumberTrivia(),
              );
              verify(
                mockNumberTrivialocalDataSource.cacheNumberTrivia(
                  tNumberTriviaModel,
                ),
              );
            },
          );

          test(
            'should return Server failure when the call remote data source is unsuccessfull',
            () async {
              // arrange
              when(
                mockNumberTriviaRemoteDataSource.getRandomNumberTrivia(),
              ).thenThrow(
                ServerException(),
              );
              // act
              final result = await repository.getRandomNumberTrivia();
              // assert
              verify(
                mockNumberTriviaRemoteDataSource.getRandomNumberTrivia(),
              );
              verifyZeroInteractions(
                mockNumberTrivialocalDataSource,
              );
              expect(
                result,
                equals(
                  Left(
                    ServerFailure(),
                  ),
                ),
              );
            },
          );
        },
      );
      runTestsOffline(
        () {
          test(
            'should return last locally cached data when cache data present',
            () async {
              // arrange
              when(mockNumberTrivialocalDataSource.getLastNumberTrivia())
                  .thenAnswer(
                (_) async => tNumberTriviaModel,
              );
              // act
              final result = await repository.getRandomNumberTrivia();
              // assert
              verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
              verify(mockNumberTrivialocalDataSource.getLastNumberTrivia());
              expect(
                result,
                equals(
                  const Right(tNumberTrivia),
                ),
              );
            },
          );

          test(
            'should return Cache Failure when there is no cache data present',
            () async {
              // arrange
              when(mockNumberTrivialocalDataSource.getLastNumberTrivia())
                  .thenThrow(
                CahceException(),
              );
              // act
              final result = await repository.getRandomNumberTrivia();
              // assert
              verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
              verify(mockNumberTrivialocalDataSource.getLastNumberTrivia());
              expect(
                result,
                equals(
                  Left(
                    CahceFailure(),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
