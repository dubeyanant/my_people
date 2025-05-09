import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:my_people/utility/debug_print.dart';

class GeminiAIService {
  static final _apiKey = dotenv.env['GEMINI_KEY'];
  final GenerativeModel _model;
  late ChatSession _chat;

  GeminiAIService()
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: _apiKey!,
          safetySettings: safetySettings,
          generationConfig: generationConfig,
        ) {
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'No response from Gemini AI';
    } catch (e) {
      DebugPrint.log(
        'Error sending message to Gemini AI: $e',
        color: DebugColor.red,
        tag: 'GeminiAIService',
      );
      return 'Error: Unable to get a response from Gemini AI';
    }
  }

  void startNewChat() {
    _chat = _model.startChat();
  }

  Future<String> sendInitialPrompt(String initialPrompt) async {
    startNewChat();
    return sendMessage(initialPrompt);
  }
}

final safetySettings = [
  SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
  SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
  SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
  SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
];

final generationConfig = GenerationConfig(
  temperature: 0.35,
  topK: 2,
  topP: 1,
  maxOutputTokens: 1024,
);
