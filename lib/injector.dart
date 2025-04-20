// lib/injector.dart

import 'package:get_it/get_it.dart';
import 'services/ai_service.dart';
import 'services/ocr_service.dart';
import 'presentation/blocs/ocr_bloc/ocr_bloc.dart';
import 'data/datasources/local/shared_prefs_local_datasource.dart';
import 'domain/repositories/chat_repository.dart';
import 'data/repositories/chat_repository_impl.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // سابقًا:
  getIt.registerSingleton<AIService>(AIService(apiKey: 'YOUR_API_KEY'));
  getIt.registerSingleton<OCRService>(OCRService());
  getIt.registerFactory(() => OcrBloc(ocrService: getIt<OCRService>()));

  // الجدید:
  getIt.registerLazySingleton<LocalDataSource>(() => SharedPrefsLocalDataSource());
  getIt.registerLazySingleton<ChatRepository>(() =>
      ChatRepositoryImpl(getIt<LocalDataSource>()));
}

