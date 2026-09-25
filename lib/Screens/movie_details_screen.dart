import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/movie_provider.dart';
import '../services/firestore_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Set<String> _movieLists = {};
  bool _isListsLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MovieProvider>();

      await provider.fetchMovieDetails(widget.movieId);

      await _loadMovieLists();
    });
  }

  Future<void> _loadMovieLists() async {
    try {
      final movieLists = <String>{};

      const lists = ['favorites', 'watched', 'watching', 'want_to_watch'];

      for (final listName in lists) {
        final movies = await _firestoreService.getMoviesByList(listName);

        final exists = movies.any(
          (movie) => movie['id'].toString() == widget.movieId.toString(),
        );

        if (exists) {
          movieLists.add(listName);
        }
      }

      if (mounted) {
        setState(() {
          _movieLists = movieLists;
          _isListsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListsLoading = false;
        });
      }
    }
  }

  Future<void> _toggleList(String listName) async {
    final provider = context.read<MovieProvider>();
    final movie = provider.selectedMovie;

    if (movie == null) return;

    final isInList = _movieLists.contains(listName);

    try {
      if (isInList) {
        await provider.removeMovieFromList(movie.id, listName);

        setState(() {
          _movieLists.remove(listName);
        });
      } else {
        await provider.addMovieToList(movie, listName);

        setState(() {
          _movieLists.add(listName);
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    }
  }

  Widget _buildListButton({
    required String listName,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _movieLists.contains(listName);

    return Expanded(
      child: ElevatedButton.icon(
        onPressed: _isListsLoading ? null : () => _toggleList(listName),
        icon: Icon(isSelected ? Icons.check : icon, size: 18),
        label: Text(
          isSelected ? 'Added' : title,
          style: const TextStyle(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F14),
        title: const Text('Movie Details'),
      ),

      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (movieProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  movieProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          final movie = movieProvider.selectedMovie;

          if (movie == null) {
            return const Center(
              child: Text(
                'Movie not found',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (movie.backdropPath != null)
                  Image.network(
                    'https://image.tmdb.org/t/p/w780${movie.backdropPath}',
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (movie.posterPath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w342${movie.posterPath}',
                                width: 130,
                                height: 195,
                                fit: BoxFit.cover,
                              ),
                            ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      movie.voteAverage.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  movie.releaseDate?.isNotEmpty == true
                                      ? movie.releaseDate!
                                      : 'Release date unavailable',
                                  style: const TextStyle(color: Colors.white70),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  movie.runtime != null
                                      ? '${movie.runtime} minutes'
                                      : 'Runtime unavailable',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // =========================
                      // MOVIE LISTS
                      // =========================
                      const Text(
                        'My Lists',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _buildListButton(
                            listName: 'favorites',
                            title: 'Favorite',
                            icon: Icons.favorite_border,
                          ),

                          const SizedBox(width: 8),

                          _buildListButton(
                            listName: 'watched',
                            title: 'Watched',
                            icon: Icons.visibility_outlined,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _buildListButton(
                            listName: 'watching',
                            title: 'Watching',
                            icon: Icons.play_circle_outline,
                          ),

                          const SizedBox(width: 8),

                          _buildListButton(
                            listName: 'want_to_watch',
                            title: 'Want to Watch',
                            icon: Icons.bookmark_border,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Genres',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movie.genres.map((genre) {
                          return Chip(label: Text(genre));
                        }).toList(),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        movie.overview.isNotEmpty
                            ? movie.overview
                            : 'No overview available.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
