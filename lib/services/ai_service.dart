// في services/ai_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  final GenerativeModel _model;

  AIService({required String apiKey})
      : _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  Future<String> generateExercise(String text) async {
    final prompt = "Generate English exercise for: $text";
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No exercise generated';
  }
}

