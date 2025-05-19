import 'package:flutter/material.dart';
import '../models/tajweed_rule.dart';
import '../services/tajweed_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_indicator.dart';

class TajweedRulesScreen extends StatefulWidget {
  const TajweedRulesScreen({Key? key}) : super(key: key);

  @override
  State<TajweedRulesScreen> createState() => _TajweedRulesScreenState();
}

class _TajweedRulesScreenState extends State<TajweedRulesScreen> with SingleTickerProviderStateMixin {
  final TajweedService _tajweedService = TajweedService();
  late TabController _tabController;
  Map<TajweedCategory, List<TajweedRule>> _rulesByCategory = {};
  List<TajweedRule> _allRules = [];
  List<TajweedRule> _filteredRules = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadTajweedRules();
    _tabController = TabController(
      length: TajweedCategory.values.length,
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTajweedRules() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // تحميل قواعد التجويد مصنفة حسب الفئة
      final rulesByCategory = await _tajweedService.getTajweedRulesByCategory();
      final allRules = await _tajweedService.getAllTajweedRules();
      
      if (mounted) {
        setState(() {
          _rulesByCategory = rulesByCategory;
          _allRules = allRules;
          _filteredRules = allRules;
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
            content: Text('حدث خطأ أثناء تحميل قواعد التجويد: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
  
  void _filterRules(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRules = _allRules;
      } else {
        _filteredRules = _allRules.where((rule) {
          final nameAr = rule.nameAr.toLowerCase();
          final nameEn = rule.nameEn.toLowerCase();
          final description = rule.description.toLowerCase();
          final searchLower = query.toLowerCase();
          
          return nameAr.contains(searchLower) || 
                 nameEn.contains(searchLower) || 
                 description.contains(searchLower);
        }).toList();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قواعد التجويد'),
        bottom: _isLoading ? null : TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: TajweedCategory.values.map((category) {
            return Tab(
              text: category.arabicName,
            );
          }).toList(),
        ),
      ),
      body: _isLoading 
        ? const LoadingIndicator(message: 'جاري تحميل قواعد التجويد...')
        : Column(
            children: [
              // قسم البحث
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن قاعدة تجويد...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: AppConstants.paddingSmall,
                    ),
                  ),
                  onChanged: _filterRules,
                ),
              ),
              
              // عرض نتائج البحث إذا كان هناك بحث
              if (_searchQuery.isNotEmpty)
                Expanded(
                  child: _buildSearchResults(),
                )
              else
                // عرض القواعد حسب التصنيف
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: TajweedCategory.values.map((category) {
                      return _buildRulesList(
                        _rulesByCategory[category] ?? [],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
    );
  }
  
  Widget _buildSearchResults() {
    if (_filteredRules.isEmpty) {
      return Center(
        child: Text(
          'لا توجد نتائج تطابق "$_searchQuery"',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
    
    return _buildRulesList(_filteredRules);
  }
  
  Widget _buildRulesList(List<TajweedRule> rules) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
        return _buildRuleCard(rule);
      },
    );
  }
  
  Widget _buildRuleCard(TajweedRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: () => _navigateToRuleDetails(rule),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                      rule.category.arabicName,
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                rule.nameAr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                rule.nameEn,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                rule.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Row(
                children: [
                  const Icon(
                    Icons.format_quote,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      'مثال: ${rule.example}',
                      style: TextStyle(
                        fontFamily: 'Uthmanic',
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              if (rule.subRules.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                  child: Text(
                    'يتضمن ${rule.subRules.length} قواعد فرعية',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToRuleDetails(TajweedRule rule) {
    Navigator.pushNamed(
      context,
      AppRoutes.tajweedRuleDetails,
      arguments: rule,
    );
  }
}