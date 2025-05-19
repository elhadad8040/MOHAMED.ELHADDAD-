import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prophet_story.dart';
import '../services/prophet_stories_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_indicator.dart';

/// شاشة تفاصيل قصة نبي
class ProphetStoryDetailsScreen extends StatefulWidget {
  final ProphetStory story;

  const ProphetStoryDetailsScreen({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  State<ProphetStoryDetailsScreen> createState() => _ProphetStoryDetailsScreenState();
}

class _ProphetStoryDetailsScreenState extends State<ProphetStoryDetailsScreen> with SingleTickerProviderStateMixin {
  final ProphetStoriesService _storiesService = ProphetStoriesService();
  late TabController _tabController;
  int _currentChapterIndex = 0;
  bool _isLoading = false;
  bool _isPlaying = false;
  List<ProphetStory> _relatedStories = [];
  bool _isLoadingRelated = false;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStoryProgress();
    _loadRelatedStories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// تحميل تقدم القراءة
  Future<void> _loadStoryProgress() async {
    final progress = await _storiesService.getStoryProgress(widget.story.id);
    
    if (mounted) {
      setState(() {
        _currentChapterIndex = progress;
      });
      
      if (widget.story.chapters.isNotEmpty) {
        _pageController = PageController(initialPage: _currentChapterIndex);
      }
    }
  }

  /// تحميل القصص المرتبطة
  Future<void> _loadRelatedStories() async {
    setState(() {
      _isLoadingRelated = true;
    });

    try {
      final relatedStories = await _storiesService.getRelatedStories(widget.story.id);
      
      if (mounted) {
        setState(() {
          _relatedStories = relatedStories;
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
            content: Text('حدث خطأ أثناء تحميل القصص المرتبطة: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  /// تشغيل الصوت
  Future<void> _playAudio() async {
    setState(() {
      _isPlaying = true;
    });
    
    // محاكاة تشغيل الصوت
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
      
      // اهتزاز بسيط عند انتهاء التشغيل
      HapticFeedback.mediumImpact();
    }
  }

  /// تغيير الفصل
  void _changeChapter(int index) {
    if (index >= 0 && index < widget.story.chapters.length) {
      setState(() {
        _currentChapterIndex = index;
      });
      
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // حفظ تقدم القراءة
      _storiesService.saveStoryProgress(widget.story.id, index);
    }
  }

  /// تنزيل القصة للقراءة بدون اتصال
  Future<void> _downloadForOffline() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _storiesService.downloadStoryForOffline(widget.story.id);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result
                  ? 'تم تنزيل القصة بنجاح للقراءة بدون اتصال'
                  : 'فشل تنزيل القصة',
            ),
            backgroundColor:
                result ? AppConstants.successColor : AppConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تنزيل القصة: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.story.prophetNameAr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // صورة الخلفية
                    Image.asset(
                      widget.story.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    // طبقة التعتيم
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // معلومات القصة
                    Positioned(
                      bottom: 60,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.storiesThemeColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.story.era,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.story.prophetNameEn,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'القصة'),
                  Tab(text: 'الدروس'),
                  Tab(text: 'الخريطة'),
                ],
                indicatorColor: AppConstants.storiesThemeColor,
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.volume_up,
                  ),
                  onPressed: _isPlaying ? null : _playAudio,
                  tooltip: 'استماع للقصة',
                ),
                IconButton(
                  icon: const Icon(Icons.file_download),
                  onPressed: _isLoading ? null : _downloadForOffline,
                  tooltip: 'تنزيل للقراءة بدون اتصال',
                ),
              ],
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStoryTab(),
            _buildLessonsTab(),
            _buildMapTab(),
          ],
        ),
      ),
    );
  }

  /// بناء تبويب القصة
  Widget _buildStoryTab() {
    if (widget.story.chapters.isEmpty) {
      return Center(
        child: Text(
          'لا توجد فصول متاحة لهذه القصة',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return Column(
      children: [
        // شريط التنقل بين الفصول
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.story.chapters.length,
            itemBuilder: (context, index) {
              final isActive = index == _currentChapterIndex;
              
              return GestureDetector(
                onTap: () => _changeChapter(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppConstants.storiesThemeColor
                        : AppConstants.storiesThemeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'الفصل ${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppConstants.storiesThemeColor,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // محتوى الفصول
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.story.chapters.length,
            onPageChanged: _changeChapter,
            itemBuilder: (context, index) {
              final chapter = widget.story.chapters[index];
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان الفصل
                    Text(
                      chapter.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppConstants.storiesThemeColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    
                    // صورة الفصل
                    if (chapter.imageUrl.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingMedium),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        child: Image.asset(
                          chapter.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    
                    // محتوى الفصل
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      chapter.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                      ),
                    ),
                    
                    // الآيات القرآنية
                    if (chapter.quranVerses.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingLarge),
                      const Text(
                        'الآيات القرآنية',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppConstants.storiesThemeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          border: Border.all(
                            color: AppConstants.storiesThemeColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: chapter.quranVerses.map((verse) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.format_quote,
                                    color: AppConstants.storiesThemeColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      verse,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    
                    // الأحداث المهمة
                    if (chapter.events.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingLarge),
                      const Text(
                        'الأحداث المهمة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: chapter.events.length,
                        itemBuilder: (context, eventIndex) {
                          final event = chapter.events[eventIndex];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppConstants.paddingMedium),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // صورة الحدث
                                  if (event.imageUrl.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
                                      child: Image.asset(
                                        event.imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    
                                  const SizedBox(width: AppConstants.paddingMedium),
                                  
                                  // وصف الحدث
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                event.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppConstants.storiesThemeColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${event.year < 0 ? "ق.م" : "م"} ${event.year.abs()}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppConstants.storiesThemeColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          event.description,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    
                    // أزرار التنقل
                    const SizedBox(height: AppConstants.paddingLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentChapterIndex > 0)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('السابق'),
                            onPressed: () => _changeChapter(_currentChapterIndex - 1),
                          )
                        else
                          const SizedBox.shrink(),
                          
                        if (_currentChapterIndex < widget.story.chapters.length - 1)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('التالي'),
                            onPressed: () => _changeChapter(_currentChapterIndex + 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.storiesThemeColor,
                              foregroundColor: Colors.white,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                    
                    // القصص المرتبطة
                    const SizedBox(height: AppConstants.paddingLarge),
                    const Text(
                      'قصص مرتبطة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    _isLoadingRelated
                        ? const LoadingIndicator(
                            message: 'جاري تحميل القصص المرتبطة...',
                            size: 24,
                          )
                        : _relatedStories.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                ),
                                width: double.infinity,
                                child: const Text(
                                  'لا توجد قصص مرتبطة',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _relatedStories.length,
                                  itemBuilder: (context, i) {
                                    final relatedStory = _relatedStories[i];
                                    
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProphetStoryDetailsScreen(
                                              story: relatedStory,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 140,
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // صورة القصة
                                            ClipRRect(
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(AppConstants.borderRadius),
                                              ),
                                              child: Image.asset(
                                                relatedStory.imageUrl,
                                                height: 100,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            
                                            // معلومات القصة
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    relatedStory.prophetNameAr,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    relatedStory.era,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.arrow_forward,
                                                        color: AppConstants.storiesThemeColor,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'قراءة القصة',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: AppConstants.storiesThemeColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              
                    const SizedBox(height: AppConstants.paddingLarge),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// بناء تبويب الدروس
  Widget _buildLessonsTab() {
    if (widget.story.lessons.isEmpty) {
      return Center(
        child: Text(
          'لا توجد دروس متاحة لهذه القصة',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: widget.story.lessons.length,
      itemBuilder: (context, index) {
        final lesson = widget.story.lessons[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
            leading: CircleAvatar(
              backgroundColor: AppConstants.storiesThemeColor,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              lesson,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء تبويب الخريطة
  Widget _buildMapTab() {
    if (widget.story.locations.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مواقع جغرافية متاحة لهذه القصة',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return Stack(
      children: [
        // خريطة تخيلية
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[200],
          child: Center(
            child: const Text(
              'سيتم إضافة خريطة تفاعلية هنا',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        
        // قائمة المواقع
        DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.1,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.story.locations.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'المواقع الجغرافية (${widget.story.locations.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final location = widget.story.locations[index - 1];
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        location.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      location.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          location.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppConstants.storiesThemeColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'الموقع الحالي: ${location.currentName}, ${location.country}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      // عرض تفاصيل الموقع عند النقر
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}