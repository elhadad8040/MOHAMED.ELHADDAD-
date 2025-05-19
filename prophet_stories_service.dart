import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prophet_story.dart';
import '../utils/constants.dart';

/// خدمة للتعامل مع قصص الأنبياء
class ProphetStoriesService {
  static const String _cachedStoriesKey = 'cached_prophet_stories';
  static const String _cachedStoryDetailsKey = 'cached_story_details_';

  /// الحصول على قائمة قصص الأنبياء
  Future<List<ProphetStory>> getProphetStories() async {
    try {
      // محاولة الحصول على البيانات من الذاكرة المحلية أولاً
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cachedStoriesKey);
      
      if (cachedData != null) {
        return ProphetStory.listFromJson(cachedData);
      }
      
      // الحصول على البيانات من API
      final response = await http.get(
        Uri.parse('${AppConstants.baseApiUrl}${AppConstants.prophetStoriesEndpoint}'),
      );
      
      if (response.statusCode == 200) {
        // تخزين البيانات في الذاكرة المحلية
        prefs.setString(_cachedStoriesKey, response.body);
        
        return ProphetStory.listFromJson(response.body);
      } else {
        throw Exception('فشل في الحصول على قصص الأنبياء: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('خطأ في الحصول على قصص الأنبياء: $e');
      
      // في حالة عدم الاتصال بالإنترنت، نعود بيانات افتراضية
      return _getMockProphetStories();
    }
  }
  
  /// الحصول على تفاصيل قصة نبي معين
  Future<ProphetStory> getProphetStoryDetails(String storyId) async {
    try {
      // محاولة الحصول على البيانات من الذاكرة المحلية أولاً
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('${_cachedStoryDetailsKey}$storyId');
      
      if (cachedData != null) {
        return ProphetStory.fromJson(json.decode(cachedData));
      }
      
      // الحصول على البيانات من API
      final response = await http.get(
        Uri.parse('${AppConstants.baseApiUrl}${AppConstants.prophetStoriesEndpoint}/$storyId'),
      );
      
      if (response.statusCode == 200) {
        // تخزين البيانات في الذاكرة المحلية
        prefs.setString('${_cachedStoryDetailsKey}$storyId', response.body);
        
        return ProphetStory.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل في الحصول على تفاصيل القصة: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('خطأ في الحصول على تفاصيل القصة: $e');
      
      // في حالة عدم الاتصال بالإنترنت، نعود بيانات افتراضية
      return _getMockStoryDetails(storyId);
    }
  }
  
  /// الحصول على القصص المرتبطة بقصة معينة
  Future<List<ProphetStory>> getRelatedStories(String storyId) async {
    try {
      final story = await getProphetStoryDetails(storyId);
      final allStories = await getProphetStories();
      
      return allStories
          .where((s) => story.relatedStoriesIds.contains(s.id))
          .toList();
    } catch (e) {
      debugPrint('خطأ في الحصول على القصص المرتبطة: $e');
      return [];
    }
  }
  
  /// الحصول على قصص من فترة زمنية معينة
  Future<List<ProphetStory>> getStoriesByEra(String era) async {
    try {
      final allStories = await getProphetStories();
      
      return allStories
          .where((story) => story.era == era)
          .toList();
    } catch (e) {
      debugPrint('خطأ في الحصول على قصص الفترة: $e');
      return [];
    }
  }
  
  /// الحصول على التسلسل الزمني للقصص
  Future<List<ProphetStory>> getStoriesTimeline() async {
    try {
      final allStories = await getProphetStories();
      
      // ترتيب القصص حسب الفترة الزمنية
      allStories.sort((a, b) => a.timelinePeriodStart.compareTo(b.timelinePeriodStart));
      
      return allStories;
    } catch (e) {
      debugPrint('خطأ في الحصول على التسلسل الزمني: $e');
      return [];
    }
  }
  
  /// حفظ تقدم المستخدم في قراءة القصص
  Future<bool> saveStoryProgress(String storyId, int chapterIndex) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String progressKey = '${AppConstants.storiesProgressKey}_$storyId';
      
      return await prefs.setInt(progressKey, chapterIndex);
    } catch (e) {
      debugPrint('خطأ في حفظ تقدم القصة: $e');
      return false;
    }
  }
  
  /// الحصول على تقدم المستخدم في قراءة القصص
  Future<int> getStoryProgress(String storyId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String progressKey = '${AppConstants.storiesProgressKey}_$storyId';
      
      return prefs.getInt(progressKey) ?? 0;
    } catch (e) {
      debugPrint('خطأ في الحصول على تقدم القصة: $e');
      return 0;
    }
  }
  
  /// تنزيل قصة للقراءة بدون اتصال بالإنترنت
  Future<bool> downloadStoryForOffline(String storyId) async {
    try {
      final story = await getProphetStoryDetails(storyId);
      
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String offlineKey = 'offline_story_$storyId';
      
      return await prefs.setString(offlineKey, json.encode(story.toJson()));
    } catch (e) {
      debugPrint('خطأ في تنزيل القصة للقراءة بدون اتصال: $e');
      return false;
    }
  }
  
  /// بيانات افتراضية للقصص
  List<ProphetStory> _getMockProphetStories() {
    return [
      ProphetStory(
        id: 'adam',
        prophetNameAr: 'آدم',
        prophetNameEn: 'Adam',
        title: 'قصة آدم عليه السلام',
        description: 'قصة خلق آدم عليه السلام وحواء وإخراجهما من الجنة',
        era: 'بداية الخلق',
        imageUrl: 'assets/images/stories/adam.jpg',
        audioUrl: 'assets/audio/stories/adam.mp3',
        keyEvents: [
          'خلق آدم من طين',
          'سجود الملائكة لآدم',
          'رفض إبليس السجود',
          'دخول الجنة',
          'الأكل من الشجرة',
          'الهبوط إلى الأرض',
        ],
        lessons: [
          'خطورة الكبر والغرور',
          'أهمية التوبة والاستغفار',
          'عداوة الشيطان للإنسان',
          'الامتحان والابتلاء في الحياة',
        ],
        chapters: [
          StoryChapter(
            id: 'adam_ch1',
            title: 'خلق آدم',
            content: 'خلق الله آدم عليه السلام من طين، ونفخ فيه من روحه، وعلمه الأسماء كلها.',
            quranVerses: ['البقرة: 30-33'],
            imageUrl: 'assets/images/stories/adam_creation.jpg',
            audioUrl: 'assets/audio/stories/adam_ch1.mp3',
            events: [
              StoryEvent(
                id: 'adam_ev1',
                title: 'خلق آدم من طين',
                description: 'خلق الله آدم من طين ونفخ فيه من روحه',
                imageUrl: 'assets/images/stories/adam_creation.jpg',
                year: -10000,
              ),
              StoryEvent(
                id: 'adam_ev2',
                title: 'تعليم آدم الأسماء',
                description: 'علم الله آدم الأسماء كلها',
                imageUrl: 'assets/images/stories/adam_names.jpg',
                year: -10000,
              ),
            ],
            order: 1,
          ),
          StoryChapter(
            id: 'adam_ch2',
            title: 'الخروج من الجنة',
            content: 'أسكن الله آدم وزوجته الجنة، وأمرهما بعدم الأكل من الشجرة، لكن الشيطان أغواهما.',
            quranVerses: ['البقرة: 35-36', 'الأعراف: 19-25'],
            imageUrl: 'assets/images/stories/adam_heaven.jpg',
            audioUrl: 'assets/audio/stories/adam_ch2.mp3',
            events: [
              StoryEvent(
                id: 'adam_ev3',
                title: 'إسكان آدم وحواء الجنة',
                description: 'أسكن الله آدم وزوجته الجنة',
                imageUrl: 'assets/images/stories/adam_eve_heaven.jpg',
                year: -10000,
              ),
              StoryEvent(
                id: 'adam_ev4',
                title: 'الأكل من الشجرة',
                description: 'أغوى الشيطان آدم وحواء فأكلا من الشجرة',
                imageUrl: 'assets/images/stories/adam_tree.jpg',
                year: -10000,
              ),
            ],
            order: 2,
          ),
        ],
        relatedStoriesIds: ['noah', 'iblis'],
        locations: [
          Location(
            id: 'eden',
            name: 'جنة عدن',
            description: 'الجنة التي أسكن الله فيها آدم وحواء',
            latitude: 0,
            longitude: 0,
            imageUrl: 'assets/images/locations/eden.jpg',
            currentName: 'غير معروف',
            country: 'غير معروف',
          ),
          Location(
            id: 'earth',
            name: 'الأرض',
            description: 'المكان الذي هبط إليه آدم وحواء',
            latitude: 21.4225,
            longitude: 39.8262,
            imageUrl: 'assets/images/locations/earth.jpg',
            currentName: 'مكة المكرمة',
            country: 'المملكة العربية السعودية',
          ),
        ],
        timelinePeriodStart: -10000,
        timelinePeriodEnd: -9000,
        metadata: {
          'quranMentions': 25,
          'importance': 'كبيرة جداً',
          'popularConcepts': ['التوبة', 'الحسد', 'الابتلاء'],
        },
      ),
      ProphetStory(
        id: 'noah',
        prophetNameAr: 'نوح',
        prophetNameEn: 'Noah',
        title: 'قصة نوح عليه السلام',
        description: 'قصة نوح عليه السلام ودعوته قومه وبنائه السفينة',
        era: 'ما قبل الطوفان',
        imageUrl: 'assets/images/stories/noah.jpg',
        audioUrl: 'assets/audio/stories/noah.mp3',
        keyEvents: [
          'دعوة نوح لقومه',
          'بناء السفينة',
          'الطوفان العظيم',
          'استقرار السفينة على الجودي',
        ],
        lessons: [
          'الصبر على الدعوة',
          'الاستمرار في العمل بالرغم من السخرية',
          'نصر الله للمؤمنين',
          'عاقبة الظالمين',
        ],
        chapters: [],
        relatedStoriesIds: ['adam', 'hud'],
        locations: [],
        timelinePeriodStart: -5000,
        timelinePeriodEnd: -4000,
        metadata: {
          'quranMentions': 43,
          'importance': 'كبيرة جداً',
          'popularConcepts': ['الطوفان', 'الصبر', 'الدعوة'],
        },
      ),
      ProphetStory(
        id: 'ibrahim',
        prophetNameAr: 'إبراهيم',
        prophetNameEn: 'Abraham',
        title: 'قصة إبراهيم عليه السلام',
        description: 'قصة إبراهيم عليه السلام وتحطيمه للأصنام وبناء الكعبة',
        era: 'عصر الأنبياء الأوائل',
        imageUrl: 'assets/images/stories/ibrahim.jpg',
        audioUrl: 'assets/audio/stories/ibrahim.mp3',
        keyEvents: [
          'تحطيم الأصنام',
          'إلقاؤه في النار',
          'بناء الكعبة',
          'قصة الذبيح',
        ],
        lessons: [
          'التوحيد الخالص',
          'التضحية في سبيل الله',
          'التوكل على الله',
          'بر الوالدين',
        ],
        chapters: [],
        relatedStoriesIds: ['ismail', 'lut'],
        locations: [],
        timelinePeriodStart: -2000,
        timelinePeriodEnd: -1800,
        metadata: {
          'quranMentions': 69,
          'importance': 'كبيرة جداً',
          'popularConcepts': ['التوحيد', 'الضيافة', 'الأبوة'],
        },
      ),
    ];
  }
  
  /// تفاصيل قصة افتراضية
  ProphetStory _getMockStoryDetails(String storyId) {
    final stories = _getMockProphetStories();
    return stories.firstWhere(
      (story) => story.id == storyId,
      orElse: () => stories.first,
    );
  }
}