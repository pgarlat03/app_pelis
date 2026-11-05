import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// Modelo avanzado para las películas con póster, año, puntuación y sinopsis
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
    this.year = 2023,
    this.rating = 7.5,
    this.synopsis = 'Una gran experiencia cinematográfica para disfrutar esta noche.',
    this.posterUrl = 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=600&auto=format&fit=crop',
    this.isWatched = false,
  });
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
  // Lista con algunas películas de ejemplo que ya traen póster e info detallada
  final List<Movie> _movies = [
    Movie(
      id: 1,
      title: 'Cars',
      genre: 'Animación / Aventura',
      duration: 117,
      year: 2006,
      rating: 7.1,
      synopsis: 'El aspirante a campeón de carreras Rayo McQueen parece que está a punto de conseguir el éxito, la fama y todo lo que había soñado, hasta que por error toma un desvío inesperado en la polvorienta y solitaria Ruta 66.',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
    ),
    Movie(
      id: 2,
      title: 'Interstellar',
      genre: 'Sci-Fi / Aventura',
      duration: 169,
      year: 2014,
      rating: 8.7,
      synopsis: 'Un grupo de astronautas viaja a través de un agujero de gusano en busca de un nuevo hogar para la humanidad cuando la Tierra se vuelve inhabitable.',
      posterUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=600&auto=format&fit=crop',
    ),
    Movie(
      id: 3,
      title: 'Buscando a Nemo',
      genre: 'Animación / Familiar',
      duration: 100,
      year: 2003,
      rating: 8.2,
      synopsis: 'Un pez payaso sobreprotector se embarca en un viaje épico a través del océano para rescatar a su hijo capturado por un dentista.',
      posterUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=600&auto=format&fit=crop',
    ),
    Movie(
      id: 4,
      title: 'Scream',
      genre: 'Terror / Misterio',
      duration: 111,
      year: 1996,
      rating: 7.4,
      synopsis: 'Un misterioso asesino enmascarado acecha a los estudiantes de secundaria en un pequeño pueblo, desatando una ola de terror.',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
    ),
    Movie(
      id: 5,
      title: 'Piratas del Caribe',
      genre: 'Aventura / Acción',
      duration: 143,
      year: 2011,
      rating: 6.6,
      synopsis: 'El intrépido capitán Jack Sparrow se embarca en una nueva y peligrosa búsqueda de la legendaria Fuente de la Juventud.',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
    ),
    Movie(
      id: 6,
      title: 'El Señor de los Anillos',
      genre: 'Fantasía / Épica',
      duration: 201,
      year: 2003,
      rating: 9.0,
      synopsis: 'Las fuerzas de Sauron asedian Minas Tirith. El ejército de Rohan acude en su ayuda mientras Frodo y Sam se acercan al Monte del Destino.',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
    ),
  ];

  final TextEditingController _singleMovieController = TextEditingController();

  void _roll6() {
    if (_movies.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Necesitas al menos 6 películas en tu lista. Tienes ${_movies.length}.'),
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
        builder: (context) => RollResultsScreen(selectedMovies: selected6),
      ),
    );
  }

  void _showAddMovieModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Añadir peli suelta', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _singleMovieController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Título de la película...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
              onPressed: () {
                if (_singleMovieController.text.trim().isNotEmpty) {
                  setState(() {
                    int newId = _movies.isEmpty ? 1 : _movies.last.id + 1;
                    _movies.add(Movie(
                      id: newId,
                      title: _singleMovieController.text.trim(),
                    ));
                  });
                  _singleMovieController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Película añadida a tu colección! 🍿')),
                  );
                }
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
          title: const Text('Importar desde Bloc de Notas', style: TextStyle(color: Colors.white)),
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
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
              onPressed: () {
                String text = importController.text.trim();
                if (text.isNotEmpty) {
                  List<String> lines = text.split('\n');
                  int addedCount = 0;
                  setState(() {
                    for (var line in lines) {
                      String cleanLine = line.trim();
                      if (cleanLine.isNotEmpty) {
                        int newId = _movies.isEmpty ? 1 : _movies.last.id + 1;
                        _movies.add(Movie(
                          id: newId,
                          title: cleanLine,
                        ));
                        addedCount++;
                      }
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('¡Importadas $addedCount películas a tu lista! 🚀')),
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
            setState(() {
              _movies.remove(movie);
            });
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: InkWell(
                onTap: _openCollectionScreen,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.movie_outlined, size: 14, color: primaryGold),
                      const SizedBox(width: 6),
                      Text(
                        "$pendingCount pendientes",
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
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
              child: const Icon(Icons.casino, size: 42, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            const Text("¿Qué toca ver hoy?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text("Tira los dados para obtener 6 opciones instantáneas.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _roll6,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("🎲", style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text("ROLL 6", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black)),
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
                          const SnackBar(content: Text('Tu lista está vacía. ¡Añade algunas películas primero!')),
                        );
                        return;
                      }
                      showSearch(context: context, delegate: MovieSearchDelegate(movies: _movies));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 48,
                      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [
                          Icon(Icons.search, size: 18, color: Colors.grey),
                          SizedBox(width: 12),
                          Text("Buscar en tus pendientes...", style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("📝", style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Text("Importar desde Bloc de Notas", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 48,
                            decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(12)),
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Añadir peli suelta...", style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                          decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add, color: Colors.white70),
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
    );
  }
}

// Pantalla de Resultados del Sorteo con Grid de 2 columnas estilo póster grande
class RollResultsScreen extends StatelessWidget {
  final List<Movie> selectedMovies;
  const RollResultsScreen({super.key, required this.selectedMovies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YOUR 6 PICKS", style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columnas como en la referencia
          childAspectRatio: 0.62, // proporción alargada tipo póster
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: selectedMovies.length,
        itemBuilder: (context, index) {
          final movie = selectedMovies[index];
          String formattedId = movie.id.toString().padLeft(3, '0');

          return GestureDetector(
            onTap: () {
              // Muestra el modal detallado al pulsar la tarjeta
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: const Color(0xFF1A1A1A),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => MovieDetailModal(movie: movie),
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
                  // Póster de la película
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        movie.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[850],
                          child: const Icon(Icons.movie, color: Colors.white54, size: 40),
                        ),
                      ),
                    ),
                  ),
                  // Número de identificación en la parte inferior de la tarjeta
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
    );
  }
}

// Modal Detallado de la Película (Estilo exacto de tu captura)
class MovieDetailModal extends StatelessWidget {
  final Movie movie;
  const MovieDetailModal({super.key, required this.movie});

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
            // Cabecera con miniatura y datos principales
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie.posterUrl,
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 140,
                      color: Colors.grey[850],
                      child: const Icon(Icons.movie, color: Colors.white54),
                    ),
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
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      // Fila de Año y Puntuación
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Text("📅", style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text("${movie.year}", style: const TextStyle(fontSize: 12, color: Colors.white70)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Text("⭐", style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text("${movie.rating}/10", style: const TextStyle(fontSize: 12, color: Colors.amber)),
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
            // Botón de Marcar como Vista (Elegir esta)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Cierra modal
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text('🍿 TONIGHT\'S MOVIE', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                      content: Text('¡Tonight, we\'re watching "${movie.title}"!', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Cierra alert
                            Navigator.pop(context); // Vuelve a home desde resultados
                          },
                          child: const Text('¡A verla!', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  "Marcar como Vista (Elegir esta)",
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

// Pantalla para ver y gestionar la Colección
class MyCollectionScreen extends StatefulWidget {
  final List<Movie> movies;
  final Function(Movie) onDelete;

  const MyCollectionScreen({super.key, required this.movies, required this.onDelete});

  @override
  State<MyCollectionScreen> createState() => _MyCollectionScreenState();
}

class _MyCollectionScreenState extends State<MyCollectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TU COLECCIÓN (${widget.movies.length})", style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "#$formattedId",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          movie.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          setState(() {
                            widget.onDelete(movie);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${movie.title}" eliminada de la lista.')),
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

// Buscador rápido
class MovieSearchDelegate extends SearchDelegate {
  final List<Movie> movies;
  MovieSearchDelegate({required this.movies});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredMovies = movies.where((m) => m.title.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: filteredMovies.length,
      itemBuilder: (context, index) {
        final movie = filteredMovies[index];
        return ListTile(
          title: Text(movie.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(movie.genre, style: const TextStyle(color: Colors.grey)),
          onTap: () {
            close(context, null);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: const Color(0xFF1A1A1A),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => MovieDetailModal(movie: movie),
            );
          },
        );
      },
    );
  }
}