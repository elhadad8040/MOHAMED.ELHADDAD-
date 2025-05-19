import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tajweed_rule.dart';
import '../services/tajweed_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_indicator.dart';

/// شاشة عرض تفاصيل قاعدة التجويد
class TajweedRuleDetailsScreen extends StatefulWidget {
  final TajweedRule rule;
  
  const TajweedRuleDetailsScreen({
    Key? key,
    required this.rule,
  }) : super(key: key);

  @override
  State<TajweedRuleDetailsScreen> createState() => _TajweedRuleDetailsScreenState();
}

class _TajweedRuleDetailsScreenState extends State<TajweedRuleDetailsScreen> {
  final TajweedService _tajweedService = TajweedService();
  bool _isLoadingRelated = false;
  List<TajweedRule> _relatedRules = [];
  bool _isPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _loadRelatedRules();
  }
  
  Future<void> _loadRelatedRules() async {
    setState(() {
      _isLoadingRelated = true;
    });
    
    try {
      final relatedRules = await _tajweedService.getRelatedRules(widget.rule.id);
      
      if (mounted) {
        setState(() {
          _relatedRules = relatedRules;
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRelated = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل القواعد المرتبطة: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
  
  Future<void> _playAudioExample() async {
    // هنا سيتم تنفيذ منطق تشغيل المثال الصوتي
    setState(() {
      _isPlaying = true;
    });
    
    // محاكاة تشغيل صوت
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
      
      // اهتزاز عند الانتهاء
      HapticFeedback.mediumImpact();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rule.nameAr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleHeader(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildDescription(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildExample(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildSubRules(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildRelatedRules(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRuleHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Text(
                    widget.rule.category.arabicName,
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Center(
              child: Text(
                widget.rule.nameAr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                widget.rule.nameEn,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            const Divider(),
            const SizedBox(height: AppConstants.paddingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isPlaying ? null : _playAudioExample,
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_isPlaying ? 'جاري التشغيل...' : 'استماع للمثال'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                OutlinedButton.icon(
                  onPressed: () {
                    // مشاركة القاعدة
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الوصف',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: Colors.grey[300]!),
          ),
          width: double.infinity,
          child: Text(
            widget.rule.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مثال',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
          ),
          width: double.infinity,
          child: Text(
            widget.rule.example,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Uthmanic',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubRules() {
    if (widget.rule.subRules.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'القواعد الفرعية',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.rule.subRules.length,
          itemBuilder: (context, index) {
            final subRule = widget.rule.subRules[index];
            return _buildSubRuleCard(subRule);
          },
        ),
      ],
    );
  }
  
  Widget _buildSubRuleCard(TajweedSubRule subRule) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: ExpansionTile(
        title: Text(
          subRule.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          Text(
            subRule.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          const Text(
            'مثال:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
            ),
            width: double.infinity,
            child: Text(
              subRule.example,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Uthmanic',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (subRule.commonErrors.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            const Text(
              'الأخطاء الشائعة:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...subRule.commonErrors.map((error) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppConstants.errorColor,
                    size: 16,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: AppConstants.paddingMedium),
          OutlinedButton.icon(
            onPressed: () {
              // قم بتشغيل المثال الصوتي للقاعدة الفرعية
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('استماع للمثال'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRelatedRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'قواعد مرتبطة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        
        if (_isLoadingRelated)
          const LoadingIndicator(
            message: 'جاري تحميل القواعد المرتبطة...',
            size: 24,
          )
        else if (_relatedRules.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            width: double.infinity,
            child: const Text(
              'لا توجد قواعد مرتبطة',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _relatedRules.length,
              itemBuilder: (context, index) {
                final rule = _relatedRules[index];
                return _buildRelatedRuleCard(rule);
              },
            ),
          ),
      ],
    );
  }
  
  Widget _buildRelatedRuleCard(TajweedRule rule) {
    // تجاهل عرض القاعدة الحالية في القواعد المرتبطة
    if (rule.id == widget.rule.id) {
      return const SizedBox.shrink();
    }
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TajweedRuleDetailsScreen(rule: rule),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
              ),
              child: Text(
                rule.category.arabicName,
                style: TextStyle(
                  fontSize: 10,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              rule.nameAr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              rule.nameEn,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            const Icon(
              Icons.keyboard_arrow_left,
              color: AppConstants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}