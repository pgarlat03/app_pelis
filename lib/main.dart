import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// Modelo simple para las películas
class Movie {
  final int id;
  final String title;
  final String genre;
  final int duration;
  final String synopsis;
  bool isWatched;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.duration,
    required this.synopsis,
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

// Pantalla Principal Interactiva
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista inicial de ejemplo (tu colección)
  final List<Movie> _movies = [
    Movie(id: 1, title: 'Interstellar', genre: 'Sci-Fi', duration: 169, synopsis: 'Un grupo de astronautas viaja a través de un agujero de gusano en busca de un nuevo hogar para la humanidad.'),
    Movie(id: 2, title: 'The Prestige', genre: 'Drama / Misterio', duration: 130, synopsis: 'Dos magos rivales compiten en el Londres victoriano para crear la ilusión definitiva.'),
    Movie(id: 3, title: 'Arrival', genre: 'Sci-Fi', duration: 116, synopsis: 'Una lingüista intenta comunicarse con unos alienígenas cuya nave ha aterrizado en la Tierra.'),
    Movie(id: 4, title: 'Prisoners', genre: 'Thriller', duration: 153, synopsis: 'Un padre desesperado toma la justicia por su mano cuando su hija y su amiga desaparecen.'),
    Movie(id: 5, title: 'Shutter Island', genre: 'Misterio', duration: 138, synopsis: 'Dos detectives investigan la desaparición de una asesina en un hospital psiquiátrico insular.'),
    Movie(id: 6, title: 'Inception', genre: 'Acción / Sci-Fi', duration: 148, synopsis: 'Un ladrón que roba secretos a través de los sueños recibe una misión imposible: la incepción.'),
    Movie(id: 7, title: 'Whiplash', genre: 'Drama', duration: 106, synopsis: 'Un joven baterista presiona sus límites bajo la tutela de un profesor implacable.'),
  ];

  final TextEditingController _singleMovieController = TextEditingController();

  // Función para hacer el ROLL 6
  void _roll6() {
    if (_movies.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Necesitas al menos 6 películas en tu lista para hacer Roll 6.')),
      );
      return;
    }

    // Copiamos la lista y la barajamos al azar
    List<Movie> shuffled = List.from(_movies)..shuffle(Random());
    List<Movie> selected6 = shuffled.take(6).toList();

    // Navegamos a la pantalla de resultados pasando las 6 elegidas
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RollResultsScreen(selectedMovies: selected6),
      ),
    );
  }

  // Diálogo para añadir una película suelta
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
                      genre: 'General',
                      duration: 120,
                      synopsis: 'Película añadida manualmente a la colección.',
                    ));
                  });
                  _singleMovieController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Película añadida con éxito! 🍿')),
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

  // Diálogo para importar desde el Bloc de Notas
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
              maxLines: 6,
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
                  setState(() {
                    for (var line in lines) {
                      if (line.trim().isNotEmpty) {
                        int newId = _movies.isEmpty ? 1 : _movies.last.id + 1;
                        _movies.add(Movie(
                          id: newId,
                          title: line.trim(),
                          genre: 'General',
                          duration: 120,
                          synopsis: 'Importada desde bloc de notas.',
                        ));
                      }
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('¡Importadas ${lines.length} películas con éxito! 🚀')),
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.movie_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text("$pendingCount pendientes", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
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

            // Botón ROLL 6 funcional
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

            // Zona inferior interactiva
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  // Buscador interactivo
                  GestureDetector(
                    onTap: () {
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

                  // Importar Bloc de Notas
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

                  // Añadir peli suelta + Botón de más
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

// Pantalla de Resultados del Sorteo (Muestra las 6 películas)
class RollResultsScreen extends StatelessWidget {
  final List<Movie> selectedMovies;
  const RollResultsScreen({super.key, required this.selectedMovies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YOUR 6 PICKS", style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: selectedMovies.length,
        itemBuilder: (context, index) {
          final movie = selectedMovies[index];
          String formattedId = movie.id.toString().padLeft(3, '0');

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                // Número fijo de la película
                Text(
                  "#$formattedId",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(width: 20),
                // Título y género
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text("${movie.genre} • ${movie.duration} min", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                // Botón para ver detalles
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(movie: movie),
                      ),
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

// Pantalla de Detalles de la película elegida
class DetailsScreen extends StatelessWidget {
  final Movie movie;
  const DetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    String formattedId = movie.id.toString().padLeft(3, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text("DETALLES #$formattedId"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              "${movie.genre}  |  ${movie.duration} min",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              "Sinopsis",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(height: 8),
            Text(
              movie.synopsis,
              style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5),
            ),
            const Spacer(),

            // Botón definitivo: "Elegir esta"
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text('🍿 TONIGHT\'S MOVIE', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                      content: Text('¡Tonight, we\'re watching "${movie.title}"!', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Cierra popup
                            Navigator.pop(context); // Vuelve a home
                            Navigator.pop(context); // Vuelve a home desde resultados
                          },
                          child: const Text('¡A verla!', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  "ELEGIR ESTA",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Buscador rápido integrado
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsScreen(movie: movie)));
          },
        );
      },
    );
  }
}