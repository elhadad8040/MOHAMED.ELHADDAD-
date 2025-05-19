class QuranAyah {
  final String id;
  final int surahId;
  final int number;
  final String text;
  final int page;
  final int juz;
  final int hizb;
  final bool sajda;
  
  QuranAyah({
    required this.id,
    required this.surahId,
    required this.number,
    required this.text,
    required this.page,
    required this.juz,
    required this.hizb,
    required this.sajda,
  });
  
  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      id: json['id'],
      surahId: json['surahId'],
      number: json['number'],
      text: json['text'],
      page: json['page'],
      juz: json['juz'],
      hizb: json['hizb'],
      sajda: json['sajda'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahId': surahId,
      'number': number,
      'text': text,
      'page': page,
      'juz': juz,
      'hizb': hizb,
      'sajda': sajda,
    };
  }
}
