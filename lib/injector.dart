// في injector.dart
import 'package:english_mentor_ai2/presentation/blocs/ocr_bloc/ocr_bloc.dart';
import 'package:english_mentor_ai2/services/ai_service.dart';
import 'package:english_mentor_ai2/services/ocr_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  
  getIt.registerSingleton<AIService>(AIService(apiKey: 'YOUR_API_KEY'));
  getIt.registerSingleton<OCRService>(OCRService());
  
  getIt.registerFactory(() => OcrBloc(ocrService: getIt<OCRService>()));
}