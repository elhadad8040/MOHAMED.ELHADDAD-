import 'dart:convert';

/// نموذج محتوى تعليمي للأطفال
class KidsContent {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final AgeGroup ageGroup;
  final ContentType contentType;
  final List<ContentActivity> activities;
  final int orderIndex;
  final bool isPremium;
  final Map<String, dynamic> metadata;

  KidsContent({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    required this.ageGroup,
    required this.contentType,
    required this.activities,
    required this.orderIndex,
    required this.isPremium,
    required this.metadata,
  });

  /// إنشاء من JSON
  factory KidsContent.fromJson(Map<String, dynamic> json) {
    return KidsContent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'] ?? '',
      ageGroup: AgeGroup.fromString(json['ageGroup']),
      contentType: ContentType.fromString(json['contentType']),
      activities: (json['activities'] as List)
          .map((activity) => ContentActivity.fromJson(activity))
          .toList(),
      orderIndex: json['orderIndex'] ?? 0,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'] ?? {},
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'ageGroup': ageGroup.toString(),
      'contentType': contentType.toString(),
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'orderIndex': orderIndex,
      'isPremium': isPremium,
      'metadata': metadata,
    };
  }

  /// إنشاء قائمة من JSON
  static List<KidsContent> listFromJson(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => KidsContent.fromJson(json)).toList();
  }
}

/// نموذج نشاط تعليمي
class ContentActivity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final ActivityType activityType;
  final List<dynamic> content;
  final int duration; // بالدقائق
  final int points;
  final bool isInteractive;

  ContentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.activityType,
    required this.content,
    required this.duration,
    required this.points,
    required this.isInteractive,
  });

  factory ContentActivity.fromJson(Map<String, dynamic> json) {
    return ContentActivity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      activityType: ActivityType.fromString(json['activityType']),
      content: json['content'],
      duration: json['duration'] ?? 5,
      points: json['points'] ?? 10,
      isInteractive: json['isInteractive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'activityType': activityType.toString(),
      'content': content,
      'duration': duration,
      'points': points,
      'isInteractive': isInteractive,
    };
  }
}

/// نموذج لعبة تعليمية
class KidsGame {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final AgeGroup ageGroup;
  final GameType gameType;
  final GameDifficulty difficulty;
  final int maxScore;
  final int duration; // بالدقائق
  final List<String> skills;
  final Map<String, dynamic> gameData;
  final bool isAvailableOffline;

  KidsGame({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ageGroup,
    required this.gameType,
    required this.difficulty,
    required this.maxScore,
    required this.duration,
    required this.skills,
    required this.gameData,
    required this.isAvailableOffline,
  });

  factory KidsGame.fromJson(Map<String, dynamic> json) {
    return KidsGame(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      ageGroup: AgeGroup.fromString(json['ageGroup']),
      gameType: GameType.fromString(json['gameType']),
      difficulty: GameDifficulty.fromString(json['difficulty']),
      maxScore: json['maxScore'] ?? 100,
      duration: json['duration'] ?? 5,
      skills: List<String>.from(json['skills'] ?? []),
      gameData: json['gameData'] ?? {},
      isAvailableOffline: json['isAvailableOffline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ageGroup': ageGroup.toString(),
      'gameType': gameType.toString(),
      'difficulty': difficulty.toString(),
      'maxScore': maxScore,
      'duration': duration,
      'skills': skills,
      'gameData': gameData,
      'isAvailableOffline': isAvailableOffline,
    };
  }

  static List<KidsGame> listFromJson(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => KidsGame.fromJson(json)).toList();
  }
}

/// نموذج إنجاز للأطفال
class KidsAchievement {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int pointsRequired;
  final AchievementCategory category;
  final bool isSecret;
  final String unlockCriteria;

  KidsAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.pointsRequired,
    required this.category,
    required this.isSecret,
    required this.unlockCriteria,
  });

  factory KidsAchievement.fromJson(Map<String, dynamic> json) {
    return KidsAchievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      pointsRequired: json['pointsRequired'] ?? 0,
      category: AchievementCategory.fromString(json['category']),
      isSecret: json['isSecret'] ?? false,
      unlockCriteria: json['unlockCriteria'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'pointsRequired': pointsRequired,
      'category': category.toString(),
      'isSecret': isSecret,
      'unlockCriteria': unlockCriteria,
    };
  }
}

/// فئة عمرية
enum AgeGroup {
  preschool, // 3-6
  elementary, // 7-10
  middleschool, // 11-14
  highschool; // 15+

  @override
  String toString() {
    switch (this) {
      case AgeGroup.preschool:
        return 'preschool';
      case AgeGroup.elementary:
        return 'elementary';
      case AgeGroup.middleschool:
        return 'middleschool';
      case AgeGroup.highschool:
        return 'highschool';
    }
  }

  String toArabicString() {
    switch (this) {
      case AgeGroup.preschool:
        return 'ما قبل المدرسة (3-6 سنوات)';
      case AgeGroup.elementary:
        return 'المرحلة الابتدائية (7-10 سنوات)';
      case AgeGroup.middleschool:
        return 'المرحلة المتوسطة (11-14 سنة)';
      case AgeGroup.highschool:
        return '15 سنة فما فوق';
    }
  }

  static AgeGroup fromString(String value) {
    switch (value) {
      case 'preschool':
        return AgeGroup.preschool;
      case 'elementary':
        return AgeGroup.elementary;
      case 'middleschool':
        return AgeGroup.middleschool;
      case 'highschool':
      default:
        return AgeGroup.highschool;
    }
  }
}

/// نوع المحتوى
enum ContentType {
  story,
  animation,
  song,
  interactiveLesson,
  quiz,
  challenge;

  @override
  String toString() {
    switch (this) {
      case ContentType.story:
        return 'story';
      case ContentType.animation:
        return 'animation';
      case ContentType.song:
        return 'song';
      case ContentType.interactiveLesson:
        return 'interactiveLesson';
      case ContentType.quiz:
        return 'quiz';
      case ContentType.challenge:
        return 'challenge';
    }
  }

  String toArabicString() {
    switch (this) {
      case ContentType.story:
        return 'قصة';
      case ContentType.animation:
        return 'رسوم متحركة';
      case ContentType.song:
        return 'أنشودة';
      case ContentType.interactiveLesson:
        return 'درس تفاعلي';
      case ContentType.quiz:
        return 'اختبار';
      case ContentType.challenge:
        return 'تحدي';
    }
  }

  static ContentType fromString(String value) {
    switch (value) {
      case 'story':
        return ContentType.story;
      case 'animation':
        return ContentType.animation;
      case 'song':
        return ContentType.song;
      case 'interactiveLesson':
        return ContentType.interactiveLesson;
      case 'quiz':
        return ContentType.quiz;
      case 'challenge':
        return ContentType.challenge;
      default:
        return ContentType.story;
    }
  }
}

/// نوع النشاط
enum ActivityType {
  watch,
  listen,
  read,
  play,
  write,
  draw,
  recite;

  @override
  String toString() {
    switch (this) {
      case ActivityType.watch:
        return 'watch';
      case ActivityType.listen:
        return 'listen';
      case ActivityType.read:
        return 'read';
      case ActivityType.play:
        return 'play';
      case ActivityType.write:
        return 'write';
      case ActivityType.draw:
        return 'draw';
      case ActivityType.recite:
        return 'recite';
    }
  }

  String toArabicString() {
    switch (this) {
      case ActivityType.watch:
        return 'مشاهدة';
      case ActivityType.listen:
        return 'استماع';
      case ActivityType.read:
        return 'قراءة';
      case ActivityType.play:
        return 'لعب';
      case ActivityType.write:
        return 'كتابة';
      case ActivityType.draw:
        return 'رسم';
      case ActivityType.recite:
        return 'تلاوة';
    }
  }

  static ActivityType fromString(String value) {
    switch (value) {
      case 'watch':
        return ActivityType.watch;
      case 'listen':
        return ActivityType.listen;
      case 'read':
        return ActivityType.read;
      case 'play':
        return ActivityType.play;
      case 'write':
        return ActivityType.write;
      case 'draw':
        return ActivityType.draw;
      case 'recite':
        return ActivityType.recite;
      default:
        return ActivityType.watch;
    }
  }
}

/// نوع اللعبة
enum GameType {
  puzzle,
  memory,
  quiz,
  matching,
  sorting,
  drawing,
  wordSearch;

  @override
  String toString() {
    switch (this) {
      case GameType.puzzle:
        return 'puzzle';
      case GameType.memory:
        return 'memory';
      case GameType.quiz:
        return 'quiz';
      case GameType.matching:
        return 'matching';
      case GameType.sorting:
        return 'sorting';
      case GameType.drawing:
        return 'drawing';
      case GameType.wordSearch:
        return 'wordSearch';
    }
  }

  String toArabicString() {
    switch (this) {
      case GameType.puzzle:
        return 'لغز';
      case GameType.memory:
        return 'ذاكرة';
      case GameType.quiz:
        return 'اختبار';
      case GameType.matching:
        return 'مطابقة';
      case GameType.sorting:
        return 'ترتيب';
      case GameType.drawing:
        return 'رسم';
      case GameType.wordSearch:
        return 'بحث عن كلمات';
    }
  }

  static GameType fromString(String value) {
    switch (value) {
      case 'puzzle':
        return GameType.puzzle;
      case 'memory':
        return GameType.memory;
      case 'quiz':
        return GameType.quiz;
      case 'matching':
        return GameType.matching;
      case 'sorting':
        return GameType.sorting;
      case 'drawing':
        return GameType.drawing;
      case 'wordSearch':
        return GameType.wordSearch;
      default:
        return GameType.quiz;
    }
  }
}

/// مستوى صعوبة اللعبة
enum GameDifficulty {
  easy,
  medium,
  hard;

  @override
  String toString() {
    switch (this) {
      case GameDifficulty.easy:
        return 'easy';
      case GameDifficulty.medium:
        return 'medium';
      case GameDifficulty.hard:
        return 'hard';
    }
  }

  String toArabicString() {
    switch (this) {
      case GameDifficulty.easy:
        return 'سهل';
      case GameDifficulty.medium:
        return 'متوسط';
      case GameDifficulty.hard:
        return 'صعب';
    }
  }

  static GameDifficulty fromString(String value) {
    switch (value) {
      case 'easy':
        return GameDifficulty.easy;
      case 'medium':
        return GameDifficulty.medium;
      case 'hard':
        return GameDifficulty.hard;
      default:
        return GameDifficulty.medium;
    }
  }
}

/// فئة الإنجاز
enum AchievementCategory {
  recitation,
  memorization,
  learning,
  exploration,
  consistency,
  social;

  @override
  String toString() {
    switch (this) {
      case AchievementCategory.recitation:
        return 'recitation';
      case AchievementCategory.memorization:
        return 'memorization';
      case AchievementCategory.learning:
        return 'learning';
      case AchievementCategory.exploration:
        return 'exploration';
      case AchievementCategory.consistency:
        return 'consistency';
      case AchievementCategory.social:
        return 'social';
    }
  }

  String toArabicString() {
    switch (this) {
      case AchievementCategory.recitation:
        return 'تلاوة';
      case AchievementCategory.memorization:
        return 'حفظ';
      case AchievementCategory.learning:
        return 'تعلم';
      case AchievementCategory.exploration:
        return 'استكشاف';
      case AchievementCategory.consistency:
        return 'مواظبة';
      case AchievementCategory.social:
        return 'اجتماعي';
    }
  }

  static AchievementCategory fromString(String value) {
    switch (value) {
      case 'recitation':
        return AchievementCategory.recitation;
      case 'memorization':
        return AchievementCategory.memorization;
      case 'learning':
        return AchievementCategory.learning;
      case 'exploration':
        return AchievementCategory.exploration;
      case 'consistency':
        return AchievementCategory.consistency;
      case 'social':
        return AchievementCategory.social;
      default:
        return AchievementCategory.learning;
    }
  }
}