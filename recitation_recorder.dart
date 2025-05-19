import 'package:flutter/material.dart';
import '../services/audio_recording_service.dart';

class RecitationRecorder extends StatefulWidget {
  final Function(String) onRecordingComplete;
  
  const RecitationRecorder({
    Key? key,
    required this.onRecordingComplete,
  }) : super(key: key);

  @override
  State<RecitationRecorder> createState() => _RecitationRecorderState();
}

class _RecitationRecorderState extends State<RecitationRecorder> {
  final _audioRecordingService = AudioRecordingService();
  bool _isRecording = false;
  Duration _currentDuration = Duration.zero;
  double _amplitude = 0.0;
  
  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }
  
  @override
  void dispose() {
    _audioRecordingService.dispose();
    super.dispose();
  }
  
  Future<void> _initializeRecorder() async {
    await _audioRecordingService.initialize();
    _audioRecordingService.recordingStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _isRecording = status.isRecording;
          _currentDuration = status.currentDuration;
          _amplitude = status.amplitude;
        });
      }
    });
  }
  
  Future<void> _startRecording() async {
    final hasPermission = await _audioRecordingService.requestPermissions();
    if (hasPermission) {
      await _audioRecordingService.startRecording();
    } else {
      // إظهار رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم منح إذن استخدام الميكروفون'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _stopRecording() async {
    final path = await _audioRecordingService.stopRecording();
    if (path != null && mounted) {
      widget.onRecordingComplete(path);
    }
  }
  
  Future<void> _cancelRecording() async {
    await _audioRecordingService.cancelRecording();
  }
  
  // تنسيق عدد ليظهر برقمين
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  
  // تنسيق المدة الزمنية
  String _formatDuration(Duration duration) {
    final minutes = _twoDigits(duration.inMinutes.remainder(60));
    final seconds = _twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // عرض الوقت المنقضي
        Text(
          _formatDuration(_currentDuration),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // شريط مؤشر شدة الصوت
        if (_isRecording)
          Container(
            width: double.infinity,
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                FractionallySizedBox(
                  widthFactor: _amplitude,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade300,
                          Colors.green.shade500,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // أزرار التحكم
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRecording) ...[
              // زر إلغاء التسجيل
              IconButton(
                onPressed: _cancelRecording,
                icon: const Icon(Icons.delete),
                color: Colors.red,
                tooltip: 'إلغاء التسجيل',
              ),
              const SizedBox(width: 24),
              
              // زر إيقاف التسجيل
              ElevatedButton(
                onPressed: _stopRecording,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                ),
                child: const Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ] else
              // زر بدء التسجيل
              ElevatedButton(
                onPressed: _startRecording,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 32,
                ),
              ),
          ],
        ),
        
        // نص المساعدة
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            _isRecording ? 'اضغط للتوقف' : 'اضغط للتسجيل',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
