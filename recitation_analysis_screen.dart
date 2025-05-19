import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/recitation_bloc.dart';
import '../models/quran_ayah.dart';
import '../models/recitation_analysis.dart';
import '../widgets/error_highlight.dart';

class RecitationAnalysisScreen extends StatefulWidget {
  final String? audioFilePath;
  final String? currentRecitationId;
  final int selectedSurahId;
  final int selectedAyahId;
  
  const RecitationAnalysisScreen({
    Key? key,
    this.audioFilePath,
    this.currentRecitationId,
    required this.selectedSurahId,
    required this.selectedAyahId,
  }) : super(key: key);

  @override
  State<RecitationAnalysisScreen> createState() => _RecitationAnalysisScreenState();
}

class _RecitationAnalysisScreenState extends State<RecitationAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RecitationAnalysis? _analysisResult;
  bool _isAnalyzing = false;
  String? _audioFilePath;
  String? _currentRecitationId;
  late int _selectedSurahId;
  late int _selectedAyahId;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _audioFilePath = widget.audioFilePath;
    _currentRecitationId = widget.currentRecitationId;
    _selectedSurahId = widget.selectedSurahId;
    _selectedAyahId = widget.selectedAyahId;
    
    if (_audioFilePath != null && _currentRecitationId != null) {
      _analyzeRecitation();
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل التلاوة'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'التلاوة'),
            Tab(text: 'التحليل'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecitationTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }
  
  // بناء علامة تبويب التلاوة
  Widget _buildRecitationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectedAyah(),
          const SizedBox(height: 24),
          if (_audioFilePath != null)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التسجيل الصوتي:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // هنا يمكن إضافة مشغل الصوت
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _isAnalyzing
                            ? null
                            : _analyzeRecitation,
                        icon: const Icon(Icons.analytics),
                        label: Text(_isAnalyzing ? 'جاري التحليل...' : 'تحليل التلاوة'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(
              child: Text('لم يتم تسجيل تلاوة بعد'),
            ),
        ],
      ),
    );
  }
  
  // بناء علامة تبويب التحليل
  Widget _buildAnalysisTab() {
    if (_analysisResult == null) {
      return const Center(
        child: Text('لم يتم تحليل التلاوة بعد'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisOverview(),
          const SizedBox(height: 24),
          _buildErrorsList(),
          const SizedBox(height: 24),
          _buildCorrectRulesList(),
          const SizedBox(height: 24),
          _buildMakhaarijDiagnosis(),
        ],
      ),
    );
  }
  
  // بناء عرض الآية المختارة
  Widget _buildSelectedAyah() {
    final selectedAyah = context.select((RecitationBloc bloc) => 
      bloc.state.quranData.ayahs.firstWhere(
        (ayah) => ayah.number == _selectedAyahId,
        orElse: () => QuranAyah(
          id: '',
          surahId: _selectedSurahId,
          number: _selectedAyahId,
          text: 'جاري تحميل الآية...',
          page: 0,
          juz: 0,
          hizb: 0,
          sajda: false,
        ),
      )
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الآية المختارة:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          width: double.infinity,
          child: Text(
            '${selectedAyah.text} ﴿${_selectedAyahId}﴾',
            style: const TextStyle(
              fontSize: 22,
              fontFamily: 'Uthmanic',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // عرض نظرة عامة على التحليل
  Widget _buildAnalysisOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ملخص التحليل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildScoreIndicator(_analysisResult!.overallScore),
              ],
            ),
            const SizedBox(height: 16),
            _buildScoreRow('دقة النطق', _analysisResult!.pronunciationAccuracy),
            const SizedBox(height: 8),
            _buildScoreRow('دقة النص', _analysisResult!.textAccuracy),
            const SizedBox(height: 8),
            _buildScoreRow('دقة الإيقاع', _analysisResult!.rhythmAccuracy),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  'الأخطاء',
                  _analysisResult!.errors.length.toString(),
                  Colors.red[100]!,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'القواعد الصحيحة',
                  _analysisResult!.correctRules.length.toString(),
                  Colors.green[100]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بناء صف الدرجة
  Widget _buildScoreRow(String label, double score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Text('${(score * 100).toStringAsFixed(1)}%'),
            const SizedBox(width: 8),
            Container(
              width: 100,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[300],
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: score,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getScoreColor(score),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // بناء مؤشر الدرجة
  Widget _buildScoreIndicator(int score) {
    Color color;
    String label;

    if (score >= 90) {
      color = Colors.green;
      label = 'ممتاز';
    } else if (score >= 75) {
      color = Colors.blue;
      label = 'جيد جداً';
    } else if (score >= 60) {
      color = Colors.amber;
      label = 'جيد';
    } else if (score >= 40) {
      color = Colors.orange;
      label = 'مقبول';
    } else {
      color = Colors.red;
      label = 'ضعيف';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Text(
            '$score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // بناء بطاقة إحصائية
  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // بناء قائمة الأخطاء
  Widget _buildErrorsList() {
    if (_analysisResult!.errors.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'لم يتم اكتشاف أخطاء. أحسنت!',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الأخطاء المكتشفة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _analysisResult!.errors.length,
          itemBuilder: (context, index) {
            final error = _analysisResult!.errors[index];
            return ErrorHighlight(
              error: error,
              onTap: () {
                // عرض تفاصيل الخطأ
                _showErrorDetails(error);
              },
            );
          },
        ),
      ],
    );
  }

  // بناء قائمة القواعد الصحيحة
  Widget _buildCorrectRulesList() {
    if (_analysisResult!.correctRules.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أحكام التجويد الصحيحة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _analysisResult!.correctRules.length,
          itemBuilder: (context, index) {
            final rule = _analysisResult!.correctRules[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.green[50],
              child: ListTile(
                title: Text(rule.type),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rule.description),
                    const SizedBox(height: 4),
                    Text(
                      rule.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Uthmanic',
                      ),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: rule.quality / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          Colors.green,
                        ),
                      ),
                      Text('${rule.quality}'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // بناء تشخيص مخارج الحروف
  Widget _buildMakhaarijDiagnosis() {
    if (_analysisResult!.makhaarijDiagnosis.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تشخيص مخارج الحروف',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _analysisResult!.makhaarijDiagnosis.entries.map((entry) {
                final letterGroup = entry.key;
                final score = (entry.value as num).toDouble();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMakhrajGroupName(letterGroup),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('${(score * 100).toStringAsFixed(1)}%'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey[300],
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerRight,
                                widthFactor: score,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(score),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // الحصول على لون الدرجة حسب القيمة
  Color _getScoreColor(double score) {
    if (score >= 0.9) {
      return Colors.green;
    } else if (score >= 0.75) {
      return Colors.lightGreen;
    } else if (score >= 0.6) {
      return Colors.amber;
    } else if (score >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // الحصول على اسم مجموعة المخرج
  String _getMakhrajGroupName(String key) {
    final Map<String, String> makhrajGroups = {
      'throat': 'مخارج الحلق',
      'tongue': 'مخارج اللسان',
      'lips': 'مخارج الشفتين',
      'nasality': 'مخارج الأنف',
      'emphatic': 'حروف الإطباق',
      'whistling': 'حروف الصفير',
    };

    return makhrajGroups[key] ?? key;
  }

  // عرض تفاصيل الخطأ
  void _showErrorDetails(error) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تفاصيل خطأ: ${error.ruleName}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('النوع: ${error.type}'),
                const SizedBox(height: 8),
                Text('الوصف: ${error.description}'),
                const SizedBox(height: 8),
                Text('الشدة: ${error.severity}'),
                const SizedBox(height: 8),
                Text('التوقيت: ${error.startTime.toStringAsFixed(2)} - ${error.endTime.toStringAsFixed(2)} ثانية'),
                const SizedBox(height: 16),
                const Text(
                  'النص:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(int.parse(
                      error.severityColor.substring(1),
                      radix: 16,
                    ) | 0xFF000000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    error.text,
                    style: const TextStyle(
                      fontFamily: 'Uthmanic',
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'اقتراح التصحيح:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(error.suggestion),
              ],
            ),
          ),
          actions: [
            if (error.lessonReference != null)
              TextButton(
                onPressed: () {
                  // التوجيه إلى درس شرح الحكم
                  Navigator.pop(context);
                  // يمكن إضافة التوجيه هنا
                },
                child: const Text('عرض الدرس'),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  // تحليل التلاوة
  void _analyzeRecitation() {
    if (_audioFilePath == null || _currentRecitationId == null) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    context.read<RecitationBloc>().add(
      AnalyzeRecitation(
        recitationId: _currentRecitationId!,
        audioFile: File(_audioFilePath!),
      ),
    );

    context.read<RecitationBloc>().stream.listen((state) {
      if (state is RecitationAnalyzed &&
          state.recitationId == _currentRecitationId) {
        setState(() {
          _analysisResult = state.analysis;
          _isAnalyzing = false;
          _tabController.animateTo(1); // الانتقال إلى علامة تبويب التحليل
        });
      } else if (state is RecitationError) {
        setState(() {
          _isAnalyzing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}
