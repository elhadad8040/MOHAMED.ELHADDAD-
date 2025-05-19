import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tajweed_rule.dart';
import '../utils/constants.dart';

/// خدمة لإدارة قواعد التجويد والحصول عليها
class TajweedService {
  static const String _tajweedRulesCacheKey = 'cached_tajweed_rules';
  static const String _tajweedEndpoint = '/tajweed/rules';
  
  /// الحصول على قائمة بجميع قواعد التجويد
  Future<List<TajweedRule>> getAllTajweedRules() async {
    try {
      // محاولة الحصول على البيانات من الخادم
      final response = await http.get(
        Uri.parse('${AppConstants.baseApiUrl}$_tajweedEndpoint'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final rules = data.map((json) => TajweedRule.fromJson(json)).toList();
        
        // تخزين البيانات محليًا للاستخدام في وضع عدم الاتصال
        _cacheTajweedRules(rules);
        
        return rules;
      } else {
        print('خطأ في جلب قواعد التجويد: ${response.statusCode}');
        
        // في حالة الفشل، حاول استرداد البيانات من التخزين المحلي
        return await _getCachedTajweedRules();
      }
    } catch (e) {
      print('استثناء في جلب قواعد التجويد: $e');
      // في حالة وجود استثناء (مثلا انقطاع الاتصال)، استخدم البيانات المخزنة محليًا
      return await _getCachedTajweedRules();
    }
  }
  
  /// الحصول على قواعد التجويد مرتبة حسب التصنيف
  Future<Map<TajweedCategory, List<TajweedRule>>> getTajweedRulesByCategory() async {
    final allRules = await getAllTajweedRules();
    final Map<TajweedCategory, List<TajweedRule>> rulesByCategory = {};
    
    // تصنيف القواعد حسب الفئة
    for (var rule in allRules) {
      if (!rulesByCategory.containsKey(rule.category)) {
        rulesByCategory[rule.category] = [];
      }
      rulesByCategory[rule.category]!.add(rule);
    }
    
    return rulesByCategory;
  }
  
  /// البحث في قواعد التجويد
  Future<List<TajweedRule>> searchTajweedRules(String query) async {
    final allRules = await getAllTajweedRules();
    
    if (query.isEmpty) {
      return allRules;
    }
    
    // البحث في العناوين والوصف
    return allRules.where((rule) {
      final nameAr = rule.nameAr.toLowerCase();
      final nameEn = rule.nameEn.toLowerCase();
      final description = rule.description.toLowerCase();
      final searchQuery = query.toLowerCase();
      
      return nameAr.contains(searchQuery) || 
             nameEn.contains(searchQuery) || 
             description.contains(searchQuery);
    }).toList();
  }
  
  /// الحصول على قاعدة تجويد محددة بواسطة المعرف
  Future<TajweedRule?> getTajweedRuleById(String ruleId) async {
    final allRules = await getAllTajweedRules();
    
    try {
      return allRules.firstWhere((rule) => rule.id == ruleId);
    } catch (e) {
      print('لم يتم العثور على قاعدة التجويد بالمعرف: $ruleId');
      return null;
    }
  }
  
  /// الحصول على قواعد التجويد المتعلقة بقاعدة محددة
  Future<List<TajweedRule>> getRelatedRules(String ruleId) async {
    final rule = await getTajweedRuleById(ruleId);
    if (rule == null) {
      return [];
    }
    
    final allRules = await getAllTajweedRules();
    return allRules.where((r) => 
        rule.relatedRules.contains(r.id) || 
        r.category == rule.category).toList();
  }
  
  /// تخزين قواعد التجويد محليًا
  Future<void> _cacheTajweedRules(List<TajweedRule> rules) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rulesJson = rules.map((rule) => rule.toJson()).toList();
      await prefs.setString(_tajweedRulesCacheKey, json.encode(rulesJson));
    } catch (e) {
      print('استثناء في تخزين قواعد التجويد محليًا: $e');
    }
  }
  
  /// استرداد قواعد التجويد من التخزين المحلي
  Future<List<TajweedRule>> _getCachedTajweedRules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_tajweedRulesCacheKey);
      
      if (cachedData != null) {
        final List<dynamic> rulesJson = json.decode(cachedData);
        return rulesJson.map((json) => TajweedRule.fromJson(json)).toList();
      }
      
      // إذا لم يكن هناك بيانات مخزنة، أنشئ قائمة افتراضية
      return _getDefaultTajweedRules();
    } catch (e) {
      print('استثناء في استرداد قواعد التجويد المخزنة محليًا: $e');
      return _getDefaultTajweedRules();
    }
  }
  
  /// الحصول على قائمة افتراضية من قواعد التجويد للاستخدام في وضع عدم الاتصال
  List<TajweedRule> _getDefaultTajweedRules() {
    // قواعد النون الساكنة والتنوين
    final noonRules = [
      TajweedRule(
        id: 'noon_1',
        nameAr: 'الإظهار',
        nameEn: 'Izhar',
        description: 'إظهار النون الساكنة أو التنوين عند الحروف الحلقية',
        example: 'مَنْ هَذَا، كِتَابٌ هَادِفٌ',
        audioExample: 'assets/audio/examples/izhar.mp3',
        relatedRules: ['meem_1'],
        category: TajweedCategory.nun,
        subRules: [
          TajweedSubRule(
            id: 'noon_1_1',
            name: 'إظهار حلقي',
            description: 'إظهار النون الساكنة أو التنوين عند أحرف الحلق الستة: ء هـ ع ح غ خ',
            example: 'مِنْ خَيْرٍ، عَلِيمٌ حَكِيمٌ',
            audioExample: 'assets/audio/examples/izhar_halqi.mp3',
            commonErrors: [
              'نطق النون بغنة عند حروف الإظهار',
              'عدم نطق النون بوضوح',
            ],
          ),
        ],
      ),
      TajweedRule(
        id: 'noon_2',
        nameAr: 'الإدغام',
        nameEn: 'Idgham',
        description: 'إدغام النون الساكنة أو التنوين في أحرف الإدغام الستة: ي ر م ن و ل',
        example: 'مِنْ نَعِيمٍ، هُدًى وَرَحْمَةٌ',
        audioExample: 'assets/audio/examples/idgham.mp3',
        relatedRules: ['noon_3'],
        category: TajweedCategory.nun,
        subRules: [
          TajweedSubRule(
            id: 'noon_2_1',
            name: 'إدغام بغنة',
            description: 'إدغام النون الساكنة أو التنوين مع غنة في أحرف: ي ن م و',
            example: 'مِنْ مَالٍ، كِتَابٌ مُبِينٌ',
            audioExample: 'assets/audio/examples/idgham_ghunnah.mp3',
            commonErrors: [
              'إظهار النون عند أحرف الإدغام',
              'عدم إتمام الغنة',
            ],
          ),
          TajweedSubRule(
            id: 'noon_2_2',
            name: 'إدغام بغير غنة',
            description: 'إدغام النون الساكنة أو التنوين بدون غنة في أحرف: ل ر',
            example: 'مِنْ رَبِّهِمْ، غَفُورٌ رَحِيمٌ',
            audioExample: 'assets/audio/examples/idgham_no_ghunnah.mp3',
            commonErrors: [
              'إظهار النون عند اللام والراء',
              'إضافة غنة عند الإدغام في اللام والراء',
            ],
          ),
        ],
      ),
    ];
    
    // قواعد الميم الساكنة
    final meemRules = [
      TajweedRule(
        id: 'meem_1',
        nameAr: 'إخفاء الميم',
        nameEn: 'Ikhfa Meem',
        description: 'إخفاء الميم الساكنة عند الباء',
        example: 'هُمْ بِالْآخِرَةِ',
        audioExample: 'assets/audio/examples/ikhfa_meem.mp3',
        relatedRules: ['noon_3'],
        category: TajweedCategory.meem,
        subRules: [
          TajweedSubRule(
            id: 'meem_1_1',
            name: 'إخفاء شفوي',
            description: 'إخفاء الميم الساكنة عند الباء مع الغنة',
            example: 'وَمَا هُمْ بِمُؤْمِنِينَ',
            audioExample: 'assets/audio/examples/ikhfa_shafawi.mp3',
            commonErrors: [
              'إظهار الميم عند الباء',
              'إدغام الميم في الباء كاملاً',
            ],
          ),
        ],
      ),
    ];
    
    // القلقلة
    final qalqalahRules = [
      TajweedRule(
        id: 'qalqalah_1',
        nameAr: 'القلقلة',
        nameEn: 'Qalqalah',
        description: 'اضطراب الصوت عند النطق بالحرف الساكن من حروف القلقلة: ق ط ب ج د',
        example: 'يَخْلُقْكُمْ، وَالطَّارِقِ',
        audioExample: 'assets/audio/examples/qalqalah.mp3',
        relatedRules: [],
        category: TajweedCategory.qalqalah,
        subRules: [
          TajweedSubRule(
            id: 'qalqalah_1_1',
            name: 'قلقلة صغرى',
            description: 'قلقلة خفيفة عندما يكون حرف القلقلة ساكناً في وسط الكلمة',
            example: 'يَجْعَلُونَ، نَقْتَبِسْ',
            audioExample: 'assets/audio/examples/qalqalah_sughra.mp3',
            commonErrors: [
              'عدم قلقلة الحرف الساكن',
              'المبالغة في القلقلة في وسط الكلمة',
            ],
          ),
          TajweedSubRule(
            id: 'qalqalah_1_2',
            name: 'قلقلة كبرى',
            description: 'قلقلة قوية عندما يكون حرف القلقلة في آخر الكلمة عند الوقف',
            example: 'الْفَلَقْ، مِنْ شَرٍّ خَلَقْ',
            audioExample: 'assets/audio/examples/qalqalah_kubra.mp3',
            commonErrors: [
              'عدم قلقلة الحرف في نهاية الكلمة عند الوقف',
              'القلقلة الخفيفة بدلاً من القوية',
            ],
          ),
        ],
      ),
    ];
    
    return [...noonRules, ...meemRules, ...qalqalahRules];
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tajweed_rule.dart';
import '../utils/constants.dart';

/// خدمة لإدارة قواعد التجويد والحصول عليها
class TajweedService {
  static const String _tajweedRulesCacheKey = 'cached_tajweed_rules';
  static const String _tajweedEndpoint = '/tajweed/rules';
  
  /// الحصول على قائمة بجميع قواعد التجويد
  Future<List<TajweedRule>> getAllTajweedRules() async {
    try {
      // محاولة الحصول على البيانات من الخادم
      final response = await http.get(
        Uri.parse('${AppConstants.baseApiUrl}$_tajweedEndpoint'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final rules = data.map((json) => TajweedRule.fromJson(json)).toList();
        
        // تخزين البيانات محليًا للاستخدام في وضع عدم الاتصال
        _cacheTajweedRules(rules);
        
        return rules;
      } else {
        print('خطأ في جلب قواعد التجويد: ${response.statusCode}');
        
        // في حالة الفشل، حاول استرداد البيانات من التخزين المحلي
        return await _getCachedTajweedRules();
      }
    } catch (e) {
      print('استثناء في جلب قواعد التجويد: $e');
      // في حالة وجود استثناء (مثلا انقطاع الاتصال)، استخدم البيانات المخزنة محليًا
      return await _getCachedTajweedRules();
    }
  }
  
  /// الحصول على قواعد التجويد مرتبة حسب التصنيف
  Future<Map<TajweedCategory, List<TajweedRule>>> getTajweedRulesByCategory() async {
    final allRules = await getAllTajweedRules();
    final Map<TajweedCategory, List<TajweedRule>> rulesByCategory = {};
    
    // تصنيف القواعد حسب الفئة
    for (var rule in allRules) {
      if (!rulesByCategory.containsKey(rule.category)) {
        rulesByCategory[rule.category] = [];
      }
      rulesByCategory[rule.category]!.add(rule);
    }
    
    return rulesByCategory;
  }
  
  /// البحث في قواعد التجويد
  Future<List<TajweedRule>> searchTajweedRules(String query) async {
    final allRules = await getAllTajweedRules();
    
    if (query.isEmpty) {
      return allRules;
    }
    
    // البحث في العناوين والوصف
    return allRules.where((rule) {
      final nameAr = rule.nameAr.toLowerCase();
      final nameEn = rule.nameEn.toLowerCase();
      final description = rule.description.toLowerCase();
      final searchQuery = query.toLowerCase();
      
      return nameAr.contains(searchQuery) || 
             nameEn.contains(searchQuery) || 
             description.contains(searchQuery);
    }).toList();
  }
  
  /// الحصول على قاعدة تجويد محددة بواسطة المعرف
  Future<TajweedRule?> getTajweedRuleById(String ruleId) async {
    final allRules = await getAllTajweedRules();
    
    try {
      return allRules.firstWhere((rule) => rule.id == ruleId);
    } catch (e) {
      print('لم يتم العثور على قاعدة التجويد بالمعرف: $ruleId');
      return null;
    }
  }
  
  /// الحصول على قواعد التجويد المتعلقة بقاعدة محددة
  Future<List<TajweedRule>> getRelatedRules(String ruleId) async {
    final rule = await getTajweedRuleById(ruleId);
    if (rule == null) {
      return [];
    }
    
    final allRules = await getAllTajweedRules();
    return allRules.where((r) => 
        rule.relatedRules.contains(r.id) || 
        r.category == rule.category).toList();
  }
  
  /// تخزين قواعد التجويد محليًا
  Future<void> _cacheTajweedRules(List<TajweedRule> rules) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rulesJson = rules.map((rule) => rule.toJson()).toList();
      await prefs.setString(_tajweedRulesCacheKey, json.encode(rulesJson));
    } catch (e) {
      print('استثناء في تخزين قواعد التجويد محليًا: $e');
    }
  }
  
  /// استرداد قواعد التجويد من التخزين المحلي
  Future<List<TajweedRule>> _getCachedTajweedRules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_tajweedRulesCacheKey);
      
      if (cachedData != null) {
        final List<dynamic> rulesJson = json.decode(cachedData);
        return rulesJson.map((json) => TajweedRule.fromJson(json)).toList();
      }
      
      // إذا لم يكن هناك بيانات مخزنة، أنشئ قائمة افتراضية
      return _getDefaultTajweedRules();
    } catch (e) {
      print('استثناء في استرداد قواعد التجويد المخزنة محليًا: $e');
      return _getDefaultTajweedRules();
    }
  }
  
  /// الحصول على قائمة افتراضية من قواعد التجويد للاستخدام في وضع عدم الاتصال
  List<TajweedRule> _getDefaultTajweedRules() {
    // قواعد النون الساكنة والتنوين
    final noonRules = [
      TajweedRule(
        id: 'noon_1',
        nameAr: 'الإظهار',
        nameEn: 'Izhar',
        description: 'إظهار النون الساكنة أو التنوين عند الحروف الحلقية',
        example: 'مَنْ هَذَا، كِتَابٌ هَادِفٌ',
        audioExample: 'assets/audio/examples/izhar.mp3',
        relatedRules: ['meem_1'],
        category: TajweedCategory.nun,
        subRules: [
          TajweedSubRule(
            id: 'noon_1_1',
            name: 'إظهار حلقي',
            description: 'إظهار النون الساكنة أو التنوين عند أحرف الحلق الستة: ء هـ ع ح غ خ',
            example: 'مِنْ خَيْرٍ، عَلِيمٌ حَكِيمٌ',
            audioExample: 'assets/audio/examples/izhar_halqi.mp3',
            commonErrors: [
              'نطق النون بغنة عند حروف الإظهار',
              'عدم نطق النون بوضوح',
            ],
          ),
        ],
      ),
      TajweedRule(
        id: 'noon_2',
        nameAr: 'الإدغام',
        nameEn: 'Idgham',
        description: 'إدغام النون الساكنة أو التنوين في أحرف الإدغام الستة: ي ر م ن و ل',
        example: 'مِنْ نَعِيمٍ، هُدًى وَرَحْمَةٌ',
        audioExample: 'assets/audio/examples/idgham.mp3',
        relatedRules: ['noon_3'],
        category: TajweedCategory.nun,
        subRules: [
          TajweedSubRule(
            id: 'noon_2_1',
            name: 'إدغام بغنة',
            description: 'إدغام النون الساكنة أو التنوين مع غنة في أحرف: ي ن م و',
            example: 'مِنْ مَالٍ، كِتَابٌ مُبِينٌ',
            audioExample: 'assets/audio/examples/idgham_ghunnah.mp3',
            commonErrors: [
              'إظهار النون عند أحرف الإدغام',
              'عدم إتمام الغنة',
            ],
          ),
          TajweedSubRule(
            id: 'noon_2_2',
            name: 'إدغام بغير غنة',
            description: 'إدغام النون الساكنة أو التنوين بدون غنة في أحرف: ل ر',
            example: 'مِنْ رَبِّهِمْ، غَفُورٌ رَحِيمٌ',
            audioExample: 'assets/audio/examples/idgham_no_ghunnah.mp3',
            commonErrors: [
              'إظهار النون عند اللام والراء',
              'إضافة غنة عند الإدغام في اللام والراء',
            ],
          ),
        ],
      ),
    ];
    
    // قواعد الميم الساكنة
    final meemRules = [
      TajweedRule(
        id: 'meem_1',
        nameAr: 'إخفاء الميم',
        nameEn: 'Ikhfa Meem',
        description: 'إخفاء الميم الساكنة عند الباء',
        example: 'هُمْ بِالْآخِرَةِ',
        audioExample: 'assets/audio/examples/ikhfa_meem.mp3',
        relatedRules: ['noon_3'],
        category: TajweedCategory.meem,
        subRules: [
          TajweedSubRule(
            id: 'meem_1_1',
            name: 'إخفاء شفوي',
            description: 'إخفاء الميم الساكنة عند الباء مع الغنة',
            example: 'وَمَا هُمْ بِمُؤْمِنِينَ',
            audioExample: 'assets/audio/examples/ikhfa_shafawi.mp3',
            commonErrors: [
              'إظهار الميم عند الباء',
              'إدغام الميم في الباء كاملاً',
            ],
          ),
        ],
      ),
    ];
    
    // القلقلة
    final qalqalahRules = [
      TajweedRule(
        id: 'qalqalah_1',
        nameAr: 'القلقلة',
        nameEn: 'Qalqalah',
        description: 'اضطراب الصوت عند النطق بالحرف الساكن من حروف القلقلة: ق ط ب ج د',
        example: 'يَخْلُقْكُمْ، وَالطَّارِقِ',
        audioExample: 'assets/audio/examples/qalqalah.mp3',
        relatedRules: [],
        category: TajweedCategory.qalqalah,
        subRules: [
          TajweedSubRule(
            id: 'qalqalah_1_1',
            name: 'قلقلة صغرى',
            description: 'قلقلة خفيفة عندما يكون حرف القلقلة ساكناً في وسط الكلمة',
            example: 'يَجْعَلُونَ، نَقْتَبِسْ',
            audioExample: 'assets/audio/examples/qalqalah_sughra.mp3',
            commonErrors: [
              'عدم قلقلة الحرف الساكن',
              'المبالغة في القلقلة في وسط الكلمة',
            ],
          ),
          TajweedSubRule(
            id: 'qalqalah_1_2',
            name: 'قلقلة كبرى',
            description: 'قلقلة قوية عندما يكون حرف القلقلة في آخر الكلمة عند الوقف',
            example: 'الْفَلَقْ، مِنْ شَرٍّ خَلَقْ',
            audioExample: 'assets/audio/examples/qalqalah_kubra.mp3',
            commonErrors: [
              'عدم قلقلة الحرف في نهاية الكلمة عند الوقف',
              'القلقلة الخفيفة بدلاً من القوية',
            ],
          ),
        ],
      ),
    ];
    
    return [...noonRules, ...meemRules, ...qalqalahRules];
  }
}
