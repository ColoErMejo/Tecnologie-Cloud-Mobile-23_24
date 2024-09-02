import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';
import 'models.dart'; // Importa il file dei modelli

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<TedTalk>>? _futureTedTalks;
  bool _showIntroduction = true; // Variabile per gestire l'introduzione
  final PageController _pageController = PageController();
  int _currentPage = 0; // Stato per l'indice della slide corrente

  // Funzione per ottenere i TED Talks dal backend
  Future<List<TedTalk>> fetchTedTalks(String tag) async {
    final response = await http.post(
      Uri.parse(
          'https://shk1qx21na.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_Tag'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'tag': tag}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        List<dynamic> body = json.decode(response.body);
        List<TedTalk> talks =
            body.map((dynamic item) => TedTalk.fromJson(item)).toList();
        return talks;
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to parse TED Talks');
      }
    } else {
      throw Exception('Failed to load TED Talks');
    }
  }

  void _search() {
    final tag = _searchController.text.trim();
    if (tag.isNotEmpty) {
      setState(() {
        _showIntroduction = false; // Nasconde l'introduzione alla ricerca
        _futureTedTalks = fetchTedTalks(tag);
      });
    }
  }

  int _selectedIndex = 1; // Indice iniziale selezionato per Home

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Logica per cambiare pagina o eseguire altre azioni in base all'indice
    });
  }

  void _closeIntroduction() {
    setState(() {
      _showIntroduction = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF313638), // Imposta lo sfondo al colore desiderato
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEB0028), // Colore di sfondo rosso TEDx
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Search for TedX Episode...   (es. music)', // Testo del placeholder
                    hintStyle: const TextStyle(
                        color: Colors.white), // Colore testo placeholder
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(
                        0xFFEB0028), // Colore di riempimento della barra
                    suffixIcon: const Icon(Icons.search,
                        color: Colors.white), // Icona bianca
                  ),
                  style: const TextStyle(
                      color: Colors.white), // Colore del testo inserito
                  cursorColor: Colors.white, // Colore del cursore
                  onSubmitted: (_) => _search(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                _showIntroduction
                    ? Center(
                        child: Container(
                          width: 300,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              PageView(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                children: [
                                  _buildIntroSlide(
                                    'Scrivi nella barra di ricerca il tag a cui sei interessato',
                                    Icons.search,
                                  ),
                                  _buildIntroSlide(
                                    'Scorri i talk relativi a quell\'argomento e seleziona quello che ti interessa',
                                    Icons.list,
                                  ),
                                  _buildIntroSlide(
                                    'Esamina i podcast di Spotify correlati',
                                    Icons.podcasts,
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: _closeIntroduction,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List<Widget>.generate(3, (index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      width: 10.0,
                                      height: 10.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentPage == index
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : FutureBuilder<List<TedTalk>>(
                        future: _futureTedTalks,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFEB0028)),
                              ),
                            ); // Imposta il colore del cerchio di caricamento));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'No TED Talks found for the tag',
                                style: TextStyle(
                                    color: Colors.white), // Colore testo
                              ),
                            );
                          } else {
                            final talks = snapshot.data ?? [];
                            return ListView.builder(
                              itemCount: talks.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailScreen(talk: talks[index]),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color: Colors.grey[
                                        800], // Imposta il colore del Card
                                    margin: const EdgeInsets.all(12),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (talks[index].imageUrl.isNotEmpty)
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(15)),
                                            child: Image.network(
                                              talks[index].imageUrl,
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            talks[index].title,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white, //Titolo talk
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                          child: Text(
                                            talks[index].description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            talks[index].speakers,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                              color: Color(0xFFEB0028),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor:
            const Color(0xFFEB0028), // Colore per l'elemento selezionato
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: 'Playlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildIntroSlide(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80.0,
            color: const Color(0xFFEB0028),
          ),
          const SizedBox(height: 20.0),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
