import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'ar';
  bool _offlineMode = false;
  bool _notifications = true;
  double _audioVolume = 0.7;
  double _fontSizeScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _isDarkMode = prefs.getBool(AppConstants.themeKey) ?? false;
      _selectedLanguage = prefs.getString(AppConstants.languageKey) ?? 'ar';
      _offlineMode = prefs.getBool('offline_mode') ?? false;
      _notifications = prefs.getBool('notifications_enabled') ?? true;
      _audioVolume = prefs.getDouble('audio_volume') ?? 0.7;
      _fontSizeScale = prefs.getDouble('font_size_scale') ?? 1.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(AppConstants.themeKey, _isDarkMode);
    await prefs.setString(AppConstants.languageKey, _selectedLanguage);
    await prefs.setBool('offline_mode', _offlineMode);
    await prefs.setBool('notifications_enabled', _notifications);
    await prefs.setDouble('audio_volume', _audioVolume);
    await prefs.setDouble('font_size_scale', _fontSizeScale);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الإعدادات'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          _buildSectionTitle('المظهر'),
          _buildDarkModeSwitch(),
          _buildFontSizeSlider(),

          const Divider(height: 32),
          _buildSectionTitle('اللغة والمنطقة'),
          _buildLanguageSelector(),

          const Divider(height: 32),
          _buildSectionTitle('الصوت والوسائط'),
          _buildVolumeSlider(),

          const Divider(height: 32),
          _buildSectionTitle('الإشعارات'),
          _buildNotificationsSwitch(),

          const Divider(height: 32),
          _buildSectionTitle('الاتصال بالإنترنت'),
          _buildOfflineModeSwitch(),

          const SizedBox(height: 32),
          _buildSaveButton(),

          const SizedBox(height: AppConstants.paddingLarge),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDarkModeSwitch() {
    return SwitchListTile(
      title: const Text('الوضع الداكن'),
      subtitle: const Text('تفعيل المظهر الداكن للتطبيق'),
      value: _isDarkMode,
      onChanged: (value) {
        setState(() {
          _isDarkMode = value;
        });
      },
      activeColor: AppConstants.primaryColor,
    );
  }

  Widget _buildFontSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.paddingMedium,
            right: AppConstants.paddingMedium,
            top: AppConstants.paddingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('حجم الخط'),
              Text('${(_fontSizeScale * 100).toInt()}%'),
            ],
          ),
        ),
        Slider(
          value: _fontSizeScale,
          min: 0.8,
          max: 1.4,
          divisions: 6,
          label: '${(_fontSizeScale * 100).toInt()}%',
          onChanged: (value) {
            setState(() {
              _fontSizeScale = value;
            });
          },
          activeColor: AppConstants.primaryColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('أصغر', style: TextStyle(fontSize: 12)),
              const Text('أكبر', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'اللغة',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
        ),
        value: _selectedLanguage,
        items: const [
          DropdownMenuItem(
            value: 'ar',
            child: Text('العربية'),
          ),
          DropdownMenuItem(
            value: 'en',
            child: Text('English'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedLanguage = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.paddingMedium,
            right: AppConstants.paddingMedium,
            top: AppConstants.paddingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('مستوى الصوت'),
              Text('${(_audioVolume * 100).toInt()}%'),
            ],
          ),
        ),
        Slider(
          value: _audioVolume,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: '${(_audioVolume * 100).toInt()}%',
          onChanged: (value) {
            setState(() {
              _audioVolume = value;
            });
          },
          activeColor: AppConstants.primaryColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.volume_mute, size: 16),
              const Icon(Icons.volume_up, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSwitch() {
    return SwitchListTile(
      title: const Text('الإشعارات'),
      subtitle: const Text('تلقي تذكيرات التلاوة اليومية وإشعارات التحديثات'),
      value: _notifications,
      onChanged: (value) {
        setState(() {
          _notifications = value;
        });
      },
      activeColor: AppConstants.primaryColor,
    );
  }

  Widget _buildOfflineModeSwitch() {
    return SwitchListTile(
      title: const Text('وضع عدم الاتصال'),
      subtitle: const Text('تنزيل البيانات للاستخدام بدون إنترنت'),
      value: _offlineMode,
      onChanged: (value) {
        setState(() {
          _offlineMode = value;
        });

        if (value && mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('تحميل البيانات'),
              content: const Text(
                'سيقوم التطبيق بتنزيل البيانات اللازمة للعمل في وضع عدم الاتصال. '
                'قد يستغرق هذا بعض الوقت ويستهلك مساحة تخزين إضافية.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // هنا سيتم تنفيذ منطق تنزيل البيانات
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('جاري تنزيل البيانات...'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  child: const Text('تنزيل'),
                ),
              ],
            ),
          );
        }
      },
      activeColor: AppConstants.primaryColor,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveSettings,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      ),
      child: const Text('حفظ الإعدادات'),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'حول التطبيق',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'الكوثر',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'تطبيق ذكي لتحليل وتحسين تلاوة القرآن الكريم',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                const Text('الإصدار: 1.0.0'),
                const SizedBox(height: AppConstants.paddingSmall),
                const Text('حقوق النشر © 2023 - فريق الكوثر'),
                const SizedBox(height: AppConstants.paddingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconButton(Icons.email, 'تواصل معنا'),
                    _buildIconButton(Icons.star, 'تقييم التطبيق'),
                    _buildIconButton(Icons.privacy_tip, 'سياسة الخصوصية'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        // عمل مناسب لكل زر (إرسال بريد، فتح صفحة التقييم، إلخ)
      },
      child: Column(
        children: [
          Icon(icon, color: AppConstants.primaryColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}