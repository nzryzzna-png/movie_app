import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie_model.dart';
import '../providers/movie_provider.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchTimer;

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      context.read<MovieProvider>().searchMovies(value);
    });
  }

  void _openMovie(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F14),
        title: const Text('Search Movies'),
      ),

      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for a movie...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();

                              context.read<MovieProvider>().searchMovies('');

                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white70,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF1C1C24),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(child: _buildResults(movieProvider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResults(MovieProvider movieProvider) {
    if (_searchController.text.trim().isEmpty) {
      return const Center(
        child: Text(
          'Search for a movie',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    if (movieProvider.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (movieProvider.searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            movieProvider.searchError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (movieProvider.searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No movies found',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: movieProvider.searchResults.length,
      itemBuilder: (context, index) {
        final movie = movieProvider.searchResults[index];

        return GestureDetector(
          onTap: () {
            _openMovie(movie);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: movie.posterPath != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w342${movie.posterPath}',
                          width: 90,
                          height: 130,
                          fit: BoxFit.cover,
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

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
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
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        movie.releaseDate?.isNotEmpty == true
                            ? movie.releaseDate!
                            : 'Release date unavailable',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
