import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/recitation_analysis.dart';
import '../models/quran_ayah.dart';

class QuranApiService {
  // عنوان API الافتراضي (يمكن تغييره في الإعدادات)
  static const String _baseUrl = 'https://api.quranai.com/v1';
  
  // جلب معلومات السورة والآية
  Future<QuranAyah?> getAyah(int surahId, int ayahId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quran/ayah/$surahId/$ayahId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return QuranAyah.fromJson(data);
      } else {
        print('خطأ في جلب الآية: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('استثناء في جلب الآية: $e');
      
      // في حالة عدم وجود اتصال، نستخدم بيانات مخزنة محلياً
      return _getMockAyah(surahId, ayahId);
    }
  }
  
  // تحليل تلاوة
  Future<RecitationAnalysis?> analyzeRecitation(String recitationId, File audioFile) async {
    try {
      // إعداد طلب متعدد الأجزاء
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/recitations/analyze'),
      );
      
      // إضافة معلومات التلاوة
      request.fields['recitationId'] = recitationId;
      
      // إضافة ملف الصوت
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
          contentType: MediaType('audio', 'aac'),
        ),
      );
      
      // إرسال الطلب
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RecitationAnalysis.fromJson(data);
      } else {
        print('خطأ في تحليل التلاوة: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('استثناء في تحليل التلاوة: $e');
      // في حالة عدم وجود اتصال، نستخدم بيانات مزيفة للاختبار
      return _getMockAnalysis();
    }
  }
  
  // بيانات مزيفة للآية (للاستخدام في حالة عدم وجود اتصال)
  QuranAyah _getMockAyah(int surahId, int ayahId) {
    if (surahId == 1 && ayahId == 1) {
      return QuranAyah(
        id: '1:1',
        surahId: 1,
        number: 1,
        text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        page: 1,
        juz: 1,
        hizb: 1,
        sajda: false,
      );
    } else if (surahId == 1 && ayahId == 2) {
      return QuranAyah(
        id: '1:2',
        surahId: 1,
        number: 2,
        text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        page: 1,
        juz: 1,
        hizb: 1,
        sajda: false,
      );
    } else {
      // آية افتراضية في حالة عدم توفر البيانات
      return QuranAyah(
        id: '$surahId:$ayahId',
        surahId: surahId,
        number: ayahId,
        text: 'نص الآية غير متوفر حالياً',
        page: 1,
        juz: 1,
        hizb: 1,
        sajda: false,
      );
    }
  }
  
  // تحليل مزيف للتلاوة (للاستخدام في حالة عدم وجود اتصال)
  RecitationAnalysis _getMockAnalysis() {
    return RecitationAnalysis(
      overallScore: 85,
      pronunciationAccuracy: 0.88,
      textAccuracy: 0.92,
      rhythmAccuracy: 0.78,
      errors: [
        {
          'ruleName': 'الإدغام',
          'type': 'إدغام بغير غنة',
          'description': 'لم يتم إدغام اللام في الراء',
          'severity': 'medium',
          'startTime': 1.2,
          'endTime': 1.5,
          'text': 'قُلْ رَبِّي',
          'severityColor': '#FFA500',
          'suggestion': 'يجب إدغام اللام في الراء بدون غنة',
        },
        {
          'ruleName': 'المد',
          'type': 'مد لازم',
          'description': 'المد أقصر من اللازم',
          'severity': 'high',
          'startTime': 3.5,
          'endTime': 3.8,
          'text': 'الضَّآلِّينَ',
          'severityColor': '#FF0000',
          'suggestion': 'يجب مد الألف بمقدار 6 حركات',
        },
      ],
      correctRules: [
        {
          'type': 'الإخفاء',
          'description': 'إخفاء النون الساكنة عند التاء',
          'text': 'مِنْ تَحْتِهَا',
          'quality': 95,
        },
        {
          'type': 'القلقلة',
          'description': 'قلقلة القاف الساكنة',
          'text': 'خَلَقْنَا',
          'quality': 88,
        },
      ],
      makhaarijDiagnosis: {
        'throat': 0.92,
        'tongue': 0.85,
        'lips': 0.95,
        'nasality': 0.78,
        'emphatic': 0.82,
      },
    );
  }
}
