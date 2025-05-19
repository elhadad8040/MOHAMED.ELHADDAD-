import 'package:flutter/material.dart';
import '../models/kids_content.dart';
import '../services/kids_content_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_indicator.dart';

/// شاشة ركن الأطفال
class KidsZoneScreen extends StatefulWidget {
  const KidsZoneScreen({Key? key}) : super(key: key);

  @override
  State<KidsZoneScreen> createState() => _KidsZoneScreenState();
}

class _KidsZoneScreenState extends State<KidsZoneScreen> with SingleTickerProviderStateMixin {
  final KidsContentService _kidsService = KidsContentService();
  bool _isLoading = true;
  String _errorMessage = '';
  late TabController _tabController;
  AgeGroup _selectedAgeGroup = AgeGroup.preschool;
  List<KidsContent> _allContent = [];
  List<KidsGame> _allGames = [];
  List<KidsAchievement> _achievements = [];
  List<String> _unlockedAchievementIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// تحميل البيانات
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // تحميل المحتوى والألعاب والإنجازات
      final content = await _kidsService.getKidsContent(ageGroup: _selectedAgeGroup);
      final games = await _kidsService.getKidsGames(ageGroup: _selectedAgeGroup);
      final achievements = await _kidsService.getKidsAchievements();
      final unlockedIds = await _kidsService.getUnlockedAchievements();
      
      if (mounted) {
        setState(() {
          _allContent = content;
          _allGames = games;
          _achievements = achievements;
          _unlockedAchievementIds = unlockedIds;
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

  /// تغيير الفئة العمرية
  void _changeAgeGroup(AgeGroup ageGroup) {
    setState(() {
      _selectedAgeGroup = ageGroup;
    });
    
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ركن الأطفال'),
        backgroundColor: AppConstants.kidsThemeColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'محتوى تعليمي'),
            Tab(text: 'ألعاب'),
            Tab(text: 'إنجازاتي'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.family_restroom),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.familyMode);
            },
            tooltip: 'وضع العائلة',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'جاري تحميل المحتوى التعليمي...')
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
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.kidsThemeColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // اختيار الفئة العمرية
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الفئة العمرية:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: AgeGroup.values.map((ageGroup) {
                                  final isSelected = ageGroup == _selectedAgeGroup;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(ageGroup.toArabicString()),
                                      selected: isSelected,
                                      selectedColor: AppConstants.kidsThemeColor.withOpacity(0.2),
                                      onSelected: (selected) {
                                        if (selected) {
                                          _changeAgeGroup(ageGroup);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // محتوى التبويبات
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildContentTab(),
                          _buildGamesTab(),
                          _buildAchievementsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  /// بناء تبويب المحتوى التعليمي
  Widget _buildContentTab() {
    if (_allContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد محتوى متاح لهذه الفئة العمرية',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _allContent.length,
      itemBuilder: (context, index) {
        final content = _allContent[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.kidsLearning,
                arguments: content,
              );
            },
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المحتوى
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.borderRadius),
                  ),
                  child: Stack(
                    children: [
                      Image.asset(
                        content.imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      if (content.isPremium)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.gamificationColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'محتوى مميز',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getContentTypeIcon(content.contentType),
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                content.contentType.toArabicString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // معلومات المحتوى
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      
                      // الأنشطة والتقدم
                      FutureBuilder<List<String>>(
                        future: _kidsService.getCompletedActivities(content.id),
                        builder: (context, snapshot) {
                          final completedActivities = snapshot.data ?? [];
                          final totalActivities = content.activities.length;
                          final completedCount = completedActivities.length;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'الأنشطة (${completedCount}/${totalActivities})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (completedCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppConstants.kidsThemeColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: AppConstants.kidsThemeColor,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            completedCount == totalActivities
                                                ? 'مكتمل'
                                                : 'قيد التقدم',
                                            style: TextStyle(
                                              color: AppConstants.kidsThemeColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
                                child: LinearProgressIndicator(
                                  value: totalActivities > 0
                                      ? completedCount / totalActivities
                                      : 0,
                                  backgroundColor: Colors.grey[200],
                                  color: AppConstants.kidsThemeColor,
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.kidsLearning,
                                        arguments: content,
                                      );
                                    },
                                    icon: const Icon(Icons.play_arrow),
                                    label: Text(
                                      completedCount > 0
                                          ? 'متابعة التعلم'
                                          : 'ابدأ التعلم',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppConstants.kidsThemeColor,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () {
                                      // مشاركة المحتوى
                                    },
                                    icon: const Icon(Icons.share),
                                    label: const Text('مشاركة'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// بناء تبويب الألعاب
  Widget _buildGamesTab() {
    if (_allGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.games,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد ألعاب متاحة لهذه الفئة العمرية',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // فلترة الألعاب
        Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'تصفية: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                ...GameType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.toArabicString()),
                      selected: false,
                      onSelected: (selected) {
                        // تطبيق تصفية على الألعاب
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        
        // قائمة الألعاب
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _allGames.length,
            itemBuilder: (context, index) {
              final game = _allGames[index];
              
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.kidsGames,
                      arguments: game,
                    );
                  },
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صورة اللعبة
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppConstants.borderRadius),
                        ),
                        child: Stack(
                          children: [
                            Image.asset(
                              game.imageUrl,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            // علامة مستوى الصعوبة
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(game.difficulty),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  game.difficulty.toArabicString(),
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
                      
                      // معلومات اللعبة
                      Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              game.gameType.toArabicString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // أعلى نتيجة
                            FutureBuilder<int>(
                              future: _kidsService.getGameHighScore(game.id),
                              builder: (context, snapshot) {
                                final highScore = snapshot.data ?? 0;
                                
                                return Row(
                                  children: [
                                    Icon(
                                      highScore > 0
                                          ? Icons.emoji_events
                                          : Icons.play_circle_filled,
                                      color: highScore > 0
                                          ? AppConstants.gamificationColor
                                          : AppConstants.kidsThemeColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      highScore > 0
                                          ? 'أعلى نتيجة: $highScore'
                                          : 'العب الآن',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: highScore > 0
                                            ? AppConstants.gamificationColor
                                            : AppConstants.kidsThemeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              },
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
      ],
    );
  }

  /// بناء تبويب الإنجازات
  Widget _buildAchievementsTab() {
    if (_achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد إنجازات متاحة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    // فرز الإنجازات: المفتوحة أولاً ثم المغلقة
    final unlockedAchievements = _achievements
        .where((ach) => _unlockedAchievementIds.contains(ach.id))
        .toList();
    final lockedAchievements = _achievements
        .where((ach) => !_unlockedAchievementIds.contains(ach.id))
        .toList();
    final sortedAchievements = [...unlockedAchievements, ...lockedAchievements];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: sortedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = sortedAchievements[index];
        final isUnlocked = _unlockedAchievementIds.contains(achievement.id);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: isUnlocked ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
            leading: SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                children: [
                  if (isUnlocked)
                    Image.asset(
                      achievement.imageUrl,
                      width: 60,
                      height: 60,
                    )
                  else
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.saturation,
                      ),
                      child: Image.asset(
                        achievement.imageUrl,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  if (!isUnlocked)
                    Positioned.fill(
                      child: Icon(
                        Icons.lock,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
            title: Text(
              achievement.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.black : Colors.grey[600],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: isUnlocked ? Colors.grey[700] : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                if (!isUnlocked && !achievement.isSecret) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'كيفية الحصول عليه: ${achievement.unlockCriteria}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isUnlocked) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'تم الحصول عليه!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// الحصول على أيقونة نوع المحتوى
  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.story:
        return Icons.auto_stories;
      case ContentType.animation:
        return Icons.movie;
      case ContentType.song:
        return Icons.music_note;
      case ContentType.interactiveLesson:
        return Icons.school;
      case ContentType.quiz:
        return Icons.quiz;
      case ContentType.challenge:
        return Icons.extension;
    }
  }

  /// الحصول على لون مستوى الصعوبة
  Color _getDifficultyColor(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return Colors.green;
      case GameDifficulty.medium:
        return Colors.orange;
      case GameDifficulty.hard:
        return Colors.red;
    }
  }
}