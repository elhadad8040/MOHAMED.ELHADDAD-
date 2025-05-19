class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int level;
  final int points;
  final List<Achievement> achievements;
  final LearningPath learningPath;
  final RecitationStats recitationStats;
  
  UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.level,
    required this.points,
    required this.achievements,
    required this.learningPath,
    required this.recitationStats,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      displayName: json['displayName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      level: json['level'] ?? 1,
      points: json['points'] ?? 0,
      achievements: (json['achievements'] as List? ?? [])
          .map((achievement) => Achievement.fromJson(achievement))
          .toList(),
      learningPath: LearningPath.fromJson(json['learningPath'] ?? {}),
      recitationStats: RecitationStats.fromJson(json['recitationStats'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'level': level,
      'points': points,
      'achievements': achievements.map((achievement) => achievement.toJson()).toList(),
      'learningPath': learningPath.toJson(),
      'recitationStats': recitationStats.toJson(),
    };
  }
  
  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    int? level,
    int? points,
    List<Achievement>? achievements,
    LearningPath? learningPath,
    RecitationStats? recitationStats,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      level: level ?? this.level,
      points: points ?? this.points,
      achievements: achievements ?? this.achievements,
      learningPath: learningPath ?? this.learningPath,
      recitationStats: recitationStats ?? this.recitationStats,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final int pointsAwarded;
  final DateTime earnedAt;
  
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.pointsAwarded,
    required this.earnedAt,
  });
  
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconPath: json['iconPath'],
      pointsAwarded: json['pointsAwarded'] ?? 0,
      earnedAt: json['earnedAt'] != null
          ? DateTime.parse(json['earnedAt'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'pointsAwarded': pointsAwarded,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }
}

class LearningPath {
  final String currentLevel;
  final List<String> completedLessons;
  final List<String> unlockedLessons;
  final String nextMilestone;
  final double progressPercentage;
  
  LearningPath({
    required this.currentLevel,
    required this.completedLessons,
    required this.unlockedLessons,
    required this.nextMilestone,
    required this.progressPercentage,
  });
  
  factory LearningPath.fromJson(Map<String, dynamic> json) {
    return LearningPath(
      currentLevel: json['currentLevel'] ?? 'مبتدئ',
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      unlockedLessons: List<String>.from(json['unlockedLessons'] ?? []),
      nextMilestone: json['nextMilestone'] ?? 'إتقان الإدغام',
      progressPercentage: json['progressPercentage']?.toDouble() ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'completedLessons': completedLessons,
      'unlockedLessons': unlockedLessons,
      'nextMilestone': nextMilestone,
      'progressPercentage': progressPercentage,
    };
  }
}

class RecitationStats {
  final int totalRecitations;
  final int perfectRecitations;
  final int totalMinutesRecited;
  final Map<String, int> errorTypeFrequency;
  final Map<String, double> tajweedRuleAccuracy;
  
  RecitationStats({
    required this.totalRecitations,
    required this.perfectRecitations,
    required this.totalMinutesRecited,
    required this.errorTypeFrequency,
    required this.tajweedRuleAccuracy,
  });
  
  factory RecitationStats.fromJson(Map<String, dynamic> json) {
    // تحويل error frequency من JSON
    Map<String, int> errorFreq = {};
    if (json['errorTypeFrequency'] != null) {
      json['errorTypeFrequency'].forEach((key, value) {
        errorFreq[key] = value;
      });
    }
    
    // تحويل tajweed accuracy من JSON
    Map<String, double> tajweedAcc = {};
    if (json['tajweedRuleAccuracy'] != null) {
      json['tajweedRuleAccuracy'].forEach((key, value) {
        tajweedAcc[key] = value.toDouble();
      });
    }
    
    return RecitationStats(
      totalRecitations: json['totalRecitations'] ?? 0,
      perfectRecitations: json['perfectRecitations'] ?? 0,
      totalMinutesRecited: json['totalMinutesRecited'] ?? 0,
      errorTypeFrequency: errorFreq,
      tajweedRuleAccuracy: tajweedAcc,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalRecitations': totalRecitations,
      'perfectRecitations': perfectRecitations,
      'totalMinutesRecited': totalMinutesRecited,
      'errorTypeFrequency': errorTypeFrequency,
      'tajweedRuleAccuracy': tajweedRuleAccuracy,
    };
  }
}