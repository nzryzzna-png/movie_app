import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile_screen.dart';
import '../models/movie_model.dart';
import '../providers/movie_provider.dart';
import 'search_screen.dart';
import 'movie_details_screen.dart';
import 'favorites_screen.dart';
import 'watched_screen.dart';
import 'watching_screen.dart';
import 'want_to_watch_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().fetchHomeMovies();
    });
  }

  void _openMovieDetails(int movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movieId)),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        _openMovieDetails(movie.id);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: movie.posterPath != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                color: Colors.white54,
                                size: 45,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            color: Colors.white54,
                            size: 45,
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 17),
                const SizedBox(width: 4),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieSection(String title, List<Movie> movies) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 285,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return _buildMovieCard(movies[index]);
            },
          ),
        ),

        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildLists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Lists',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
              icon: const Icon(Icons.favorite),
              label: const Text('Favorites'),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WatchedScreen()),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Watched'),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WatchingScreen()),
                );
              },
              icon: const Icon(Icons.play_circle),
              label: const Text('Watching'),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WantToWatchScreen()),
                );
              },
              icon: const Icon(Icons.bookmark),
              label: const Text('Want to Watch'),
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F14),
        elevation: 0,
        title: const Text(
          'Movie App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      movieProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: () {
                        movieProvider.fetchHomeMovies();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: movieProvider.fetchHomeMovies,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              children: [
                const Text(
                  'Discover Movies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Explore movies and manage your lists',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),

                const SizedBox(height: 25),

                _buildLists(),

                _buildMovieSection(
                  'Popular Movies',
                  movieProvider.popularMovies,
                ),

                _buildMovieSection(
                  'Now Playing',
                  movieProvider.nowPlayingMovies,
                ),

                _buildMovieSection('Top Rated', movieProvider.topRatedMovies),

                _buildMovieSection('Upcoming', movieProvider.upcomingMovies),

                _buildMovieSection('Trending', movieProvider.trendingMovies),
              ],
            ),
          );
        },
      ),
    );
  }
}
