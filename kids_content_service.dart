import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kids_content.dart';
import '../utils/constants.dart';

/// خدمة للتعامل مع محتوى الأطفال
class KidsContentService {
  static const String _cachedContentKey = 'cached_kids_content';
  static const String _cachedGamesKey = 'cached_kids_games';
  static const String _cachedAchievementsKey = 'cached_kids_achievements';
  static const String _kidsProgressPrefix = 'kids_activity_progress_';

  /// الحصول على محتوى الأطفال
  Future<List<KidsContent>> getKidsContent({AgeGroup? ageGroup, ContentType? contentType}) async {
    try {
      // محاولة الحصول على البيانات من الذاكرة المحلية أولاً
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cachedContentKey);
      
      List<KidsContent> allContent = [];
      
      if (cachedData != null) {
        allContent = KidsContent.listFromJson(cachedData);
      } else {
        // الحصول على البيانات من API
        final response = await http.get(
          Uri.parse('${AppConstants.baseApiUrl}${AppConstants.kidsContentEndpoint}'),
        );
        
        if (response.statusCode == 200) {
          // تخزين البيانات في الذاكرة المحلية
          prefs.setString(_cachedContentKey, response.body);
          
          allContent = KidsContent.listFromJson(response.body);
        } else {
          throw Exception('فشل في الحصول على محتوى الأطفال: ${response.statusCode}');
        }
      }
      
      // تطبيق التصفية حسب الفئة العمرية
      if (ageGroup != null) {
        allContent = allContent.where((content) => content.ageGroup == ageGroup).toList();
      }
      
      // تطبيق التصفية حسب نوع المحتوى
      if (contentType != null) {
        allContent = allContent.where((content) => content.contentType == contentType).toList();
      }
      
      // ترتيب المحتوى حسب الترتيب
      allContent.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      
      return allContent;
    } catch (e) {
      debugPrint('خطأ في الحصول على محتوى الأطفال: $e');
      
      // في حالة عدم الاتصال بالإنترنت، نعود بيانات افتراضية
      return _getMockKidsContent(ageGroup, contentType);
    }
  }
  
  /// الحصول على الألعاب التعليمية للأطفال
  Future<List<KidsGame>> getKidsGames({AgeGroup? ageGroup, GameType? gameType, GameDifficulty? difficulty}) async {
    try {
      // محاولة الحصول على البيانات من الذاكرة المحلية أولاً
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cachedGamesKey);
      
      List<KidsGame> allGames = [];
      
      if (cachedData != null) {
        allGames = KidsGame.listFromJson(cachedData);
      } else {
        // الحصول على البيانات من API
        final response = await http.get(
          Uri.parse('${AppConstants.baseApiUrl}${AppConstants.kidsContentEndpoint}/games'),
        );
        
        if (response.statusCode == 200) {
          // تخزين البيانات في الذاكرة المحلية
          prefs.setString(_cachedGamesKey, response.body);
          
          allGames = KidsGame.listFromJson(response.body);
        } else {
          throw Exception('فشل في الحصول على ألعاب الأطفال: ${response.statusCode}');
        }
      }
      
      // تطبيق التصفية حسب الفئة العمرية
      if (ageGroup != null) {
        allGames = allGames.where((game) => game.ageGroup == ageGroup).toList();
      }
      
      // تطبيق التصفية حسب نوع اللعبة
      if (gameType != null) {
        allGames = allGames.where((game) => game.gameType == gameType).toList();
      }
      
      // تطبيق التصفية حسب مستوى الصعوبة
      if (difficulty != null) {
        allGames = allGames.where((game) => game.difficulty == difficulty).toList();
      }
      
      return allGames;
    } catch (e) {
      debugPrint('خطأ في الحصول على ألعاب الأطفال: $e');
      
      // في حالة عدم الاتصال بالإنترنت، نعود بيانات افتراضية
      return _getMockKidsGames(ageGroup, gameType);
    }
  }
  
  /// الحصول على إنجازات الأطفال
  Future<List<KidsAchievement>> getKidsAchievements({AchievementCategory? category}) async {
    try {
      // محاولة الحصول على البيانات من الذاكرة المحلية أولاً
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cachedAchievementsKey);
      
      List<KidsAchievement> allAchievements = [];
      
      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        allAchievements = jsonList
            .map((json) => KidsAchievement.fromJson(json))
            .toList();
      } else {
        // الحصول على البيانات من API
        final response = await http.get(
          Uri.parse('${AppConstants.baseApiUrl}${AppConstants.kidsContentEndpoint}/achievements'),
        );
        
        if (response.statusCode == 200) {
          // تخزين البيانات في الذاكرة المحلية
          prefs.setString(_cachedAchievementsKey, response.body);
          
          final List<dynamic> jsonList = json.decode(response.body);
          allAchievements = jsonList
              .map((json) => KidsAchievement.fromJson(json))
              .toList();
        } else {
          throw Exception('فشل في الحصول على إنجازات الأطفال: ${response.statusCode}');
        }
      }
      
      // تطبيق التصفية حسب الفئة
      if (category != null) {
        allAchievements = allAchievements.where((achievement) => achievement.category == category).toList();
      }
      
      return allAchievements;
    } catch (e) {
      debugPrint('خطأ في الحصول على إنجازات الأطفال: $e');
      
      // في حالة عدم الاتصال بالإنترنت، نعود بيانات افتراضية
      return _getMockKidsAchievements(category);
    }
  }
  
  /// حفظ تقدم المستخدم في نشاط معين
  Future<bool> saveActivityProgress(String contentId, String activityId, double progress) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String progressKey = '$_kidsProgressPrefix${contentId}_$activityId';
      
      // حفظ التقدم الحالي
      final bool result = await prefs.setDouble(progressKey, progress);
      
      // تحديث التقدم الكلي للمستخدم إذا كان هناك تقدم كامل
      if (progress >= 1.0) {
        final String completedKey = '${_kidsProgressPrefix}completed_$contentId';
        final List<String> completedActivities = prefs.getStringList(completedKey) ?? [];
        
        if (!completedActivities.contains(activityId)) {
          completedActivities.add(activityId);
          await prefs.setStringList(completedKey, completedActivities);
          
          // التحقق من إمكانية فتح إنجاز جديد
          await _checkForNewAchievements();
        }
      }
      
      return result;
    } catch (e) {
      debugPrint('خطأ في حفظ تقدم النشاط: $e');
      return false;
    }
  }
  
  /// الحصول على تقدم المستخدم في نشاط معين
  Future<double> getActivityProgress(String contentId, String activityId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String progressKey = '$_kidsProgressPrefix${contentId}_$activityId';
      
      return prefs.getDouble(progressKey) ?? 0.0;
    } catch (e) {
      debugPrint('خطأ في الحصول على تقدم النشاط: $e');
      return 0.0;
    }
  }
  
  /// الحصول على الأنشطة المكتملة لمحتوى معين
  Future<List<String>> getCompletedActivities(String contentId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String completedKey = '${_kidsProgressPrefix}completed_$contentId';
      
      return prefs.getStringList(completedKey) ?? [];
    } catch (e) {
      debugPrint('خطأ في الحصول على الأنشطة المكتملة: $e');
      return [];
    }
  }
  
  /// تسجيل نتيجة لعبة
  Future<bool> saveGameScore(String gameId, int score) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String scoreKey = 'kids_game_score_$gameId';
      
      // الحصول على أعلى نتيجة سابقة
      final int highScore = prefs.getInt(scoreKey) ?? 0;
      
      // تحديث النتيجة فقط إذا كانت أعلى من السابقة
      if (score > highScore) {
        await prefs.setInt(scoreKey, score);
        
        // التحقق من إمكانية فتح إنجاز جديد
        await _checkForNewAchievements();
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('خطأ في حفظ نتيجة اللعبة: $e');
      return false;
    }
  }
  
  /// الحصول على أعلى نتيجة لعبة
  Future<int> getGameHighScore(String gameId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String scoreKey = 'kids_game_score_$gameId';
      
      return prefs.getInt(scoreKey) ?? 0;
    } catch (e) {
      debugPrint('خطأ في الحصول على نتيجة اللعبة: $e');
      return 0;
    }
  }
  
  /// فتح إنجاز جديد
  Future<bool> unlockAchievement(String achievementId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String achievementsKey = 'kids_unlocked_achievements';
      
      final List<String> unlockedAchievements = prefs.getStringList(achievementsKey) ?? [];
      
      if (!unlockedAchievements.contains(achievementId)) {
        unlockedAchievements.add(achievementId);
        return await prefs.setStringList(achievementsKey, unlockedAchievements);
      }
      
      return true;
    } catch (e) {
      debugPrint('خطأ في فتح الإنجاز: $e');
      return false;
    }
  }
  
  /// الحصول على الإنجازات المفتوحة
  Future<List<String>> getUnlockedAchievements() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String achievementsKey = 'kids_unlocked_achievements';
      
      return prefs.getStringList(achievementsKey) ?? [];
    } catch (e) {
      debugPrint('خطأ في الحصول على الإنجازات المفتوحة: $e');
      return [];
    }
  }
  
  /// التحقق من إمكانية فتح إنجازات جديدة
  Future<void> _checkForNewAchievements() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String completedActivitiesCountKey = 'kids_completed_activities_count';
      final String gamesPlayedCountKey = 'kids_games_played_count';
      
      // تحديث عدد الأنشطة المكتملة
      int completedActivitiesCount = prefs.getInt(completedActivitiesCountKey) ?? 0;
      completedActivitiesCount++;
      await prefs.setInt(completedActivitiesCountKey, completedActivitiesCount);
      
      // تحديث عدد الألعاب التي تم لعبها
      int gamesPlayedCount = prefs.getInt(gamesPlayedCountKey) ?? 0;
      gamesPlayedCount++;
      await prefs.setInt(gamesPlayedCountKey, gamesPlayedCount);
      
      // التحقق من فتح إنجازات بناءً على عدد الأنشطة المكتملة
      if (completedActivitiesCount == 5) {
        await unlockAchievement('kids_achievement_5_activities');
      } else if (completedActivitiesCount == 10) {
        await unlockAchievement('kids_achievement_10_activities');
      } else if (completedActivitiesCount == 25) {
        await unlockAchievement('kids_achievement_25_activities');
      }
      
      // التحقق من فتح إنجازات بناءً على عدد الألعاب التي تم لعبها
      if (gamesPlayedCount == 3) {
        await unlockAchievement('kids_achievement_3_games');
      } else if (gamesPlayedCount == 7) {
        await unlockAchievement('kids_achievement_7_games');
      } else if (gamesPlayedCount == 15) {
        await unlockAchievement('kids_achievement_15_games');
      }
    } catch (e) {
      debugPrint('خطأ في التحقق من الإنجازات الجديدة: $e');
    }
  }
  
  /// بيانات افتراضية لمحتوى الأطفال
  List<KidsContent> _getMockKidsContent(AgeGroup? ageFilter, ContentType? typeFilter) {
    final List<KidsContent> allContent = [
      KidsContent(
        id: 'kids_content_1',
        title: 'قصة نوح عليه السلام للأطفال',
        description: 'قصة مصورة تتناول قصة سيدنا نوح عليه السلام مع قومه وبناء السفينة بأسلوب يناسب الأطفال',
        imageUrl: 'assets/images/kids/noah_story.jpg',
        videoUrl: 'assets/videos/kids/noah_story.mp4',
        ageGroup: AgeGroup.preschool,
        contentType: ContentType.story,
        activities: [
          ContentActivity(
            id: 'kids_activity_1',
            title: 'استماع للقصة',
            description: 'استمع إلى القصة بصوت المعلم',
            imageUrl: 'assets/images/kids/activities/listen.jpg',
            activityType: ActivityType.listen,
            content: ['assets/audio/kids/noah_story.mp3'],
            duration: 5,
            points: 10,
            isInteractive: false,
          ),
          ContentActivity(
            id: 'kids_activity_2',
            title: 'تلوين شخصيات القصة',
            description: 'لوّن شخصيات ومشاهد من قصة نوح عليه السلام',
            imageUrl: 'assets/images/kids/activities/coloring.jpg',
            activityType: ActivityType.draw,
            content: [
              'assets/images/kids/coloring/noah_1.png',
              'assets/images/kids/coloring/noah_2.png',
              'assets/images/kids/coloring/noah_3.png',
            ],
            duration: 15,
            points: 20,
            isInteractive: true,
          ),
        ],
        orderIndex: 1,
        isPremium: false,
        metadata: {},
      ),
      KidsContent(
        id: 'kids_content_2',
        title: 'تعلم الحروف العربية مع آيات القرآن',
        description: 'تعلم نطق الحروف العربية من خلال آيات قرآنية مختارة',
        imageUrl: 'assets/images/kids/arabic_letters.jpg',
        videoUrl: 'assets/videos/kids/arabic_letters.mp4',
        ageGroup: AgeGroup.elementary,
        contentType: ContentType.interactiveLesson,
        activities: [
          ContentActivity(
            id: 'kids_activity_3',
            title: 'استماع للحروف',
            description: 'استمع إلى نطق الحروف العربية',
            imageUrl: 'assets/images/kids/activities/listen_letters.jpg',
            activityType: ActivityType.listen,
            content: ['assets/audio/kids/arabic_letters.mp3'],
            duration: 10,
            points: 15,
            isInteractive: false,
          ),
          ContentActivity(
            id: 'kids_activity_4',
            title: 'اكتب الحروف',
            description: 'تدرب على كتابة الحروف العربية',
            imageUrl: 'assets/images/kids/activities/write_letters.jpg',
            activityType: ActivityType.write,
            content: [
              'assets/images/kids/writing/alef.png',
              'assets/images/kids/writing/ba.png',
              'assets/images/kids/writing/ta.png',
            ],
            duration: 20,
            points: 30,
            isInteractive: true,
          ),
        ],
        orderIndex: 2,
        isPremium: false,
        metadata: {},
      ),
      KidsContent(
        id: 'kids_content_3',
        title: 'أناشيد إسلامية للأطفال',
        description: 'مجموعة من الأناشيد الإسلامية التعليمية للأطفال',
        imageUrl: 'assets/images/kids/islamic_songs.jpg',
        videoUrl: '',
        ageGroup: AgeGroup.preschool,
        contentType: ContentType.song,
        activities: [
          ContentActivity(
            id: 'kids_activity_5',
            title: 'نشيد الحروف الهجائية',
            description: 'نشيد تعليمي للحروف الهجائية',
            imageUrl: 'assets/images/kids/activities/song_letters.jpg',
            activityType: ActivityType.listen,
            content: ['assets/audio/kids/song_letters.mp3'],
            duration: 3,
            points: 5,
            isInteractive: false,
          ),
          ContentActivity(
            id: 'kids_activity_6',
            title: 'نشيد أركان الإسلام',
            description: 'نشيد تعليمي عن أركان الإسلام',
            imageUrl: 'assets/images/kids/activities/song_pillars.jpg',
            activityType: ActivityType.listen,
            content: ['assets/audio/kids/song_pillars.mp3'],
            duration: 3,
            points: 5,
            isInteractive: false,
          ),
        ],
        orderIndex: 3,
        isPremium: false,
        metadata: {},
      ),
    ];
    
    // تطبيق التصفية حسب الفئة العمرية
    List<KidsContent> filteredContent = allContent;
    if (ageFilter != null) {
      filteredContent = filteredContent.where((content) => content.ageGroup == ageFilter).toList();
    }
    
    // تطبيق التصفية حسب نوع المحتوى
    if (typeFilter != null) {
      filteredContent = filteredContent.where((content) => content.contentType == typeFilter).toList();
    }
    
    // ترتيب المحتوى حسب الترتيب
    filteredContent.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    
    return filteredContent;
  }
  
  /// بيانات افتراضية لألعاب الأطفال
  List<KidsGame> _getMockKidsGames(AgeGroup? ageFilter, GameType? typeFilter) {
    final List<KidsGame> allGames = [
      KidsGame(
        id: 'kids_game_1',
        title: 'اربط الآية بالسورة',
        description: 'لعبة تعليمية لربط الآيات القرآنية بالسور المناسبة',
        imageUrl: 'assets/images/kids/games/match_verses.jpg',
        ageGroup: AgeGroup.elementary,
        gameType: GameType.matching,
        difficulty: GameDifficulty.easy,
        maxScore: 100,
        duration: 5,
        skills: ['الذاكرة', 'المعرفة بالقرآن'],
        gameData: {
          'pairs': [
            {'verse': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', 'surah': 'الفاتحة'},
            {'verse': 'قُلْ هُوَ اللَّهُ أَحَدٌ', 'surah': 'الإخلاص'},
            {'verse': 'تَبَّتْ يَدَا أَبِي لَهَبٍ وَتَبَّ', 'surah': 'المسد'},
          ],
        },
        isAvailableOffline: true,
      ),
      KidsGame(
        id: 'kids_game_2',
        title: 'لغز الحروف الهجائية',
        description: 'لعبة تعليمية لتعلم الحروف الهجائية',
        imageUrl: 'assets/images/kids/games/letters_puzzle.jpg',
        ageGroup: AgeGroup.preschool,
        gameType: GameType.puzzle,
        difficulty: GameDifficulty.easy,
        maxScore: 50,
        duration: 10,
        skills: ['التركيز', 'معرفة الحروف'],
        gameData: {
          'letters': ['أ', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر'],
        },
        isAvailableOffline: true,
      ),
      KidsGame(
        id: 'kids_game_3',
        title: 'اختبار قصص الأنبياء',
        description: 'اختبار معرفي حول قصص الأنبياء المذكورة في القرآن',
        imageUrl: 'assets/images/kids/games/prophets_quiz.jpg',
        ageGroup: AgeGroup.middleschool,
        gameType: GameType.quiz,
        difficulty: GameDifficulty.medium,
        maxScore: 150,
        duration: 15,
        skills: ['المعرفة الدينية', 'الذاكرة'],
        gameData: {
          'questions': [
            {
              'question': 'من هو النبي الذي بنى السفينة؟',
              'options': ['نوح', 'إبراهيم', 'موسى', 'يونس'],
              'answer': 'نوح',
            },
            {
              'question': 'من هو النبي الذي ألقي في النار ولم تحرقه؟',
              'options': ['إبراهيم', 'موسى', 'يوسف', 'يعقوب'],
              'answer': 'إبراهيم',
            },
          ],
        },
        isAvailableOffline: false,
      ),
    ];
    
    // تطبيق التصفية حسب الفئة العمرية
    List<KidsGame> filteredGames = allGames;
    if (ageFilter != null) {
      filteredGames = filteredGames.where((game) => game.ageGroup == ageFilter).toList();
    }
    
    // تطبيق التصفية حسب نوع اللعبة
    if (typeFilter != null) {
      filteredGames = filteredGames.where((game) => game.gameType == typeFilter).toList();
    }
    
    return filteredGames;
  }
  
  /// بيانات افتراضية لإنجازات الأطفال
  List<KidsAchievement> _getMockKidsAchievements(AchievementCategory? categoryFilter) {
    final List<KidsAchievement> allAchievements = [
      KidsAchievement(
        id: 'kids_achievement_5_activities',
        title: 'المستكشف الصغير',
        description: 'أكملت 5 أنشطة تعليمية',
        imageUrl: 'assets/images/kids/achievements/explorer.png',
        pointsRequired: 0,
        category: AchievementCategory.exploration,
        isSecret: false,
        unlockCriteria: 'أكمل 5 أنشطة تعليمية',
      ),
      KidsAchievement(
        id: 'kids_achievement_10_activities',
        title: 'المتعلم النشط',
        description: 'أكملت 10 أنشطة تعليمية',
        imageUrl: 'assets/images/kids/achievements/active_learner.png',
        pointsRequired: 0,
        category: AchievementCategory.learning,
        isSecret: false,
        unlockCriteria: 'أكمل 10 أنشطة تعليمية',
      ),
      KidsAchievement(
        id: 'kids_achievement_3_games',
        title: 'اللاعب المبتدئ',
        description: 'لعبت 3 ألعاب تعليمية',
        imageUrl: 'assets/images/kids/achievements/rookie_player.png',
        pointsRequired: 0,
        category: AchievementCategory.exploration,
        isSecret: false,
        unlockCriteria: 'العب 3 ألعاب تعليمية',
      ),
      KidsAchievement(
        id: 'kids_achievement_daily_streak',
        title: 'المواظب الصغير',
        description: 'استخدمت التطبيق لمدة 7 أيام متتالية',
        imageUrl: 'assets/images/kids/achievements/streak.png',
        pointsRequired: 0,
        category: AchievementCategory.consistency,
        isSecret: false,
        unlockCriteria: 'استخدم التطبيق لمدة 7 أيام متتالية',
      ),
    ];
    
    // تطبيق التصفية حسب الفئة
    if (categoryFilter != null) {
      return allAchievements
          .where((achievement) => achievement.category == categoryFilter)
          .toList();
    }
    
    return allAchievements;
  }
}