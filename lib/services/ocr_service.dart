import 'dart:io';
import 'dart:convert';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;

class OCRService {
  final TextRecognizer _mlKitRecognizer;
  final String _cloudVisionApiKey;
  final String _cloudVisionEndpoint;

  OCRService({
    String? cloudVisionApiKey,
    String? cloudVisionEndpoint,
  })  : _mlKitRecognizer = GoogleMlKit.vision.textRecognizer(),
        _cloudVisionApiKey = cloudVisionApiKey ?? 'YOUR_CLOUD_VISION_KEY',
        _cloudVisionEndpoint = cloudVisionEndpoint ??
            'https://vision.googleapis.com/v1/images:annotate';

  Future<String> processImage(InputImage inputImage) async {
    try {
      // المحاولة الأولى: استخدام ML Kit
      final recognizedText = await _processWithMLKit(inputImage);
      return recognizedText;
    } catch (mlKitError) {
      // Fallback إلى Cloud Vision إذا فشلت ML Kit
      try {
        final recognizedText = await _processWithCloudVision(inputImage);
        return recognizedText;
      } catch (cloudVisionError) {
        throw Exception('فشل التعرف على النص: $mlKitError | $cloudVisionError');
      }
    }
  }

  Future<String> _processWithMLKit(InputImage inputImage) async {
    final RecognizedText recognizedText =
        await _mlKitRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  Future<String> _processWithCloudVision(InputImage inputImage) async {
    final imageBytes = await _getImageBytes(inputImage);
    final response = await http.post(
      Uri.parse('$_cloudVisionEndpoint?key=$_cloudVisionApiKey'),
      body: jsonEncode({
        'requests': [
          {
            'image': {'content': base64Encode(imageBytes)},
            'features': [
              {'type': 'TEXT_DETECTION'}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['responses'][0]['fullTextAnnotation']['text'] ?? '';
    } else {
      throw Exception('خطأ في Cloud Vision: ${response.statusCode}');
    }
  }

  Future<List<int>> _getImageBytes(InputImage inputImage) async {
    if (inputImage.filePath != null) {
      final file = File(inputImage.filePath!);
      return await file.readAsBytes();
    } else if (inputImage.bytes != null) {
      return inputImage.bytes!;
    } else {
      throw Exception('صيغة الصورة غير مدعومة');
    }
  }

  void dispose() {
    _mlKitRecognizer.close();
  }
}