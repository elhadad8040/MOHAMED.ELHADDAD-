import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// شبكة ميزات الصفحة الرئيسية
class HomeFeaturesGrid extends StatelessWidget {
  const HomeFeaturesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // قائمة الميزات
    final features = [
      _FeatureItem(
        title: 'تحليل التلاوة',
        description: 'سجّل تلاوتك واحصل على تحليل بالأخطاء والتحسينات',
        icon: Icons.mic,
        color: AppConstants.primaryColor,
        route: '/recitation',
      ),
      _FeatureItem(
        title: 'قواعد التجويد',
        description: 'تعلم قواعد التجويد بطريقة سهلة وتفاعلية',
        icon: Icons.menu_book,
        color: AppConstants.secondaryColor,
        route: AppRoutes.tajweedRules,
      ),
      _FeatureItem(
        title: 'قصص الأنبياء',
        description: 'استكشف قصص الأنبياء والدروس المستفادة منها',
        icon: Icons.auto_stories,
        color: Colors.indigo,
        route: AppRoutes.prophetStories,
      ),
      _FeatureItem(
        title: 'ركن الأطفال',
        description: 'محتوى تعليمي وألعاب تفاعلية للأطفال',
        icon: Icons.child_care,
        color: AppConstants.kidsThemeColor,
        route: AppRoutes.kidsZone,
      ),
      _FeatureItem(
        title: 'اختبر معلوماتك',
        description: 'اختبارات متنوعة لقياس معرفتك بالقرآن الكريم',
        icon: Icons.quiz,
        color: AppConstants.accentColor,
        route: '/quiz',
      ),
      _FeatureItem(
        title: 'الإحصائيات والتقدم',
        description: 'تتبع تقدمك في تلاوة القرآن الكريم',
        icon: Icons.insert_chart,
        color: Colors.teal,
        route: '/statistics',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, feature.route);
            },
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: feature.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      feature.icon,
                      color: feature.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feature.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// عنصر ميزة واحدة في الشبكة
class _FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  _FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
