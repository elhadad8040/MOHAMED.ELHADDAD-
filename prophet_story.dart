import 'dart:convert';

/// نموذج قصة نبي
class ProphetStory {
  final String id;
  final String prophetNameAr;
  final String prophetNameEn;
  final String title;
  final String description;
  final String era;
  final String imageUrl;
  final String audioUrl;
  final List<String> keyEvents;
  final List<String> lessons;
  final List<StoryChapter> chapters;
  final List<String> relatedStoriesIds;
  final List<Location> locations;
  final int timelinePeriodStart;
  final int timelinePeriodEnd;
  final Map<String, dynamic> metadata;

  ProphetStory({
    required this.id,
    required this.prophetNameAr,
    required this.prophetNameEn,
    required this.title,
    required this.description,
    required this.era,
    required this.imageUrl,
    required this.audioUrl,
    required this.keyEvents,
    required this.lessons,
    required this.chapters,
    required this.relatedStoriesIds,
    required this.locations,
    required this.timelinePeriodStart,
    required this.timelinePeriodEnd,
    required this.metadata,
  });

  /// إنشاء من JSON
  factory ProphetStory.fromJson(Map<String, dynamic> json) {
    return ProphetStory(
      id: json['id'],
      prophetNameAr: json['prophetNameAr'],
      prophetNameEn: json['prophetNameEn'],
      title: json['title'],
      description: json['description'],
      era: json['era'],
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      keyEvents: List<String>.from(json['keyEvents']),
      lessons: List<String>.from(json['lessons']),
      chapters: (json['chapters'] as List)
          .map((chapter) => StoryChapter.fromJson(chapter))
          .toList(),
      relatedStoriesIds: List<String>.from(json['relatedStoriesIds']),
      locations: (json['locations'] as List)
          .map((location) => Location.fromJson(location))
          .toList(),
      timelinePeriodStart: json['timelinePeriodStart'],
      timelinePeriodEnd: json['timelinePeriodEnd'],
      metadata: json['metadata'],
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prophetNameAr': prophetNameAr,
      'prophetNameEn': prophetNameEn,
      'title': title,
      'description': description,
      'era': era,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'keyEvents': keyEvents,
      'lessons': lessons,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
      'relatedStoriesIds': relatedStoriesIds,
      'locations': locations.map((location) => location.toJson()).toList(),
      'timelinePeriodStart': timelinePeriodStart,
      'timelinePeriodEnd': timelinePeriodEnd,
      'metadata': metadata,
    };
  }

  /// إنشاء قائمة من JSON
  static List<ProphetStory> listFromJson(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => ProphetStory.fromJson(json)).toList();
  }
}

/// نموذج فصل من قصة
class StoryChapter {
  final String id;
  final String title;
  final String content;
  final List<String> quranVerses;
  final String imageUrl;
  final String audioUrl;
  final List<StoryEvent> events;
  final int order;

  StoryChapter({
    required this.id,
    required this.title,
    required this.content,
    required this.quranVerses,
    required this.imageUrl,
    required this.audioUrl,
    required this.events,
    required this.order,
  });

  factory StoryChapter.fromJson(Map<String, dynamic> json) {
    return StoryChapter(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      quranVerses: List<String>.from(json['quranVerses']),
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      events: (json['events'] as List)
          .map((event) => StoryEvent.fromJson(event))
          .toList(),
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'quranVerses': quranVerses,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'events': events.map((event) => event.toJson()).toList(),
      'order': order,
    };
  }
}

/// نموذج حدث في القصة
class StoryEvent {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int year;

  StoryEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.year,
  });

  factory StoryEvent.fromJson(Map<String, dynamic> json) {
    return StoryEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'year': year,
    };
  }
}

/// نموذج موقع جغرافي
class Location {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String currentName;
  final String country;

  Location({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.currentName,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      imageUrl: json['imageUrl'],
      currentName: json['currentName'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'currentName': currentName,
      'country': country,
    };
  }
}