/// Maps provider/auth failures to calm, blame-free copy for the Home UX
/// (EOM-S18 / UX F2). Never surfaces raw `Exception:` strings.
class IntentError {
  const IntentError({required this.message, this.offerSettings = false});

  /// User-facing copy shown in the response card.
  final String message;

  /// When true, the UI should offer an Open Settings recovery action.
  final bool offerSettings;

  /// Builds a friendly [IntentError] from a caught object.
  static IntentError from(Object error) {
    final raw = error.toString();
    final msg = raw.replaceFirst(RegExp(r'^Exception:\s*'), '');

    if (_isMissingCredential(msg)) {
      return const IntentError(
        message: 'Add an API key in Settings so this provider can respond.',
        offerSettings: true,
      );
    }

    if (_isProviderConfig(msg)) {
      return const IntentError(
        message:
            'That provider needs a quick check in Settings before it can respond.',
        offerSettings: true,
      );
    }

    if (_isProviderFailure(msg)) {
      return const IntentError(
        message:
            'That provider couldn\'t complete the request. Check Settings or try again.',
        offerSettings: true,
      );
    }

    return const IntentError(
      message: 'Something went quiet — try again in a moment.',
    );
  }

  static bool _isMissingCredential(String msg) {
    final lower = msg.toLowerCase();
    return lower.contains('api_key is missing') ||
        lower.contains('api key is missing') ||
        lower.contains('master key is required') ||
        lower.contains('model alias is missing');
  }

  static bool _isProviderConfig(String msg) {
    final lower = msg.toLowerCase();
    return lower.contains('litellm') &&
        (lower.contains('required') || lower.contains('missing'));
  }

  static bool _isProviderFailure(String msg) {
    return msg.contains('OpenAI Error') ||
        msg.contains('Anthropic Error') ||
        msg.contains('Gemini Error') ||
        msg.contains('LiteLLM') ||
        msg.contains('Error:');
  }
}
