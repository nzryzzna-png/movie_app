import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/movie_model.dart';

class TmdbService {
  final String _token = const String.fromEnvironment('TMDB_TOKEN');

  Future<List<Movie>> getPopularMovies() async {
    return _getMovies(
      'https://api.themoviedb.org/3/movie/popular?language=en-US&page=1',
    );
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    return _getMovies(
      'https://api.themoviedb.org/3/movie/now_playing?language=en-US&page=1',
    );
  }

  Future<List<Movie>> getTopRatedMovies() async {
    return _getMovies(
      'https://api.themoviedb.org/3/movie/top_rated?language=en-US&page=1',
    );
  }

  Future<List<Movie>> getUpcomingMovies() async {
    return _getMovies(
      'https://api.themoviedb.org/3/movie/upcoming?language=en-US&page=1',
    );
  }

  Future<List<Movie>> getTrendingMovies() async {
    return _getMovies(
      'https://api.themoviedb.org/3/trending/movie/week?language=en-US',
    );
  }

  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://api.themoviedb.org/3/movie/$movieId?language=en-US',
            ),
            headers: {
              'Authorization': 'Bearer $_token',
              'accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Movie.fromJson(data);
      }

      if (response.statusCode == 401) {
        throw Exception('TMDB authentication failed.');
      }

      if (response.statusCode >= 500) {
        throw Exception('TMDB server is unavailable.');
      }

      throw Exception('Failed to load movie details: ${response.statusCode}');
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    return _getMovies(
      'https://api.themoviedb.org/3/search/movie?query=${Uri.encodeComponent(query)}&language=en-US&page=1',
    );
  }

  Future<List<Movie>> _getMovies(String url) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_token',
              'accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List results = data['results'] ?? [];

        return results.map((movie) => Movie.fromJson(movie)).toList();
      }

      if (response.statusCode == 401) {
        throw Exception('TMDB authentication failed.');
      }

      if (response.statusCode >= 500) {
        throw Exception('TMDB server is unavailable.');
      }

      throw Exception('Failed to load movies: ${response.statusCode}');
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    }
  }
}
