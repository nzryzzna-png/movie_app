import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class MovieListScreen extends StatefulWidget {
  final String listName;
  final String title;

  const MovieListScreen({
    super.key,
    required this.listName,
    required this.title,
  });

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final movies = await _firestoreService.getMoviesByList(widget.listName);

      if (!mounted) return;

      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to load movies';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeMovie(int movieId) async {
    try {
      await _firestoreService.removeMovieFromList(movieId, widget.listName);

      if (!mounted) return;

      setState(() {
        _movies.removeWhere((movie) => movie['id'] == movieId);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Movie removed from list')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to remove movie')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F14),
        title: Text(widget.title),
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _loadMovies,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Text(
          'No movies in ${widget.title}',
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMovies,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];

          final int movieId = int.parse(movie['id'].toString());

          final String title = movie['title'] ?? 'Unknown Movie';

          final String? posterPath = movie['posterPath'];

          final double voteAverage =
              double.tryParse(movie['voteAverage'].toString()) ?? 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: posterPath != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w342$posterPath',
                          width: 90,
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 90,
                              height: 130,
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.movie,
                                color: Colors.white54,
                                size: 40,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 90,
                          height: 130,
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.movie,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                ),

                const SizedBox(width: 12),

                // Movie information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),

                          const SizedBox(width: 5),

                          Text(
                            voteAverage.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete button
                IconButton(
                  onPressed: () {
                    _removeMovie(movieId);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
