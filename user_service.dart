import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';

class UserService {
  static const String _userCacheKey = 'cached_user_profile';
  
  // الحصول على معلومات المستخدم من API أو التخزين المحلي
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      // محاولة الحصول على البيانات من الخادم
      final response = await http.get(
        Uri.parse('${AppConstants.baseApiUrl}${AppConstants.userProfileEndpoint}/$userId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userProfile = UserProfile.fromJson(data);
        
        // تخزين البيانات محليًا للاستخدام في وضع عدم الاتصال
        _cacheUserProfile(userProfile);
        
        return userProfile;
      } else {
        print('خطأ في جلب بيانات المستخدم: ${response.statusCode}');
        
        // في حالة الفشل، حاول استرداد البيانات من التخزين المحلي
        return _getCachedUserProfile(userId);
      }
    } catch (e) {
      print('استثناء في جلب بيانات المستخدم: $e');
      // في حالة وجود استثناء (مثلا انقطاع الاتصال)، استخدم البيانات المخزنة محليًا
      return _getCachedUserProfile(userId);
    }
  }
  
  // تحديث بيانات المستخدم
  Future<bool> updateUserProfile(UserProfile userProfile) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseApiUrl}${AppConstants.userProfileEndpoint}/${userProfile.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userProfile.toJson()),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        // تحديث البيانات المخزنة محليًا
        _cacheUserProfile(userProfile);
        return true;
      } else {
        print('خطأ في تحديث بيانات المستخدم: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('استثناء في تحديث بيانات المستخدم: $e');
      // في حالة فشل التحديث على الخادم، قم بتخزين البيانات محليًا على الأقل
      _cacheUserProfile(userProfile);
      return false;
    }
  }
  
  // إضافة إنجاز جديد للمستخدم
  Future<bool> addAchievement(String userId, Achievement achievement) async {
    try {
      // احصل على الملف الشخصي الحالي أولاً
      final userProfile = await getUserProfile(userId);
      if (userProfile == null) {
        return false;
      }
      
      // أضف الإنجاز إلى القائمة
      final updatedAchievements = List<Achievement>.from(userProfile.achievements)
        ..add(achievement);
      
      // قم بتحديث نقاط المستخدم
      final updatedPoints = userProfile.points + achievement.pointsAwarded;
      
      // أنشئ ملف شخصي محدث
      final updatedProfile = userProfile.copyWith(
        achievements: updatedAchievements,
        points: updatedPoints,
      );
      
      // قم بتحديث الملف الشخصي
      return await updateUserProfile(updatedProfile);
    } catch (e) {
      print('استثناء في إضافة إنجاز: $e');
      return false;
    }
  }
  
  // تحديث تقدم المستخدم في مسار التعلم
  Future<bool> updateLearningProgress(String userId, LearningPath learningPath) async {
    try {
      // احصل على الملف الشخصي الحالي أولاً
      final userProfile = await getUserProfile(userId);
      if (userProfile == null) {
        return false;
      }
      
      // أنشئ ملف شخصي محدث
      final updatedProfile = userProfile.copyWith(
        learningPath: learningPath,
      );
      
      // قم بتحديث الملف الشخصي
      return await updateUserProfile(updatedProfile);
    } catch (e) {
      print('استثناء في تحديث مسار التعلم: $e');
      return false;
    }
  }
  
  // تحديث إحصائيات التلاوة
  Future<bool> updateRecitationStats(String userId, RecitationAnalysis analysis) async {
    try {
      // احصل على الملف الشخصي الحالي أولاً
      final userProfile = await getUserProfile(userId);
      if (userProfile == null) {
        return false;
      }
      
      // استخرج إحصائيات التلاوة الحالية
      final currentStats = userProfile.recitationStats;
      
      // احسب الإحصائيات الجديدة
      final updatedStats = RecitationStats(
        totalRecitations: currentStats.totalRecitations + 1,
        perfectRecitations: analysis.errors.isEmpty ? 
            currentStats.perfectRecitations + 1 : currentStats.perfectRecitations,
        totalMinutesRecited: currentStats.totalMinutesRecited + 
            (analysis.totalDuration?.inMinutes ?? 0),
        errorTypeFrequency: _updateErrorFrequency(
          currentStats.errorTypeFrequency, 
          analysis.errors,
        ),
        tajweedRuleAccuracy: _updateTajweedAccuracy(
          currentStats.tajweedRuleAccuracy, 
          analysis.correctRules,
        ),
      );
      
      // أنشئ ملف شخصي محدث
      final updatedProfile = userProfile.copyWith(
        recitationStats: updatedStats,
      );
      
      // قم بتحديث الملف الشخصي
      return await updateUserProfile(updatedProfile);
    } catch (e) {
      print('استثناء في تحديث إحصائيات التلاوة: $e');
      return false;
    }
  }
  
  // تخزين الملف الشخصي محليًا
  Future<void> _cacheUserProfile(UserProfile userProfile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userCacheKey, json.encode(userProfile.toJson()));
    } catch (e) {
      print('استثناء في تخزين بيانات المستخدم محليًا: $e');
    }
  }
  
  // استرداد الملف الشخصي من التخزين المحلي
  Future<UserProfile?> _getCachedUserProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_userCacheKey);
      
      if (cachedData != null) {
        return UserProfile.fromJson(json.decode(cachedData));
      }
      
      // إذا لم يكن هناك بيانات مخزنة، أنشئ ملف شخصي افتراضي
      return _createDefaultUserProfile(userId);
    } catch (e) {
      print('استثناء في استرداد بيانات المستخدم المخزنة محليًا: $e');
      return _createDefaultUserProfile(userId);
    }
  }
  
  // إنشاء ملف شخصي افتراضي
  UserProfile _createDefaultUserProfile(String userId) {
    return UserProfile(
      id: userId,
      displayName: 'مستخدم جديد',
      email: 'user@example.com',
      level: 1,
      points: 0,
      achievements: [],
      learningPath: LearningPath(
        currentLevel: 'مبتدئ',
        completedLessons: [],
        unlockedLessons: ['مقدمة في التجويد', 'مخارج الحروف الأساسية'],
        nextMilestone: 'إتقان مخارج الحروف',
        progressPercentage: 0.0,
      ),
      recitationStats: RecitationStats(
        totalRecitations: 0,
        perfectRecitations: 0,
        totalMinutesRecited: 0,
        errorTypeFrequency: {},
        tajweedRuleAccuracy: {},
      ),
    );
  }
  
  // تحديث تردد أنواع الأخطاء
  Map<String, int> _updateErrorFrequency(
    Map<String, int> current, 
    List<dynamic> newErrors,
  ) {
    final updatedFrequency = Map<String, int>.from(current);
    
    for (var error in newErrors) {
      final type = error['type'] as String;
      updatedFrequency[type] = (updatedFrequency[type] ?? 0) + 1;
    }
    
    return updatedFrequency;
  }
  
  // تحديث دقة قواعد التجويد
  Map<String, double> _updateTajweedAccuracy(
    Map<String, double> current, 
    List<dynamic> correctRules,
  ) {
    final updatedAccuracy = Map<String, double>.from(current);
    
    for (var rule in correctRules) {
      final type = rule['type'] as String;
      final quality = rule['quality'] as num;
      
      // إذا كانت القاعدة موجودة بالفعل، احسب المتوسط
      if (updatedAccuracy.containsKey(type)) {
        final currentValue = updatedAccuracy[type]!;
        // متوسط مرجح يعطي وزناً أكبر للقيم الجديدة
        updatedAccuracy[type] = (currentValue * 0.7) + (quality.toDouble() * 0.3);
      } else {
        // إذا كانت القاعدة جديدة، أضفها
        updatedAccuracy[type] = quality.toDouble();
      }
    }
    
    return updatedAccuracy;
  }
}

// امتداد RecitationAnalysis
extension RecitationAnalysisExtension on RecitationAnalysis {
  // إضافة حقل لإجمالي مدة التلاوة (قد يكون مفيدًا لحساب إحصائيات المستخدم)
  Duration? get totalDuration {
    if (errors.isEmpty) return null;
    
    try {
      // استخراج آخر وقت نهاية في قائمة الأخطاء
      final lastErrorEndTime = errors
          .map((e) => e['endTime'] as double)
          .reduce((max, time) => time > max ? time : max);
      
      return Duration(milliseconds: (lastErrorEndTime * 1000).round());
    } catch (e) {
      return null;
    }
  }
}