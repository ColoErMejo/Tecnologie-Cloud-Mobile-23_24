import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';
import 'models.dart'; // Importa il file dei modelli

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<TedTalk>>? _futureTedTalks;

  // Funzione per ottenere i TED Talks dal backend
  Future<List<TedTalk>> fetchTedTalks(String tag) async {
    final response = await http.post(
      Uri.parse(
          'https://shk1qx21na.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_Tag'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tag': tag // Verifica se il formato corretto è solo una stringa
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Stampa la risposta dell'API

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
    final tag = _searchController.text.trim(); // Rimuovi spazi extra
    if (tag.isNotEmpty) {
      setState(() {
        _futureTedTalks = fetchTedTalks(tag);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTEDx Talks'),
        backgroundColor: const Color(0xFF1DB954), // Verde Spotify
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1DB954),
                const Color(0xFF1DB954).withOpacity(0.8)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(30.0), // Arrotonda tutti gli angoli
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
                  hintText: 'Search for TED Talks...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        30.0), // Arrotonda tutti gli angoli
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon:
                      const Icon(Icons.search, color: Color(0xFF1DB954)),
                ),
                style: const TextStyle(color: Colors.black),
                onSubmitted: (_) => _search(),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<TedTalk>>(
        future: _futureTedTalks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No TED Talks found for the tag'));
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
                        builder: (context) => DetailScreen(talk: talks[index]),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (talks[index].imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
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
                              color: Color(0xFF1DB954), // Verde Spotify
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            talks[index].description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:
                                  Colors.white, // Colore bianco per leggibilità
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            talks[index].speakers, // Aggiungi il speaker
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFEB0028), // Rosso TEDx
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
    );
  }
}
