import 'package:flutter/material.dart';
import 'dart:async';
import '../models/kids_content.dart';
import '../services/kids_content_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_indicator.dart';

/// شاشة الألعاب التعليمية للأطفال
class KidsGameScreen extends StatefulWidget {
  final KidsGame game;

  const KidsGameScreen({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  State<KidsGameScreen> createState() => _KidsGameScreenState();
}

class _KidsGameScreenState extends State<KidsGameScreen> {
  final KidsContentService _kidsService = KidsContentService();
  
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isGameStarted = false;
  bool _isGamePaused = false;
  bool _isGameCompleted = false;
  
  int _currentScore = 0;
  int _highScore = 0;
  int _timeRemaining = 0;
  Timer? _gameTimer;
  
  @override
  void initState() {
    super.initState();
    _loadGameData();
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
  
  /// تحميل بيانات اللعبة
  Future<void> _loadGameData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final highScore = await _kidsService.getGameHighScore(widget.game.id);
      
      if (mounted) {
        setState(() {
          _highScore = highScore;
          _isLoading = false;
          
          // تعيين الوقت الافتراضي وفقاً لمستوى الصعوبة
          switch (widget.game.difficulty) {
            case GameDifficulty.easy:
              _timeRemaining = 120; // سهل: دقيقتان
              break;
            case GameDifficulty.medium:
              _timeRemaining = 90; // متوسط: دقيقة ونصف
              break;
            case GameDifficulty.hard:
              _timeRemaining = 60; // صعب: دقيقة واحدة
              break;
          }
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
  
  /// بدء اللعبة
  void _startGame() {
    setState(() {
      _isGameStarted = true;
      _isGamePaused = false;
      _currentScore = 0;
    });
    
    _startTimer();
  }
  
  /// إيقاف اللعبة مؤقتًا
  void _pauseGame() {
    setState(() {
      _isGamePaused = true;
    });
    
    _gameTimer?.cancel();
  }
  
  /// استئناف اللعبة
  void _resumeGame() {
    setState(() {
      _isGamePaused = false;
    });
    
    _startTimer();
  }
  
  /// إعادة تشغيل اللعبة
  void _restartGame() {
    setState(() {
      _isGameStarted = false;
      _isGamePaused = false;
      _isGameCompleted = false;
      _currentScore = 0;
      
      // إعادة ضبط الوقت
      switch (widget.game.difficulty) {
        case GameDifficulty.easy:
          _timeRemaining = 120;
          break;
        case GameDifficulty.medium:
          _timeRemaining = 90;
          break;
        case GameDifficulty.hard:
          _timeRemaining = 60;
          break;
      }
    });
    
    _gameTimer?.cancel();
  }
  
  /// بدء المؤقت
  void _startTimer() {
    _gameTimer?.cancel();
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeRemaining > 0) {
            _timeRemaining--;
          } else {
            timer.cancel();
            _endGame();
          }
        });
      }
    });
  }
  
  /// إنهاء اللعبة
  void _endGame() {
    setState(() {
      _isGameStarted = false;
      _isGameCompleted = true;
    });
    
    _gameTimer?.cancel();
    
    // تحديث أعلى نتيجة إذا كانت النتيجة الحالية أعلى
    if (_currentScore > _highScore) {
      _kidsService.updateGameHighScore(widget.game.id, _currentScore);
      setState(() {
        _highScore = _currentScore;
      });
    }
    
    // عرض مربع حوار النتيجة النهائية
    _showGameResultDialog();
  }
  
  /// عرض مربع حوار النتيجة
  void _showGameResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _currentScore > _highScore ? Icons.emoji_events : Icons.stars,
              color: _currentScore > _highScore
                  ? AppConstants.gamificationColor
                  : Colors.amber,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              _currentScore > _highScore
                  ? 'رائع! سجل جديد!'
                  : 'انتهت اللعبة!',
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: _currentScore > _highScore
                  ? Image.asset('assets/images/trophy.png')
                  : Icon(
                      Icons.star,
                      size: 80,
                      color: Colors.amber,
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              'النتيجة: $_currentScore نقطة',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أعلى نتيجة: $_highScore نقطة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('العودة للقائمة'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
              _startGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.kidsThemeColor,
            ),
            child: const Text('اللعب مرة أخرى'),
          ),
        ],
      ),
    );
  }
  
  /// زيادة النتيجة
  void _increaseScore(int points) {
    setState(() {
      _currentScore += points;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
        backgroundColor: AppConstants.kidsThemeColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // عرض تعليمات اللعبة
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تعليمات اللعبة'),
                  content: Text(widget.game.instructions),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('حسناً'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'تعليمات اللعبة',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'جاري تحميل اللعبة...')
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : Column(
                  children: [
                    // شريط المعلومات
                    _buildInfoBar(),
                    
                    // محتوى اللعبة
                    Expanded(
                      child: _isGameStarted
                          ? _buildGameContent()
                          : _buildGameIntroduction(),
                    ),
                    
                    // شريط التحكم
                    _buildControlBar(),
                  ],
                ),
    );
  }
  
  /// بناء عرض الخطأ
  Widget _buildErrorView() {
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
            'حدث خطأ أثناء تحميل اللعبة',
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
            onPressed: _loadGameData,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.kidsThemeColor,
            ),
          ),
        ],
      ),
    );
  }
  
  /// بناء شريط المعلومات
  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // مستوى الصعوبة
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getDifficultyColor(widget.game.difficulty),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.game.difficulty.toArabicString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // نوع اللعبة
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.game.gameType.toArabicString(),
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const Spacer(),
          
          // النقاط
          if (_isGameStarted || _isGameCompleted)
            Row(
              children: [
                const Icon(
                  Icons.stars,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_currentScore',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          
          const SizedBox(width: 16),
          
          // الوقت المتبقي
          if (_isGameStarted)
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: _timeRemaining < 10
                      ? AppConstants.errorColor
                      : Colors.grey[700],
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_timeRemaining ~/ 60}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _timeRemaining < 10
                        ? AppConstants.errorColor
                        : null,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  /// بناء مقدمة اللعبة
  Widget _buildGameIntroduction() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // صورة اللعبة
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Image.asset(
              widget.game.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          
          // عنوان اللعبة
          Text(
            widget.game.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.kidsThemeColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // وصف اللعبة
          Text(
            widget.game.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // أعلى نتيجة
          if (_highScore > 0)
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppConstants.gamificationColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: AppConstants.gamificationColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'أعلى نتيجة: $_highScore',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.gamificationColor,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 32),
          
          // زر بدء اللعبة
          ElevatedButton.icon(
            onPressed: _startGame,
            icon: const Icon(Icons.play_arrow),
            label: const Text('ابدأ اللعب'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.kidsThemeColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// بناء محتوى اللعبة
  Widget _buildGameContent() {
    // تنفيذ لعبة ذاكرة بسيطة
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'لعبة تطابق البطاقات',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            if (_isGamePaused)
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.pause_circle_filled,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'اللعبة متوقفة مؤقتاً',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _resumeGame,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('استئناف'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.kidsThemeColor,
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // تنفيذ منطق اللعبة
                      _increaseScore(10);
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.help_outline,
                          size: 32,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  
  /// بناء شريط التحكم
  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_isGameStarted && !_isGamePaused)
            // زر الإيقاف المؤقت
            ElevatedButton.icon(
              onPressed: _pauseGame,
              icon: const Icon(Icons.pause),
              label: const Text('إيقاف مؤقت'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
            )
          else if (_isGameStarted && _isGamePaused)
            // زر الاستئناف
            ElevatedButton.icon(
              onPressed: _resumeGame,
              icon: const Icon(Icons.play_arrow),
              label: const Text('استئناف'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.kidsThemeColor,
              ),
            ),
            
          if (_isGameStarted)
            // زر إعادة التشغيل
            ElevatedButton.icon(
              onPressed: _restartGame,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
              ),
            )
          else if (!_isGameStarted && !_isGameCompleted)
            // زر البدء
            ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow),
              label: const Text('ابدأ اللعب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.kidsThemeColor,
              ),
            ),
            
          // زر الخروج
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.exit_to_app),
            label: const Text('خروج'),
          ),
        ],
      ),
    );
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