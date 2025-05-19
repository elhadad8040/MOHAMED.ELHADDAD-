import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  late TabController _tabController;
  UserProfile? _userProfile;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // استخدم معرف مستخدم تجريبي لأغراض التطوير (في المنتج النهائي سيتم استخدام المصادقة)
      final userProfile = await _userService.getUserProfile('user123');
      
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل الملف الشخصي: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'جاري تحميل الملف الشخصي...'),
      );
    }
    
    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
        ),
        body: const Center(
          child: Text('لا يمكن تحميل الملف الشخصي، يرجى المحاولة لاحقاً'),
        ),
      );
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _buildProfileHeader(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'الملف الشخصي'),
                  Tab(text: 'الإنجازات'),
                  Tab(text: 'الإحصائيات'),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildAchievementsTab(),
                _buildStatsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _userProfile!.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppConstants.primaryColor,
                AppConstants.secondaryColor,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: _userProfile?.photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        _userProfile!.photoUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 50,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 50,
                      color: AppConstants.primaryColor,
                    ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
      ],
    );
  }
  
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('المستوى', _userProfile!.level.toString()),
          _buildStatItem('النقاط', _userProfile!.points.toString()),
          _buildStatItem(
            'التلاوات',
            _userProfile!.recitationStats.totalRecitations.toString(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoTab() {
    final learningPath = _userProfile!.learningPath;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معلومات المستخدم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildInfoItem('البريد الإلكتروني', _userProfile!.email),
          const Divider(),
          
          const SizedBox(height: AppConstants.paddingMedium),
          const Text(
            'مسار التعلم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildInfoItem('المستوى الحالي', learningPath.currentLevel),
          _buildInfoItem('الهدف القادم', learningPath.nextMilestone),
          
          const SizedBox(height: AppConstants.paddingMedium),
          LinearProgressIndicator(
            value: learningPath.progressPercentage,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppConstants.primaryColor,
            ),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'التقدم: ${(learningPath.progressPercentage * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          const Text(
            'الدروس المكتملة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          learningPath.completedLessons.isEmpty
            ? Text(
                'لم تكمل أي درس بعد',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: learningPath.completedLessons
                    .map((lesson) => _buildLessonItem(lesson, true))
                    .toList(),
              ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          const Text(
            'الدروس المتاحة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: learningPath.unlockedLessons
                .map((lesson) => _buildLessonItem(lesson, false))
                .toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLessonItem(String lesson, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.play_circle_outline,
            color: isCompleted ? Colors.green : AppConstants.primaryColor,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              lesson,
              style: TextStyle(
                color: isCompleted ? Colors.grey[600] : Colors.black87,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementsTab() {
    final achievements = _userProfile!.achievements;
    
    return achievements.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'لم تحصل على أي إنجازات بعد',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'استمر في التلاوة وممارسة التجويد لكسب الإنجازات!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: AppConstants.paddingMedium,
              mainAxisSpacing: AppConstants.paddingMedium,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementItem(achievement);
            },
          );
  }
  
  Widget _buildAchievementItem(Achievement achievement) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              achievement.iconPath,
              width: 64,
              height: 64,
              errorBuilder: (_, __, ___) => Icon(
                Icons.emoji_events,
                size: 64,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              achievement.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              achievement.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall / 2,
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Text(
                '+${achievement.pointsAwarded} نقطة',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsTab() {
    final stats = _userProfile!.recitationStats;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات التلاوة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          
          // بطاقات الإحصائيات الرئيسية
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي التلاوات',
                  stats.totalRecitations.toString(),
                  Icons.record_voice_over,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: _buildStatCard(
                  'التلاوات المثالية',
                  stats.perfectRecitations.toString(),
                  Icons.star,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'الوقت الإجمالي',
                  '${stats.totalMinutesRecited} دقيقة',
                  Icons.timer,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: _buildStatCard(
                  'معدل النجاح',
                  stats.totalRecitations > 0
                      ? '${((stats.perfectRecitations / stats.totalRecitations) * 100).toStringAsFixed(1)}%'
                      : '0%',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          const Text(
            'أكثر الأخطاء شيوعاً',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          
          // عرض أكثر أنواع الأخطاء شيوعاً
          stats.errorTypeFrequency.isEmpty
              ? Text(
                  'لم يتم تسجيل أي أخطاء بعد',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Column(
                  children: stats.errorTypeFrequency.entries
                      .toList()
                      .sorted((a, b) => b.value.compareTo(a.value))
                      .take(5)
                      .map((entry) => _buildErrorFrequencyItem(
                            entry.key,
                            entry.value,
                          ))
                      .toList(),
                ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          const Text(
            'دقة قواعد التجويد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          
          // عرض دقة قواعد التجويد
          stats.tajweedRuleAccuracy.isEmpty
              ? Text(
                  'لم يتم تسجيل أي قياسات للدقة بعد',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Column(
                  children: stats.tajweedRuleAccuracy.entries
                      .map((entry) => _buildAccuracyItem(
                            entry.key,
                            entry.value,
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 30,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorFrequencyItem(String errorType, int frequency) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppConstants.errorColor,
            size: 16,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(errorType),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingSmall,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppConstants.errorColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
            ),
            child: Text(
              frequency.toString(),
              style: const TextStyle(
                color: AppConstants.errorColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccuracyItem(String ruleName, double accuracy) {
    final percentage = (accuracy * 100).toInt();
    Color color;
    
    if (percentage >= 80) {
      color = Colors.green;
    } else if (percentage >= 60) {
      color = Colors.orange;
    } else {
      color = AppConstants.errorColor;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(ruleName),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall / 2),
          LinearProgressIndicator(
            value: accuracy,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}

extension ListExtension<T> on List<T> {
  List<T> sorted(Comparator<T> compare) {
    final List<T> copy = List.from(this);
    copy.sort(compare);
    return copy;
  }
}