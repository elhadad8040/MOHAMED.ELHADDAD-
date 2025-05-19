import 'package:flutter/material.dart';
import 'models/tajweed_rule.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recitation_analysis_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tajweed_rule_details_screen.dart';
import 'screens/tajweed_rules_screen.dart';
import 'utils/constants.dart';

/// مسؤول عن توجيه التنقل في التطبيق
class AppRouter {
  /// إنشاء المسار المناسب بناءً على الإعدادات
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case AppRoutes.recitationAnalysis:
        // التحقق من وجود البيانات المطلوبة للتحليل
        if (settings.arguments != null && settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => RecitationAnalysisScreen(
              audioFilePath: args['audioFilePath'] as String?,
              currentRecitationId: args['currentRecitationId'] as String?,
              selectedSurahId: args['selectedSurahId'] as int? ?? AppConstants.defaultSurahId,
              selectedAyahId: args['selectedAyahId'] as int? ?? AppConstants.defaultAyahId,
            ),
          );
        }
        // في حالة عدم توفر البيانات، عودة للشاشة الرئيسية
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
        
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
        
      case AppRoutes.tajweedRules:
        return MaterialPageRoute(builder: (_) => const TajweedRulesScreen());
        
      case AppRoutes.tajweedRuleDetails:
        // التحقق من وجود قاعدة التجويد المطلوبة
        if (settings.arguments != null && settings.arguments is TajweedRule) {
          final rule = settings.arguments as TajweedRule;
          return MaterialPageRoute(
            builder: (_) => TajweedRuleDetailsScreen(rule: rule),
          );
        }
        // في حالة عدم توفر القاعدة، عودة لشاشة قواعد التجويد
        return MaterialPageRoute(builder: (_) => const TajweedRulesScreen());
        
      default:
        // مسار غير معروف - عودة للشاشة الرئيسية مع رسالة خطأ
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('المسار المطلوب غير موجود: ${settings.name}'),
            ),
          ),
        );
    }
  }
}