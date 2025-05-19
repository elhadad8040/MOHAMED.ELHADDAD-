import 'package:flutter/material.dart';

/// ثوابت التطبيق
class AppConstants {
  // ألوان التطبيق
  static const Color primaryColor = Color(0xFF43A047);
  static const Color secondaryColor = Color(0xFF388E3C);
  static const Color accentColor = Color(0xFF66BB6A);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF1E88E5);
  static const Color successColor = Color(0xFF43A047);
  
  // ألوان إضافية للميزات الجديدة
  static const Color kidsThemeColor = Color(0xFF8E24AA);
  static const Color storiesThemeColor = Color(0xFF6D4C41);
  static const Color interactiveThemeColor = Color(0xFF1565C0);
  static const Color gamificationColor = Color(0xFFFFB300);
  
  // قياسات التطبيق
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 8.0;
  static const double iconSize = 24.0;
  
  // مسارات API
  static const String baseApiUrl = 'https://api.quranai.com/v1';
  static const String ayahEndpoint = '/quran/ayah';
  static const String analyzeEndpoint = '/recitations/analyze';
  static const String userProfileEndpoint = '/user/profile';
  static const String prophetStoriesEndpoint = '/content/prophet-stories';
  static const String kidsContentEndpoint = '/content/kids';
  static const String quizEndpoint = '/learn/quiz';
  
  // مفاتيح التخزين المحلي
  static const String userPrefsKey = 'user_preferences';
  static const String recitationHistoryKey = 'recitation_history';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String kidsProgressKey = 'kids_learning_progress';
  static const String storiesProgressKey = 'stories_progress';
  static const String achievementsKey = 'user_achievements';
  
  // قيم افتراضية
  static const int defaultSurahId = 1;  // الفاتحة
  static const int defaultAyahId = 1;
  static const Duration maxRecordingDuration = Duration(minutes: 10);
  static const Duration defaultRecitationTimer = Duration(minutes: 3);
  
  // الفئات العمرية
  static const List<String> ageGroups = ['3-6', '7-10', '11-14', '15+'];
  
  // مستويات التعلم
  static const List<String> learningLevels = ['مبتدئ', 'متوسط', 'متقدم', 'خبير'];
}

/// ثوابت المسارات
class AppRoutes {
  static const String home = '/';
  static const String quranBrowser = '/quran_browser';
  static const String recitationAnalysis = '/recitation_analysis';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String community = '/community';
  static const String tajweedRules = '/tajweed_rules';
  static const String tajweedRuleDetails = '/tajweed_rule_details';
  static const String learningPath = '/learning_path';
  static const String achievements = '/achievements';
  static const String leaderboard = '/leaderboard';
  
  // مسارات قصص الأنبياء
  static const String prophetStories = '/prophet_stories';
  static const String prophetStoryDetails = '/prophet_story_details';
  static const String storyTimeline = '/story_timeline';
  static const String interactiveMap = '/interactive_map';
  
  // مسارات قسم الأطفال
  static const String kidsZone = '/kids_zone';
  static const String kidsLearning = '/kids_zone/learning';
  static const String kidsGames = '/kids_zone/games';
  static const String kidsQuiz = '/kids_zone/kids_quiz';
  static const String familyMode = '/kids_zone/family_mode';
  
  // مسارات التعلم التفاعلي
  static const String interactiveLearning = '/interactive_learning';
  static const String tajweedCartoon = '/tajweed_cartoon';
  static const String virtualTeacher = '/virtual_teacher';
  static const String mindMaps = '/mind_maps';
  static const String groupRecitation = '/group_recitation';
}
