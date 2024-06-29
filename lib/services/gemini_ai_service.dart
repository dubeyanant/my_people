// ignore_for_file: unused_field

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAIService {
  static final _apiKey = dotenv.env['GEMINI_KEY'];
  final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiAIService()
      : _model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: _apiKey!,
          safetySettings: safetySettings,
          generationConfig: generationConfig,
        ) {
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    final content = [Content.text(message)];
    final response = await _model.generateContent(
      content,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
    );

    return response.text ?? 'No response from Gemini AI';
  }
}

final safetySettings = [
  SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
  SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
  SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
  SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
];

final generationConfig = GenerationConfig(
  temperature: 0.2,
  topK: 1,
  topP: 1,
  maxOutputTokens: 2048,
);
