class TedTalk {
  final String id;
  final String slug;
  final String speakers;
  final String title;
  final String imageUrl; // Cambiato da `url` a `imageUrl`
  final String description;
  final String duration;
  final DateTime publishedAt;
  final List<String> relatedIds;
  final List<String> relatedTitles;
  final List<String> tags;

  TedTalk({
    required this.id,
    required this.slug,
    required this.speakers,
    required this.title,
    required this.imageUrl, // Cambiato da `url` a `imageUrl`
    required this.description,
    required this.duration,
    required this.publishedAt,
    required this.relatedIds,
    required this.relatedTitles,
    required this.tags,
  });

  factory TedTalk.fromJson(Map<String, dynamic> json) {
    return TedTalk(
      id: json['id_related'] as String,
      slug: json['slug'] as String,
      speakers: json['speakers'] as String,
      title: json['title'] as String,
      imageUrl: json['url'] as String, // Mappatura del campo `url` a `imageUrl`
      description: json['description'] as String,
      duration: json['duration'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      relatedIds: List<String>.from(json['id_related_list'] as List),
      relatedTitles: List<String>.from(json['title_related_list'] as List),
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_related': id,
      'slug': slug,
      'speakers': speakers,
      'title': title,
      'url': imageUrl, // Cambiato da `imageUrl` a `url` per la serializzazione
      'description': description,
      'duration': duration,
      'publishedAt': publishedAt.toIso8601String(),
      'id_related_list': relatedIds,
      'title_related_list': relatedTitles,
      'tags': tags,
    };
  }
}

class Podcast {
  final String name;
  final String publisher;
  final String id;
  final String description;
  final String imageUrl; // Aggiunto per l'immagine del podcast
  final String spotifyUrl; // Aggiunto per l'URL di Spotify

  Podcast({
    required this.name,
    required this.publisher,
    required this.id,
    required this.description,
    required this.imageUrl,
    required this.spotifyUrl,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
        name: json['name'] ?? 'Unknown Name',
        publisher: json['publisher'] ?? 'Unknown Publisher',
        id: json['id'] ?? 'Unknown ID',
        description: json['description'] ?? 'No description available',
        imageUrl: json['imageUrl'],
        spotifyUrl: json['externalUrl']);
  }
}
