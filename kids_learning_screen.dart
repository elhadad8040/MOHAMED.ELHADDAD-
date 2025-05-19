import 'package:flutter/material.dart';
import '../models/kids_content.dart';
import '../services/kids_content_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_indicator.dart';

/// شاشة التعلم التفاعلي للأطفال
class KidsLearningScreen extends StatefulWidget {
  final KidsContent content;

  const KidsLearningScreen({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  State<KidsLearningScreen> createState() => _KidsLearningScreenState();
}

class _KidsLearningScreenState extends State<KidsLearningScreen> {
  final KidsContentService _kidsService = KidsContentService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<String> _completedActivityIds = [];
  int _currentActivityIndex = 0;
  bool _isContentExpanded = false;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadCompletedActivities();
  }

  /// تحميل الأنشطة المكتملة
  Future<void> _loadCompletedActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final completedIds = await _kidsService.getCompletedActivities(widget.content.id);
      
      if (mounted) {
        setState(() {
          _completedActivityIds = completedIds;
          
          // تحديد النشاط الحالي (أول نشاط غير مكتمل)
          if (widget.content.activities.isNotEmpty) {
            final firstIncompleteIndex = widget.content.activities.indexWhere(
              (activity) => !_completedActivityIds.contains(activity.id),
            );
            
            _currentActivityIndex = firstIncompleteIndex != -1
                ? firstIncompleteIndex
                : 0;
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// تعليم النشاط كمكتمل
  Future<void> _markActivityCompleted(String activityId) async {
    try {
      await _kidsService.markActivityCompleted(widget.content.id, activityId);
      
      if (mounted) {
        setState(() {
          if (!_completedActivityIds.contains(activityId)) {
            _completedActivityIds.add(activityId);
          }
        });
      }
    } catch (e) {
      // معالجة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  /// التنقل إلى النشاط التالي
  void _navigateToNextActivity() {
    if (_currentActivityIndex < widget.content.activities.length - 1) {
      setState(() {
        _currentActivityIndex++;
        _isContentExpanded = false;
      });
    } else {
      // إذا كان هذا آخر نشاط، أظهر رسالة تهنئة
      _showCompletionDialog();
    }
  }

  /// التنقل إلى النشاط السابق
  void _navigateToPreviousActivity() {
    if (_currentActivityIndex > 0) {
      setState(() {
        _currentActivityIndex--;
        _isContentExpanded = false;
      });
    }
  }

  /// عرض مربع حوار الإكمال
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: AppConstants.gamificationColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('أحسنت!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/completion_badge.png',
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              'لقد أكملت جميع الأنشطة في هذا المحتوى! استمر في التعلم واكتشاف المزيد.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('حسناً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.kidsThemeColor,
            ),
            child: const Text('العودة للقائمة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.content.title),
        backgroundColor: AppConstants.kidsThemeColor,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'جاري تحميل المحتوى...')
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppConstants.errorColor,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'حدث خطأ أثناء تحميل المحتوى',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadCompletedActivities,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.kidsThemeColor,
                        ),
                      ),
                    ],
                  ),
                )
              : widget.content.activities.isEmpty
                  ? _buildEmptyActivitiesView()
                  : _buildActivityContent(),
    );
  }

  /// بناء عرض عندما لا تكون هناك أنشطة
  Widget _buildEmptyActivitiesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pending_actions,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أنشطة متاحة لهذا المحتوى',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('العودة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.kidsThemeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء محتوى النشاط
  Widget _buildActivityContent() {
    final currentActivity = widget.content.activities[_currentActivityIndex];
    final isActivityCompleted = _completedActivityIds.contains(currentActivity.id);
    
    return Column(
      children: [
        // شريط التقدم
        Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'النشاط ${_currentActivityIndex + 1} من ${widget.content.activities.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'تم إكمال ${_completedActivityIds.length} من ${widget.content.activities.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  widget.content.activities.length,
                  (index) {
                    final isCompleted = _completedActivityIds.contains(
                      widget.content.activities[index].id,
                    );
                    final isCurrent = index == _currentActivityIndex;
                    
                    return Expanded(
                      child: Container(
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppConstants.kidsThemeColor
                              : isCurrent
                                  ? AppConstants.kidsThemeColor.withOpacity(0.3)
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // محتوى النشاط
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان النشاط
                Text(
                  currentActivity.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                // وصف النشاط
                Text(
                  currentActivity.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 24),
                
                // محتوى النشاط المرئي (صورة، رسوم متحركة، إلخ)
                _buildMediaContent(currentActivity),
                const SizedBox(height: 24),
                
                // محتوى النشاط التفاعلي
                _buildInteractiveContent(currentActivity),
              ],
            ),
          ),
        ),
        
        // أزرار التنقل
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر العودة
              TextButton.icon(
                onPressed: _currentActivityIndex > 0
                    ? _navigateToPreviousActivity
                    : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('السابق'),
              ),
              
              // زر إكمال النشاط
              ElevatedButton.icon(
                onPressed: isActivityCompleted
                    ? _navigateToNextActivity
                    : () async {
                        await _markActivityCompleted(currentActivity.id);
                        _navigateToNextActivity();
                      },
                icon: Icon(
                  isActivityCompleted ? Icons.skip_next : Icons.check,
                ),
                label: Text(
                  isActivityCompleted ? 'التالي' : 'إكمال النشاط',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.kidsThemeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// بناء محتوى الوسائط (صور، فيديو، إلخ)
  Widget _buildMediaContent(ContentActivity activity) {
    // مساحة للصورة أو الفيديو وفقًا لنوع النشاط
    Widget mediaWidget;
    
    switch (activity.activityType) {
      case ActivityType.reading:
        mediaWidget = ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Image.asset(
            activity.mediaUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
        );
        break;
        
      case ActivityType.watching:
        mediaWidget = Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: Image.asset(
                  activity.thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              IconButton(
                onPressed: () {
                  // تشغيل الفيديو
                },
                icon: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ],
          ),
        );
        break;
        
      case ActivityType.listening:
        mediaWidget = Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppConstants.kidsThemeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  image: DecorationImage(
                    image: AssetImage(activity.thumbnailUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اضغط لاستماع للمقطع الصوتي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.kidsThemeColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isAudioPlaying = !_isAudioPlaying;
                            });
                          },
                          icon: Icon(
                            _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                            color: AppConstants.kidsThemeColor,
                            size: 32,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: 0.5,
                            onChanged: (value) {
                              // تغيير موضع الصوت
                            },
                            activeColor: AppConstants.kidsThemeColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        break;
        
      case ActivityType.interaction:
      case ActivityType.quiz:
      case ActivityType.game:
        mediaWidget = ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Image.asset(
            activity.mediaUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
        );
        break;
    }
    
    return mediaWidget;
  }

  /// بناء المحتوى التفاعلي
  Widget _buildInteractiveContent(ContentActivity activity) {
    // استخدام محتوى تفاعلي مختلف وفقًا لنوع النشاط
    switch (activity.activityType) {
      case ActivityType.reading:
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'محتوى القراءة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isContentExpanded = !_isContentExpanded;
                        });
                      },
                      icon: Icon(
                        _isContentExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      tooltip: _isContentExpanded ? 'تصغير' : 'توسيع',
                    ),
                  ],
                ),
                if (_isContentExpanded)
                  Text(
                    activity.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  )
                else
                  Text(
                    '${activity.content.substring(0, activity.content.length > 100 ? 100 : activity.content.length)}${activity.content.length > 100 ? '...' : ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        );
        
      case ActivityType.quiz:
        return _buildQuizContent(activity);
        
      case ActivityType.game:
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                const Text(
                  'لعبة تعليمية',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'اضغط على الزر أدناه للبدء في اللعبة',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // فتح اللعبة
                  },
                  icon: const Icon(Icons.sports_esports),
                  label: const Text('بدء اللعبة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.gamificationColor,
                  ),
                ),
              ],
            ),
          ),
        );
        
      case ActivityType.listening:
        return activity.lyrics.isNotEmpty
            ? Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'كلمات الأنشودة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        activity.lyrics,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(); // إذا لم تكن هناك كلمات
            
      case ActivityType.watching:
      case ActivityType.interaction:
      default:
        return activity.worksheetUrl.isNotEmpty
            ? Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    children: [
                      const Text(
                        'ورقة عمل تفاعلية',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'يمكنك تحميل ورقة العمل أو طباعتها للتطبيق العملي',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // تحميل ورقة العمل
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('تحميل'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.kidsThemeColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              // طباعة ورقة العمل
                            },
                            icon: const Icon(Icons.print),
                            label: const Text('طباعة'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(); // إذا لم تكن هناك ورقة عمل
    }
  }

  /// بناء محتوى اختبار (كويز)
  Widget _buildQuizContent(ContentActivity activity) {
    if (activity.questions.isEmpty) {
      return const SizedBox();
    }
    
    // في التطبيق الفعلي، يمكن استخدام StatefulWidget منفصل للاختبار
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اختبار قصير',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...activity.questions.map((question) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...question.options.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: null, // قيمة محددة
                      onChanged: (value) {
                        // اختيار إجابة
                      },
                      activeColor: AppConstants.kidsThemeColor,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // التحقق من الإجابات
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.kidsThemeColor,
                ),
                child: const Text('تحقق من إجاباتك'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}