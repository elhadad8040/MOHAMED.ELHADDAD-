class RecitationAnalysis {
  final int overallScore;
  final double pronunciationAccuracy;
  final double textAccuracy;
  final double rhythmAccuracy;
  final List<dynamic> errors;
  final List<dynamic> correctRules;
  final Map<String, dynamic> makhaarijDiagnosis;
  
  RecitationAnalysis({
    required this.overallScore,
    required this.pronunciationAccuracy,
    required this.textAccuracy,
    required this.rhythmAccuracy,
    required this.errors,
    required this.correctRules,
    required this.makhaarijDiagnosis,
  });
  
  factory RecitationAnalysis.fromJson(Map<String, dynamic> json) {
    return RecitationAnalysis(
      overallScore: json['overallScore'],
      pronunciationAccuracy: json['pronunciationAccuracy'],
      textAccuracy: json['textAccuracy'],
      rhythmAccuracy: json['rhythmAccuracy'],
      errors: json['errors'] ?? [],
      correctRules: json['correctRules'] ?? [],
      makhaarijDiagnosis: json['makhaarijDiagnosis'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'overallScore': overallScore,
      'pronunciationAccuracy': pronunciationAccuracy,
      'textAccuracy': textAccuracy,
      'rhythmAccuracy': rhythmAccuracy,
      'errors': errors,
      'correctRules': correctRules,
      'makhaarijDiagnosis': makhaarijDiagnosis,
    };
  }
}
