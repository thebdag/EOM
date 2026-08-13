/// The LLM providers the app can route intents to (EOM-S10).
///
/// Provider identity used to be a raw uppercase string with the legacy
/// `OLLAMA` → `LOCAL` mapping re-implemented at every call site; it now
/// lives here exactly once. Persisted preferences store [id].
enum LlmProviderKind {
  openai(id: 'OPENAI', label: 'OpenAI', keyHint: 'API Key (sk-...)'),
  anthropic(
    id: 'ANTHROPIC',
    label: 'Anthropic Claude',
    keyHint: 'API Key (sk-ant-...)',
  ),
  gemini(id: 'GEMINI', label: 'Google Gemini', keyHint: 'API Key'),
  local(id: 'LOCAL', label: 'LiteLLM', keyHint: 'Master Key (required)');

  const LlmProviderKind({
    required this.id,
    required this.label,
    required this.keyHint,
  });

  /// Uppercase value persisted in shared preferences.
  final String id;

  /// Human-readable name shown in settings.
  final String label;

  /// Hint for the essential credential field (soft gate + Settings).
  final String keyHint;

  /// The kind used when no preference has been saved yet.
  static const LlmProviderKind fallback = LlmProviderKind.gemini;

  /// Parses a persisted provider id, mapping the legacy `OLLAMA`
  /// preference value to [LlmProviderKind.local] and falling back to
  /// [fallback] for unknown values.
  static LlmProviderKind fromString(String raw) {
    var normalized = raw.trim().toUpperCase();
    if (normalized == 'OLLAMA') normalized = 'LOCAL';
    return LlmProviderKind.values.firstWhere(
      (k) => k.id == normalized,
      orElse: () => fallback,
    );
  }
}
