import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movie_flix/models/constants.dart';
import 'package:movie_flix/models/now_playing_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:movie_flix/models/top_rated_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationModel extends ChangeNotifier {
  bool darkThemeForCompleteApp;

  ApplicationModel({required this.darkThemeForCompleteApp});

  //API requests
  Future<NowPlayingResponseModel> getNowPlayingList() async {
    print("application_model.dart: getNowPlayingList() called");
    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey'));
    log("application_model.dart: getNowPlayingList() response code: ${response.statusCode}, response body: ${response.body}");
    if (response.statusCode == 200) {
      return NowPlayingResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch Now Playing list.');
    }
  }

  Future<TopRatedResponseModel> getTopRatedList() async {
    print("application_model.dart: getTopRatedList() called");
    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey'));
    log("application_model.dart: getTopRatedList() response code: ${response.statusCode}, response body: ${response.body}");
    if (response.statusCode == 200) {
      return TopRatedResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch Top Rated list.');
    }
  }

  //SharedPreferences request
  Future<void> saveTheme(bool darkTheme, SharedPreferences preferences) async {
    preferences.setBool("darkTheme", darkTheme);
    darkThemeForCompleteApp = darkTheme;
    notifyListeners();
    print("application_model.dart: theme saved. Dark Theme: $darkTheme");
  }
}
