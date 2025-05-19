import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/recitation_analysis.dart';
import '../services/quran_api_service.dart';

// أحداث كتلة التلاوة
abstract class RecitationEvent {}

class AnalyzeRecitation extends RecitationEvent {
  final String recitationId;
  final File audioFile;
  
  AnalyzeRecitation({
    required this.recitationId,
    required this.audioFile,
  });
}

class LoadAyah extends RecitationEvent {
  final int surahId;
  final int ayahId;
  
  LoadAyah({
    required this.surahId,
    required this.ayahId,
  });
}

// حالات كتلة التلاوة
abstract class RecitationState {
  final Map<String, dynamic> quranData;
  
  RecitationState({required this.quranData});
}

class RecitationInitial extends RecitationState {
  RecitationInitial({required super.quranData});
}

class RecitationLoading extends RecitationState {
  RecitationLoading({required super.quranData});
}

class RecitationAnalyzed extends RecitationState {
  final String recitationId;
  final RecitationAnalysis analysis;
  
  RecitationAnalyzed({
    required super.quranData,
    required this.recitationId,
    required this.analysis,
  });
}

class RecitationError extends RecitationState {
  final String message;
  
  RecitationError({
    required super.quranData,
    required this.message,
  });
}

// كتلة التلاوة
class RecitationBloc extends Bloc<RecitationEvent, RecitationState> {
  final QuranApiService _apiService = QuranApiService();
  
  RecitationBloc(RecitationState initialState) : super(initialState) {
    on<AnalyzeRecitation>(_onAnalyzeRecitation);
    on<LoadAyah>(_onLoadAyah);
  }
  
  Future<void> _onAnalyzeRecitation(
    AnalyzeRecitation event,
    Emitter<RecitationState> emit,
  ) async {
    emit(RecitationLoading(quranData: state.quranData));
    
    try {
      // استدعاء خدمة تحليل التلاوة
      final analysis = await _apiService.analyzeRecitation(
        event.recitationId,
        event.audioFile,
      );
      
      if (analysis != null) {
        emit(RecitationAnalyzed(
          quranData: state.quranData,
          recitationId: event.recitationId,
          analysis: analysis,
        ));
      } else {
        emit(RecitationError(
          quranData: state.quranData,
          message: 'فشل في تحليل التلاوة، يرجى المحاولة مرة أخرى',
        ));
      }
    } catch (e) {
      emit(RecitationError(
        quranData: state.quranData,
        message: 'حدث خطأ أثناء تحليل التلاوة: ${e.toString()}',
      ));
    }
  }
  
  Future<void> _onLoadAyah(
    LoadAyah event,
    Emitter<RecitationState> emit,
  ) async {
    try {
      // استدعاء خدمة جلب الآية
      final ayah = await _apiService.getAyah(
        event.surahId,
        event.ayahId,
      );
      
      if (ayah != null) {
        // نسخ البيانات الحالية وإضافة الآية الجديدة
        final updatedQuranData = Map<String, dynamic>.from(state.quranData);
        updatedQuranData['currentAyah'] = ayah;
        
        emit(RecitationInitial(quranData: updatedQuranData));
      } else {
        emit(RecitationError(
          quranData: state.quranData,
          message: 'فشل في تحميل الآية، يرجى المحاولة مرة أخرى',
        ));
      }
    } catch (e) {
      emit(RecitationError(
        quranData: state.quranData,
        message: 'حدث خطأ أثناء تحميل الآية: ${e.toString()}',
      ));
    }
  }
}
