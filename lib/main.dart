import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

const String tmdbApiReadToken =
    'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxOTcwNzI4OTE2OTA2NWIxY2U5MTYyNGYwNWUzOTAzZSIsIm5iZiI6MTc4NjM1OTQzNi44MTEsInN1YiI6IjZhNzlhZThjODM0N2E5MTUwMzZjYzU4YyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.uz-BuRbvT5bh0M-Jod0UGcVYJSK_tAz3IhzH-uprWto';

class Movie {
  final int id;
  final String title;
  final String genre;
  final int duration;
  final int year;
  final double rating;
  final String synopsis;
  final String posterUrl;
  bool isWatched;

  Movie({
    required this.id,
    required this.title,
    this.genre = 'Cine',
    this.duration = 120,
    this.year = 2024,
    this.rating = 0.0,
    this.synopsis = 'Sinopsis no disponible.',
    this.posterUrl = '',
    this.isWatched = false,
  });
}

class TmdbService {
  static Future fetchMovieDetails(String title) async {
    final query = Uri.encodeComponent(title);
    final url = Uri.parse(
        'https://api.themoviedb.org/3/search/movie?query=$query&include_adult=false&language=es-ES&page=1');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $tmdbApiReadToken',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        if (results.isNotEmpty) {
          final firstResult = results.first;

          String posterPath = firstResult['poster_path'] ?? '';
          String fullPosterUrl = posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w500$posterPath'
              : '';

          String releaseDate = firstResult['release_date'] ?? '';
          int year = releaseDate.length >= 4
              ? int.tryParse(releaseDate.substring(0, 4)) ?? 2024
              : 2024;

          return {
            'title': firstResult['title'] ?? title,
            'synopsis': (firstResult['overview'] as String).isNotEmpty
                ? firstResult['overview']
                : 'Sinopsis no disponible.',
            'posterUrl': fullPosterUrl,
            'year': year,
            'rating': (firstResult['vote_average'] as num).toDouble(),
          };
        }
      }
    } catch (e) {
      debugPrint('Error conectando a TMDb: $e');
    }
    return null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tonight's Movie",
      initialRoute: 'home',
      routes: {
        'home': (BuildContext context) => const HomeScreen(),
      },
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Movie> _movies = [];
  bool _isLoading = false;

  final TextEditingController _singleMovieController = TextEditingController();

  void _deleteMovie(Movie movie) {
    setState(() {
      _movies.removeWhere((m) => m.id == movie.id);
    });
  }

  void _roll6() {
    if (_movies.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Necesitas al menos 6 películas en tu lista. Tienes ${_movies.length}.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    List<Movie> shuffled = List.from(_movies)..shuffle(Random());
    List<Movie> selected6 = shuffled.take(6).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RollResultsScreen(
          selectedMovies: selected6,
          onSelectAsWatched: (movie) {
            _deleteMovie(movie);
          },
        ),
      ),
    );
  }

  Future<void> _addSingleMovie(String titleText) async {
    final cleanTitle = titleText.trim();
    if (cleanTitle.isEmpty) return;

    setState(() => _isLoading = true);

    final dynamic details = await TmdbService.fetchMovieDetails(cleanTitle);

    setState(() {
      int newId = _movies.isEmpty ? 1 : _movies.last.id + 1;
      if (details != null) {
        _movies.add(Movie(
          id: newId,
          title: details['title'],
          synopsis: details['synopsis'],
          posterUrl: details['posterUrl'],
          year: details['year'],
          rating: details['rating'],
        ));
      } else {
        _movies.add(Movie(
          id: newId,
          title: cleanTitle,
        ));
      }
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Película procesada con éxito! 🍿')),
    );
  }

  void _showAddMovieModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Añadir peli suelta',
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _singleMovieController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Ej: Cars, Interstellar...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black),
              onPressed: () {
                final text = _singleMovieController.text;
                _singleMovieController.clear();
                Navigator.pop(context);
                _addSingleMovie(text);
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  void _showImportModal() {
    final TextEditingController importController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Importar desde Bloc de Notas',
              style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: importController,
              maxLines: 8,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Pega aquí tus películas (una por línea)...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black),
              onPressed: () async {
                String text = importController.text.trim();
                Navigator.pop(context);

                if (text.isNotEmpty) {
                  List<String> lines = text.split('\n');
                  setState(() => _isLoading = true);

                  int addedCount = 0;
                  for (var line in lines) {
                    String cleanLine = line.trim();
                    if (cleanLine.isNotEmpty) {
                      final dynamic details =
                          await TmdbService.fetchMovieDetails(cleanLine);
                      int newId = _movies.isEmpty ? 1 : _movies.last.id + 1;

                      if (details != null) {
                        _movies.add(Movie(
                          id: newId,
                          title: details['title'],
                          synopsis: details['synopsis'],
                          posterUrl: details['posterUrl'],
                          year: details['year'],
                          rating: details['rating'],
                        ));
                      } else {
                        _movies.add(Movie(
                          id: newId,
                          title: cleanLine,
                        ));
                      }
                      addedCount++;
                    }
                  }

                  setState(() => _isLoading = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '¡Importadas $addedCount películas con sus pósters! 🚀')),
                  );
                }
              },
              child: const Text('Importar'),
            ),
          ],
        );
      },
    );
  }

  void _openCollectionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyCollectionScreen(
          movies: _movies,
          onDelete: (movie) {
            _deleteMovie(movie);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGold = Color(0xFFD4AF37);
    const Color surfaceDark = Color(0xFF1A1A1A);

    int pendingCount = _movies.where((m) => !m.isWatched).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TONIGHT'S MOVIE",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: InkWell(
                onTap: _openCollectionScreen,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: surfaceDark,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.movie_outlined,
                          size: 14, color: primaryGold),
                      const SizedBox(width: 6),
                      Text(
                        "$pendingCount pendientes",
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: surfaceDark,
                    border: Border.all(color: Colors.white12, width: 1),
                  ),
                  child:
                      const Icon(Icons.casino, size: 42, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                const Text("¿Qué toca ver hoy?",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                const Text(
                    "Tira los dados para obtener 6 opciones instantáneas.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _roll6,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("🎲", style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text("ROLL 6",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_movies.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Tu lista está vacía. ¡Añade algunas películas primero!')),
                            );
                            return;
                          }
                          showSearch(
                              context: context,
                              delegate: MovieSearchDelegate(
                                movies: _movies,
                                onDelete: _deleteMovie,
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 48,
                          decoration: BoxDecoration(
                              color: surfaceDark,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            children: [
                              Icon(Icons.search, size: 18, color: Colors.grey),
                              SizedBox(width: 12),
                              Text("Buscar en tus pendientes...",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _showImportModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 48,
                          decoration: BoxDecoration(
                              color: surfaceDark,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("📝", style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Text("Importar desde Bloc de Notas",
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _showAddMovieModal,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                height: 48,
                                decoration: BoxDecoration(
                                    color: surfaceDark,
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Añadir peli suelta...",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _showAddMovieModal,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                  color: surfaceDark,
                                  borderRadius: BorderRadius.circular(12)),
                              child:
                                  const Icon(Icons.add, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: primaryGold),
                    SizedBox(height: 16),
                    Text("Obteniendo información y pósters...",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RollResultsScreen extends StatelessWidget {
  final List<Movie> selectedMovies;
  final Function(Movie) onSelectAsWatched;

  const RollResultsScreen({
    super.key,
    required this.selectedMovies,
    required this.onSelectAsWatched,
  });

  @override
  Widget build(BuildContext context) {
    Movie criticChoice = selectedMovies.reduce(
        (curr, next) => curr.rating > next.rating ? curr : next);

    List<Movie> otherMovies =
        selectedMovies.where((m) => m.id != criticChoice.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("YOUR 6 PICKS",
            style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "✨ SELECCIÓN DEL CRÍTICO",
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: const Color(0xFF1A1A1A),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => MovieDetailModal(
                    movie: criticChoice,
                    onSelectAsWatched: onSelectAsWatched,
                  ),
                );
              },
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(14)),
                      child: criticChoice.posterUrl.isNotEmpty
                          ? Image.network(
                              criticChoice.posterUrl,
                              width: 140,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 140,
                                color: Colors.grey[850],
                                child: const Icon(Icons.movie,
                                    color: Colors.white54, size: 40),
                              ),
                            )
                          : Container(
                              width: 140,
                              color: Colors.grey[850],
                              child: const Icon(Icons.movie,
                                  color: Colors.white54, size: 40),
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              criticChoice.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "#${criticChoice.id.toString().padLeft(3, '0')} • ${criticChoice.genre}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text("⭐",
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  "${criticChoice.rating.toStringAsFixed(1)}/10",
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Toca para ver detalles ->",
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFFD4AF37)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "🍿 OTRAS 5 OPCIONES",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: otherMovies.length,
              itemBuilder: (context, index) {
                final movie = otherMovies[index];
                String formattedId = movie.id.toString().padLeft(3, '0');

                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: const Color(0xFF1A1A1A),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => MovieDetailModal(
                        movie: movie,
                        onSelectAsWatched: onSelectAsWatched,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: movie.posterUrl.isNotEmpty
                                ? Image.network(
                                    movie.posterUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: Colors.grey[850],
                                      child: const Icon(Icons.movie,
                                          color: Colors.white54, size: 40),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[850],
                                    child: const Icon(Icons.movie,
                                        color: Colors.white54, size: 40),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "#$formattedId",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MovieDetailModal extends StatelessWidget {
  final Movie movie;
  final Function(Movie) onSelectAsWatched;

  const MovieDetailModal({
    super.key,
    required this.movie,
    required this.onSelectAsWatched,
  });

  @override
  Widget build(BuildContext context) {
    String formattedId = movie.id.toString().padLeft(3, '0');

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: movie.posterUrl.isNotEmpty
                      ? Image.network(
                          movie.posterUrl,
                          width: 100,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 100,
                            height: 140,
                            color: Colors.grey[850],
                            child: const Icon(Icons.movie,
                                color: Colors.white54),
                          ),
                        )
                      : Container(
                          width: 100,
                          height: 140,
                          color: Colors.grey[850],
                          child:
                              const Icon(Icons.movie, color: Colors.white54),
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "#$formattedId • ${movie.genre}",
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Text("📅",
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text("${movie.year}",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white70)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Text("⭐",
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                    "${movie.rating.toStringAsFixed(1)}/10",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.amber)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Sinopsis",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.synopsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // 1. Elimina la película de la lista principal
                  onSelectAsWatched(movie);

                  // 2. Cierra el modal emergente
                  Navigator.pop(context);

                  // 3. Muestra diálogo de confirmación y vuelve a inicio
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text('🍿 TONIGHT\'S MOVIE',
                          style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold)),
                      content: Text(
                          '¡Tonight, we\'re watching "${movie.title}"!\n(Eliminada de tu lista de pendientes)',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Cierra alerta
                            Navigator.pop(context); // Vuelve a Home
                          },
                          child: const Text('¡A verla!',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  "Marcar como Vista (Eliminar)",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class MyCollectionScreen extends StatefulWidget {
  final List<Movie> movies;
  final Function(Movie) onDelete;

  const MyCollectionScreen(
      {super.key, required this.movies, required this.onDelete});

  @override
  State<MyCollectionScreen> createState() => _MyCollectionScreenState();
}

class _MyCollectionScreenState extends State<MyCollectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TU COLECCIÓN (${widget.movies.length})",
            style: const TextStyle(
                letterSpacing: 1.5, fontWeight: FontWeight.bold)),
      ),
      body: widget.movies.isEmpty
          ? const Center(
              child: Text(
                "Aún no has añadido películas a tu lista. 🍿",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.movies.length,
              itemBuilder: (context, index) {
                final movie = widget.movies[index];
                String formattedId = movie.id.toString().padLeft(3, '0');

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "#$formattedId",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        onPressed: () {
                          setState(() {
                            widget.onDelete(movie);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '"${movie.title}" eliminada de la lista.')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class MovieSearchDelegate extends SearchDelegate {
  final List<Movie> movies;
  final Function(Movie) onDelete;

  MovieSearchDelegate({required this.movies, required this.onDelete});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return const [];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredMovies = movies
        .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredMovies.length,
      itemBuilder: (context, index) {
        final movie = filteredMovies[index];
        return ListTile(
          title: Text(movie.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(movie.genre,
              style: const TextStyle(color: Colors.grey)),
          onTap: () {
            close(context, null);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: const Color(0xFF1A1A1A),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => MovieDetailModal(
                movie: movie,
                onSelectAsWatched: onDelete,
              ),
            );
          },
        );
      },
    );
  }
}