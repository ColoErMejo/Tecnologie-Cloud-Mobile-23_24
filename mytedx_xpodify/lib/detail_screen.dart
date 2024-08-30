import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models.dart'; // Assicurati che il modello sia corretto

class DetailScreen extends StatelessWidget {
  final TedTalk talk;

  const DetailScreen({super.key, required this.talk});

  Future<List<Podcast>> fetchPodcasts(List<String> tags) async {
    const String apiUrl =
        'https://dsuvyfxzkk.execute-api.us-east-1.amazonaws.com/default/FindPodcast';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tags': tags, // Passa l'elenco dei tag come parametro
      }),
    );

    if (response.statusCode == 200) {
      try {
        List<dynamic> body = json.decode(response.body);
        List<Podcast> podcasts =
            body.map((dynamic item) => Podcast.fromJson(item)).toList();
        return podcasts;
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to parse podcasts');
      }
    } else {
      throw Exception('Failed to load podcasts');
    }
  }

  Future<void> _launchURL(String podcastId) async {
    final Uri webUri = Uri.parse('https://open.spotify.com/show/$podcastId');
    final Uri appUri = Uri.parse('spotify:show:$podcastId');

    // Prova ad aprire il link nel web
    if (await canLaunchUrl(webUri)) {
      await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Se non riesce, prova ad aprire l'app Spotify
      if (await canLaunchUrl(appUri)) {
        await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Se nessuna delle due opzioni funziona, mostra un errore
        throw 'Could not launch URL or Spotify app with ID: $podcastId';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(talk.title),
        backgroundColor: const Color(0xFF1DB954), // Verde Spotify
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Aggiungi azione per la condivisione se necessario
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostra l'immagine del TedTalk se disponibile
            if (talk.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(15)),
                child: Image.network(
                  talk.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error,
                        size: 100, color: Colors.red);
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                talk.description,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white), // Testo bianco per leggibilità
              ),
            ),
            const Divider(
              height: 30,
              color: Color(0xFF1DB954), // Verde Spotify
              thickness: 2,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Suggested Podcasts',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1DB954), // Verde Spotify
                ),
              ),
            ),
            FutureBuilder<List<Podcast>>(
              future: fetchPodcasts(talk.tags), // Passa l'elenco dei tag
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final podcasts = snapshot.data ?? [];
                  return Column(
                    children: podcasts.map((podcast) {
                      return GestureDetector(
                        onTap: () {
                          _launchURL(
                              podcast.id); // Usa direttamente l'ID del podcast
                        },
                        child: Card(
                          margin: const EdgeInsets.all(12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            width: double
                                .infinity, // Usa l'altezza fissa o variabile
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (podcast.imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15)),
                                    child: Image.network(
                                      podcast.imageUrl,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error,
                                            size: 80, color: Colors.red);
                                      },
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    podcast.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1DB954), // Verde Spotify
                                    ),
                                  ),
                                ),
                                Text(
                                  podcast.publisher,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFEB0028), // Rosso TEDx
                                  ),
                                ),
                                Text(
                                  podcast.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors
                                        .white, // Testo bianco per leggibilità
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF121212), // Sfondo scuro per contrasto
    );
  }
}
