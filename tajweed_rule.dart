/// نموذج قاعدة التجويد
class TajweedRule {
  final String id;
  final String nameAr;
  final String nameEn;
  final String description;
  final String example;
  final String audioExample;
  final List<String> relatedRules;
  final TajweedCategory category;
  final List<TajweedSubRule> subRules;
  
  TajweedRule({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.description,
    required this.example,
    required this.audioExample,
    required this.relatedRules,
    required this.category,
    required this.subRules,
  });
  
  factory TajweedRule.fromJson(Map<String, dynamic> json) {
    return TajweedRule(
      id: json['id'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      description: json['description'],
      example: json['example'],
      audioExample: json['audioExample'],
      relatedRules: List<String>.from(json['relatedRules'] ?? []),
      category: TajweedCategoryExtension.fromString(json['category'] ?? 'other'),
      subRules: (json['subRules'] as List? ?? [])
          .map((subRule) => TajweedSubRule.fromJson(subRule))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'description': description,
      'example': example,
      'audioExample': audioExample,
      'relatedRules': relatedRules,
      'category': category.toString(),
      'subRules': subRules.map((subRule) => subRule.toJson()).toList(),
    };
  }
}

/// نموذج القاعدة الفرعية للتجويد
class TajweedSubRule {
  final String id;
  final String name;
  final String description;
  final String example;
  final String audioExample;
  final List<String> commonErrors;
  
  TajweedSubRule({
    required this.id,
    required this.name,
    required this.description,
    required this.example,
    required this.audioExample,
    required this.commonErrors,
  });
  
  factory TajweedSubRule.fromJson(Map<String, dynamic> json) {
    return TajweedSubRule(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      example: json['example'],
      audioExample: json['audioExample'],
      commonErrors: List<String>.from(json['commonErrors'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'example': example,
      'audioExample': audioExample,
      'commonErrors': commonErrors,
    };
  }
}

/// تصنيفات قواعد التجويد
enum TajweedCategory {
  nun,        // أحكام النون الساكنة والتنوين
  meem,       // أحكام الميم الساكنة
  lam,        // أحكام اللام
  qalqalah,   // القلقلة
  madd,       // المدود
  waqf,       // الوقف والابتداء
  makhraj,    // المخارج
  sifaat,     // صفات الحروف
  other,      // أخرى
}

/// امتداد لتسهيل التعامل مع تصنيفات التجويد
extension TajweedCategoryExtension on TajweedCategory {
  String get arabicName {
    switch (this) {
      case TajweedCategory.nun:
        return 'أحكام النون الساكنة والتنوين';
      case TajweedCategory.meem:
        return 'أحكام الميم الساكنة';
      case TajweedCategory.lam:
        return 'أحكام اللام';
      case TajweedCategory.qalqalah:
        return 'القلقلة';
      case TajweedCategory.madd:
        return 'المدود';
      case TajweedCategory.waqf:
        return 'الوقف والابتداء';
      case TajweedCategory.makhraj:
        return 'المخارج';
      case TajweedCategory.sifaat:
        return 'صفات الحروف';
      case TajweedCategory.other:
        return 'أحكام أخرى';
    }
  }
  
  String get englishName {
    switch (this) {
      case TajweedCategory.nun:
        return 'Rules of Noon Saakinah and Tanween';
      case TajweedCategory.meem:
        return 'Rules of Meem Saakinah';
      case TajweedCategory.lam:
        return 'Rules of Lam';
      case TajweedCategory.qalqalah:
        return 'Qalqalah';
      case TajweedCategory.madd:
        return 'Madd (Prolongation)';
      case TajweedCategory.waqf:
        return 'Stopping and Starting';
      case TajweedCategory.makhraj:
        return 'Points of Articulation';
      case TajweedCategory.sifaat:
        return 'Characteristics of Letters';
      case TajweedCategory.other:
        return 'Other Rules';
    }
  }
  
  static TajweedCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'nun':
        return TajweedCategory.nun;
      case 'meem':
        return TajweedCategory.meem;
      case 'lam':
        return TajweedCategory.lam;
      case 'qalqalah':
        return TajweedCategory.qalqalah;
      case 'madd':
        return TajweedCategory.madd;
      case 'waqf':
        return TajweedCategory.waqf;
      case 'makhraj':
        return TajweedCategory.makhraj;
      case 'sifaat':
        return TajweedCategory.sifaat;
      default:
        return TajweedCategory.other;
    }
  }
  
  @override
  String toString() {
    return name;
  }
}
