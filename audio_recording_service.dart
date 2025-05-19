import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingService {
  // تمثيل حالة التسجيل
  class RecordingStatus {
    final bool isRecording;
    final Duration currentDuration;
    final double amplitude;
    
    RecordingStatus({
      required this.isRecording,
      required this.currentDuration,
      required this.amplitude,
    });
  }
  
  // متغيرات الخدمة
  bool _isInitialized = false;
  bool _isRecording = false;
  Timer? _durationTimer;
  Duration _currentDuration = Duration.zero;
  final _recordingStatusController = StreamController<RecordingStatus>.broadcast();
  
  // كائن التسجيل
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String _recordingPath = '';
  double _currentAmplitude = 0;
  
  // الحصول على تدفق حالة التسجيل
  Stream<RecordingStatus> get recordingStatusStream => _recordingStatusController.stream;
  
  // تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _recorder.openRecorder();
      _isInitialized = true;
      
      // استماع لتحديثات مستوى الصوت
      // تعديل: في الإصدارات الجديدة، يجب استخدام onProgress مع مراعاة أنه قد يكون null
      if (_recorder.onProgress != null) {
        _recorder.onProgress!.listen((event) {
          if (event.decibels != null) {
            // القيم السالبة للديسيبل تعني الهدوء، لذا نحولها إلى قيم بين 0 و 1
            _currentAmplitude = ((event.decibels! + 80) / 80).clamp(0.0, 1.0);
          }
        });
      } else {
        // في حالة عدم توفر onProgress، سنستخدم مؤقتاً لتوليد قيم وهمية
        if (_isRecording) {
          Timer.periodic(const Duration(milliseconds: 200), (timer) {
            if (!_isRecording) {
              timer.cancel();
              return;
            }
            _currentAmplitude = 0.5 + (DateTime.now().millisecondsSinceEpoch % 100) / 200;
          });
        }
      }
    } catch (e) {
      print('خطأ في تهيئة المسجل: $e');
    }
  }
  
  // طلب أذونات الوصول للميكروفون
  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  // بدء التسجيل
  Future<void> startRecording() async {
    if (!_isInitialized) await initialize();
    
    try {
      // تجهيز ملف التسجيل
      final appDir = await getApplicationDocumentsDirectory();
      _recordingPath = '${appDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      
      // تعديل: ضمان توافق مع أحدث إصدار من flutter_sound
      // في بعض الإصدارات، يتم استخدام toFile بدلاً من toFilePath
      await _recorder.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacADTS,
      );
      
      _isRecording = true;
      _currentDuration = Duration.zero;
      
      // بدء مؤقت لتتبع مدة التسجيل
      _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _currentDuration += const Duration(milliseconds: 100);
        
        // إرسال تحديث حالة التسجيل
        _recordingStatusController.add(
          RecordingStatus(
            isRecording: _isRecording,
            currentDuration: _currentDuration,
            amplitude: _currentAmplitude,
          ),
        );
      });
    } catch (e) {
      print('خطأ في بدء التسجيل: $e');
      _isRecording = false;
    }
  }
  
  // إيقاف التسجيل
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    try {
      // إيقاف المؤقت
      _durationTimer?.cancel();
      _durationTimer = null;
      
      // إيقاف التسجيل
      final path = await _recorder.stopRecorder();
      
      _isRecording = false;
      
      // إرسال تحديث حالة التسجيل النهائية
      _recordingStatusController.add(
        RecordingStatus(
          isRecording: false,
          currentDuration: _currentDuration,
          amplitude: 0,
        ),
      );
      
      // التحقق من وجود الملف
      if (path != null) {
        final recordingFile = File(path);
        if (await recordingFile.exists()) {
          return path;
        }
      }
      
      // في حالة وجود الملف من _recordingPath
      final recordingFile = File(_recordingPath);
      if (await recordingFile.exists()) {
        return _recordingPath;
      }
      
      return null;
    } catch (e) {
      print('خطأ في إيقاف التسجيل: $e');
      _isRecording = false;
      return null;
    }
  }
  
  // إلغاء التسجيل
  Future<void> cancelRecording() async {
    if (!_isRecording) return;
    
    try {
      // إيقاف المؤقت
      _durationTimer?.cancel();
      _durationTimer = null;
      
      // إيقاف التسجيل
      await _recorder.stopRecorder();
      
      // حذف الملف إذا كان موجوداً
      final recordingFile = File(_recordingPath);
      if (await recordingFile.exists()) {
        await recordingFile.delete();
      }
      
      _isRecording = false;
      _currentDuration = Duration.zero;
      
      // إرسال تحديث حالة التسجيل
      _recordingStatusController.add(
        RecordingStatus(
          isRecording: false,
          currentDuration: Duration.zero,
          amplitude: 0,
        ),
      );
    } catch (e) {
      print('خطأ في إلغاء التسجيل: $e');
      _isRecording = false;
    }
  }
  
  // التخلص من الموارد
  void dispose() {
    _durationTimer?.cancel();
    _recordingStatusController.close();
    _recorder.closeRecorder();
  }
}
