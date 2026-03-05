import 'package:flutter/foundation.dart';

import 'package:my_people/helpers/analytics_helper.dart';
import 'package:my_people/model/chat_message.dart';
import 'package:my_people/model/chat_session.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/helpers/chat_prompt_builder.dart';
import 'package:my_people/services/gemini_ai_service.dart';
import 'package:my_people/utility/constants.dart';
import 'package:my_people/utility/debug_print.dart';

/// Manages all chat business logic: session caching, AI communication,
/// message filtering, and error state.
class ChatController extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Session cache (shared across instances for the app lifetime)
  // ---------------------------------------------------------------------------
  static final Map<String, ChatSession> _sessionCache = {};

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------
  final Person person;
  final GeminiAIService _aiService;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  late final ChatSession _session;

  bool _isLoading = false;
  bool _isThinking = false;
  bool _isChatUnavailable = false;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------
  List<ChatMessage> get messages => _session.messages;

  int get userMessageCount =>
      _session.messages.where((m) => m.sender == AppStrings.user).length;

  bool get isLoading => _isLoading;
  bool get isThinking => _isThinking;
  bool get isChatUnavailable => _isChatUnavailable;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------
  ChatController({required this.person}) : _aiService = GeminiAIService() {
    _session = _sessionCache.putIfAbsent(
      person.uuid,
      () => ChatSession(person.uuid),
    );
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Sends the system prompt and waits for the AI acknowledgement.
  /// Must be called once after construction (from the widget's initState).
  Future<void> initChat() async {
    _isLoading = true;
    notifyListeners();

    final prompt = ChatPromptBuilder.buildSystemPrompt(person);
    final aiResponse = await _aiService.sendInitialPrompt(prompt);
    final response = aiResponse.trim().toLowerCase();

    if (response == ChatPromptBuilder.expectedAck) {
      _session.messages.add(ChatMessage(
        text: aiResponse,
        sender: AppStrings.bot,
      ));
      _isLoading = false;
      notifyListeners();
    } else if (response.contains('error')) {
      _isChatUnavailable = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Sending messages
  // ---------------------------------------------------------------------------

  /// Sends a user message and appends the AI response.
  /// Returns `null` on success or an error string for the UI to display.
  Future<String?> sendMessage(String text) async {
    if (text.isEmpty) return null;

    AnalyticsHelper.trackFeatureUsage('send_AI_message');

    _session.messages.add(ChatMessage(text: text, sender: AppStrings.user));
    _isLoading = true;
    _isThinking = true;
    notifyListeners();

    // Prompt-injection guard
    if (text.toLowerCase().contains(AppStrings.prompt)) {
      _session.messages.add(ChatMessage(
        text: AppStrings.blockedResponse,
        sender: AppStrings.bot,
      ));
      _isLoading = false;
      _isThinking = false;
      notifyListeners();
      return null;
    }

    try {
      final aiResponse = await _aiService.sendMessage(text);
      final sanitized = _sanitizeResponse(aiResponse);
      _isThinking = false;
      _session.messages.add(ChatMessage(
        text: sanitized,
        sender: AppStrings.bot,
      ));
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isThinking = false;
      _isLoading = false;
      notifyListeners();

      if (e.toString().contains('SocketException')) {
        return AppStrings.checkInternetConnection;
      }
      return AppStrings.errorSendingMessage;
    }
  }

  // ---------------------------------------------------------------------------
  // Reporting
  // ---------------------------------------------------------------------------

  /// Replaces a message with the "thank you" placeholder and logs the report.
  /// Returns `true` on success, `false` if the message was not found.
  bool reportMessage(ChatMessage message) {
    final index = _session.messages.indexOf(message);
    if (index == -1) {
      DebugPrint.log(
        'Error reporting message: Message not found in list.',
        color: DebugColor.red,
        tag: 'ChatController',
      );
      return false;
    }

    AnalyticsHelper.trackReportAIMessage(message.text);
    _session.messages[index] = ChatMessage(
      text: AppStrings.reportedMessageThankYou,
      sender: AppStrings.bot,
    );
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  String _sanitizeResponse(String response) {
    if (response.toLowerCase().contains(AppStrings.prompt)) {
      return AppStrings.blockedResponse;
    }
    return response;
  }
}
