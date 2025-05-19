import 'package:flutter/material.dart';
import '../models/prophet_story.dart';
import '../services/prophet_stories_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_indicator.dart';

/// شاشة عرض قصص الأنبياء
class ProphetStoriesScreen extends StatefulWidget {
  const ProphetStoriesScreen({Key? key}) : super(key: key);

  @override
  State<ProphetStoriesScreen> createState() => _ProphetStoriesScreenState();
}

class _ProphetStoriesScreenState extends State<ProphetStoriesScreen> with SingleTickerProviderStateMixin {
  final ProphetStoriesService _storiesService = ProphetStoriesService();
  List<ProphetStory> _allStories = [];
  List<ProphetStory> _filteredStories = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedEra = 'الكل';
  List<String> _eras = ['الكل'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProphetStories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// تحميل قصص الأنبياء
  Future<void> _loadProphetStories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final stories = await _storiesService.getProphetStories();
      
      // استخراج الفترات الزمنية المتوفرة
      final Set<String> erasSet = {'الكل'};
      for (var story in stories) {
        erasSet.add(story.era);
      }
      
      if (mounted) {
        setState(() {
          _allStories = stories;
          _filteredStories = stories;
          _eras = erasSet.toList();
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

  /// تصفية القصص حسب النص المدخل
  void _filterStories() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty && _selectedEra == 'الكل') {
        _filteredStories = _allStories;
      } else {
        _filteredStories = _allStories.where((story) {
          bool matchesSearch = query.isEmpty || 
                              story.prophetNameAr.toLowerCase().contains(query) ||
                              story.prophetNameEn.toLowerCase().contains(query) ||
                              story.title.toLowerCase().contains(query) ||
                              story.description.toLowerCase().contains(query);
          
          bool matchesEra = _selectedEra == 'الكل' || story.era == _selectedEra;
          
          return matchesSearch && matchesEra;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قصص الأنبياء'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.auto_stories),
              text: 'القصص',
            ),
            Tab(
              icon: Icon(Icons.timeline),
              text: 'الخط الزمني',
            ),
          ],
          indicatorColor: AppConstants.storiesThemeColor,
          labelColor: AppConstants.storiesThemeColor,
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'جاري تحميل القصص...')
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
                        'حدث خطأ أثناء تحميل القصص',
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
                        onPressed: _loadProphetStories,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStoriesGridTab(),
                    _buildTimelineTab(),
                  ],
                ),
    );
  }

  /// بناء تبويب شبكة القصص
  Widget _buildStoriesGridTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن قصة...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: AppConstants.paddingMedium,
                  ),
                ),
                onChanged: (_) => _filterStories(),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _eras.length,
                  itemBuilder: (context, index) {
                    final era = _eras[index];
                    final isSelected = era == _selectedEra;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(era),
                        selected: isSelected,
                        selectedColor: AppConstants.storiesThemeColor.withOpacity(0.2),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedEra = era;
                            });
                            _filterStories();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredStories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لم يتم العثور على قصص مطابقة',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredStories.length,
                  itemBuilder: (context, index) {
                    final story = _filteredStories[index];
                    return _buildStoryCard(story);
                  },
                ),
        ),
      ],
    );
  }

  /// بناء بطاقة قصة
  Widget _buildStoryCard(ProphetStory story) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.prophetStoryDetails,
          arguments: story,
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة القصة
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.borderRadius),
                  ),
                  image: DecorationImage(
                    image: AssetImage(story.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.storiesThemeColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          story.era,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // معلومات القصة
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.prophetNameAr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      story.prophetNameEn,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        story.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<int>(
                      future: _storiesService.getStoryProgress(story.id),
                      builder: (context, snapshot) {
                        final progress = snapshot.data ?? 0;
                        final hasProgress = progress > 0;
                        
                        return Row(
                          children: [
                            if (hasProgress) ...[
                              Icon(
                                Icons.bookmark,
                                color: AppConstants.storiesThemeColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'تم القراءة: ${progress + 1}/${story.chapters.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ] else ...[
                              Icon(
                                Icons.play_circle_filled,
                                color: AppConstants.storiesThemeColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ابدأ القراءة',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              '${story.chapters.length} فصول',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء تبويب الخط الزمني
  Widget _buildTimelineTab() {
    return FutureBuilder<List<ProphetStory>>(
      future: _storiesService.getStoriesTimeline(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator(message: 'جاري تحميل الخط الزمني...');
        }
        
        if (snapshot.hasError) {
          return Center(
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
                  'حدث خطأ أثناء تحميل الخط الزمني',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
          );
        }
        
        final stories = snapshot.data ?? [];
        
        if (stories.isEmpty) {
          return Center(
            child: Text(
              'لا توجد قصص متاحة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final story = stories[index];
            final isFirst = index == 0;
            final isLast = index == stories.length - 1;
            
            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.prophetStoryDetails,
                  arguments: story,
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // خط الزمن
                  SizedBox(
                    width: 60,
                    child: Column(
                      children: [
                        Text(
                          '${story.timelinePeriodStart < 0 ? "ق.م" : "م"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${story.timelinePeriodStart.abs()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 2,
                          height: 160,
                          color: AppConstants.storiesThemeColor,
                        ),
                      ],
                    ),
                  ),
                  // محتوى القصة
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.prophetNameAr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.era,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                              child: Image.asset(
                                story.imageUrl,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              story.description,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}