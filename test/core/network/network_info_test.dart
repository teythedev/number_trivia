import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'network_info_test.mocks.dart';

@GenerateNiceMocks(
  [
    MockSpec<DataConnectionChecker>(),
  ],
)
void main() {
  late MockDataConnectionChecker mockDataConnectionChecker;
  late NetworkInfoImpl networkInfoImpl;
  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    networkInfoImpl =
        NetworkInfoImpl(connectionChecker: mockDataConnectionChecker);
  });

  group(
    'isConnected',
    () {
      test(
        'should forward the call to MockDataConnectionChecker.hasConnection',
        () async {
          final tHasConnectionFuture = Future.value(true);
          // arrange
          when(mockDataConnectionChecker.hasConnection)
              .thenAnswer((_) => tHasConnectionFuture);

          // act
          final result = networkInfoImpl.isConnected;
          // assert
          verify(mockDataConnectionChecker.hasConnection);
          expect(result, tHasConnectionFuture);
        },
      );
    },
  );
}
