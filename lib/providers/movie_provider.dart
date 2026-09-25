import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/tmdb_service.dart';
import '../services/firestore_service.dart';

class MovieProvider extends ChangeNotifier {
  final TmdbService _tmdbService = TmdbService();
  final FirestoreService _firestoreService = FirestoreService();

  List<Movie> _popularMovies = [];
  List<Movie> _nowPlayingMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _upcomingMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  bool _isLoading = false;
  String? _errorMessage;

  Movie? _selectedMovie;

  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get nowPlayingMovies => _nowPlayingMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get upcomingMovies => _upcomingMovies;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Movie? get selectedMovie => _selectedMovie;

  Future<void> fetchPopularMovies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _popularMovies = await _tmdbService.getPopularMovies();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHomeMovies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _popularMovies = await _tmdbService.getPopularMovies();
      _nowPlayingMovies = await _tmdbService.getNowPlayingMovies();
      _topRatedMovies = await _tmdbService.getTopRatedMovies();
      _upcomingMovies = await _tmdbService.getUpcomingMovies();
      _trendingMovies = await _tmdbService.getTrendingMovies();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMovieDetails(int movieId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedMovie = await _tmdbService.getMovieDetails(movieId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _movieToMap(Movie movie) {
    return {
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'posterPath': movie.posterPath,
      'backdropPath': movie.backdropPath,
      'releaseDate': movie.releaseDate,
      'voteAverage': movie.voteAverage,
      'runtime': movie.runtime,
      'genres': movie.genres,
    };
  }

  Future<void> addMovieToList(Movie movie, String listName) async {
    await _firestoreService.addMovieToList(_movieToMap(movie), listName);

    notifyListeners();
  }

  Future<void> removeMovieFromList(int movieId, String listName) async {
    await _firestoreService.removeMovieFromList(movieId, listName);

    notifyListeners();
  }

  Future<void> addToFavorites(Movie movie) async {
    await addMovieToList(movie, 'favorites');
  }

  Future<void> removeFromFavorites(int movieId) async {
    await removeMovieFromList(movieId, 'favorites');
  }

  Future<void> addToWatched(Movie movie) async {
    await addMovieToList(movie, 'watched');
  }

  Future<void> removeFromWatched(int movieId) async {
    await removeMovieFromList(movieId, 'watched');
  }

  Future<void> addToWatching(Movie movie) async {
    await addMovieToList(movie, 'watching');
  }

  Future<void> removeFromWatching(int movieId) async {
    await removeMovieFromList(movieId, 'watching');
  }

  Future<void> addToWantToWatch(Movie movie) async {
    await addMovieToList(movie, 'want_to_watch');
  }

  Future<void> removeFromWantToWatch(int movieId) async {
    await removeMovieFromList(movieId, 'want_to_watch');
  }

  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      _searchResults = await _tmdbService.searchMovies(query.trim());
    } catch (e) {
      _searchResults = [];
      _searchError = e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
}
