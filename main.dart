import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/recitation_bloc.dart';
import 'screens/recitation_analysis_screen.dart';
import 'services/audio_recording_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranAIApp());
}

class QuranAIApp extends StatelessWidget {
  const QuranAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecitationBloc>(
          create: (context) => RecitationBloc(
            RecitationInitial(quranData: {}),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'الكوثر - QuranAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Tajawal',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF43A047),
            centerTitle: true,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          textTheme: TextTheme(
            // تعريف أنماط النص
            displayLarge: const TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: const TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: const TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.black87,
            ),
            bodyMedium: const TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.black87,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _audioRecordingService = AudioRecordingService();
  String? _recordingPath;
  String? _recitationId;
  
  @override
  void initState() {
    super.initState();
    _audioRecordingService.initialize();
  }
  
  @override
  void dispose() {
    _audioRecordingService.dispose();
    super.dispose();
  }
  
  void _startRecording() async {
    final hasPermission = await _audioRecordingService.requestPermissions();
    if (hasPermission) {
      await _audioRecordingService.startRecording();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم منح إذن الوصول للميكروفون'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _stopRecording() async {
    _recordingPath = await _audioRecordingService.stopRecording();
    _recitationId = DateTime.now().millisecondsSinceEpoch.toString();
    
    if (_recordingPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل التلاوة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _navigateToAnalysis() {
    if (_recordingPath != null && _recitationId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecitationAnalysisScreen(
            audioFilePath: _recordingPath,
            currentRecitationId: _recitationId,
            selectedSurahId: 1, // الفاتحة
            selectedAyahId: 1, // الآية الأولى
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تسجيل تلاوة أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الكوثر - QuranAI'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'مرحباً بك في تطبيق الكوثر',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'تطبيق ذكي لتحليل وتحسين تلاوة القرآن الكريم',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              StreamBuilder<AudioRecordingService.RecordingStatus>(
                stream: _audioRecordingService.recordingStatusStream,
                initialData: AudioRecordingService.RecordingStatus(
                  isRecording: false,
                  currentDuration: Duration.zero,
                  amplitude: 0,
                ),
                builder: (context, snapshot) {
                  final isRecording = snapshot.data?.isRecording ?? false;
                  final duration = snapshot.data?.currentDuration ?? Duration.zero;
                  
                  return Column(
                    children: [
                      if (isRecording)
                        Text(
                          '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: isRecording ? _stopRecording : _startRecording,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isRecording ? Colors.red : const Color(0xFF43A047),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isRecording ? 'اضغط للتوقف' : 'اضغط للتسجيل',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _navigateToAnalysis,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 45),
                ),
                child: const Text(
                  'تحليل التلاوة',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
