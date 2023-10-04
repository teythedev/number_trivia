// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:number_trivia/core/error/exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/number_trivia_model.dart';

abstract class NumberTrivialocalDataSource {
  /// Gets the [NumberTriviaModel] which was gotten
  /// the last time the user had an internet connection
  ///
  /// Throws [CacheException] if no cached data is present
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(
    NumberTriviaModel triviaToCahce,
  );
}

// ignore: constant_identifier_names
const CACHED_NUMBER_TRIVIA = "CACHED_NUMBER_TRIVIA";

class NumberTrivialocalDataSourceImpl implements NumberTrivialocalDataSource {
  SharedPreferences sharedPreferences;
  NumberTrivialocalDataSourceImpl({
    required this.sharedPreferences,
  });

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = sharedPreferences.getString(CACHED_NUMBER_TRIVIA);
    if (jsonString != null) {
      return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString)));
    } else {
      throw CahceException();
    }
  }

  @override
  Future<void> cacheNumberTrivia(
    NumberTriviaModel triviaToCahce,
  ) async {
    final expectedJsonString = json.encode(
      triviaToCahce.toJson(),
    );
    sharedPreferences.setString(
      CACHED_NUMBER_TRIVIA,
      expectedJsonString,
    );
  }
}
