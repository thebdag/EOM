import 'dart:convert';

import '../models/epistemic_node.dart';
import '../models/epistemic_operation.dart';
import '../models/epistemic_relationship.dart';
import 'epistemic_service.dart';

String _normalize(String value) =>
    value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

/// Contract for mapping a cognitive intent's LLM exchange onto mutations of
/// the epistemic graph (EOM-T6..T10).
///
/// Each intent gets one implementation. Implementations must be total: any
/// parse or matching failure degrades to an empty operation list, never an
/// exception reaching the caller.
abstract interface class IntentOperation {
  /// Applies the graph mutations implied by [llmResponse] to [input] and
  /// returns the operations that were applied (possibly empty).
  Future<List<EpistemicOperation>> apply({
    required String input,
    required String llmResponse,
  });
}

/// Structured payload the Clarify prompt asks the LLM to append to its
/// response as a fenced JSON block.
class ClarifyPayload {
  const ClarifyPayload({this.surface, this.deeper, this.resolved});

  /// The surface concern stated by the user.
  final String? surface;

  /// The deeper current underneath the surface concern.
  final String? deeper;

  /// Content of an existing belief this exchange resolved, if any.
  final String? resolved;

  bool get hasDisambiguation =>
      surface != null &&
      surface!.isNotEmpty &&
      deeper != null &&
      deeper!.isNotEmpty &&
      _normalize(surface!) != _normalize(deeper!);

  bool get hasResolution => resolved != null && resolved!.isNotEmpty;
}

/// Maps the Clarify intent onto epistemic operations (EOM-T6):
///
/// - **Disambiguate** — when the response separates a surface concern from a
///   deeper current, both become nodes (`question` type, default confidence)
///   with the deeper node refining the surface one. An existing node whose
///   content matches the surface text is reused instead of duplicated.
/// - **Raise confidence** — when the response reports a resolved belief,
///   the matching node's confidence is raised by [confidenceStep], capped at
///   [confidenceCeiling] (Clarify never produces certainty, never lowers
///   confidence, never deletes).
class ClarifyOperation implements IntentOperation {
  ClarifyOperation(this._graph);

  /// Confidence added per resolved exchange.
  static const confidenceStep = 0.1;

  /// Hard cap — automated raises may never reach certainty.
  static const confidenceCeiling = 0.9;

  final EpistemicService _graph;

  @override
  Future<List<EpistemicOperation>> apply({
    required String input,
    required String llmResponse,
  }) async {
    final payload = parsePayload(llmResponse);
    if (payload == null) return const [];

    final operations = derive(payload, await _graph.all());
    for (final op in operations) {
      await _applyOne(op);
    }
    return operations;
  }

  /// Extracts the [ClarifyPayload] from an LLM response.
  ///
  /// Looks for a fenced ```json block first, then falls back to the last
  /// bare `{...}` object in the text. Returns null on any parse failure.
  static ClarifyPayload? parsePayload(String llmResponse) {
    final jsonText = _extractJsonBlock(llmResponse);
    if (jsonText == null) return null;
    try {
      final data = jsonDecode(jsonText) as Map<String, dynamic>;
      return ClarifyPayload(
        surface: data['surface'] as String?,
        deeper: data['deeper'] as String?,
        resolved: data['resolved'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  /// Removes the machine-readable payload block from a response so it is
  /// not shown to the user.
  static String stripPayload(String llmResponse) {
    final fenced = RegExp(
      r'```(?:json)?\s*\{[^{}]*\}\s*```',
      dotAll: true,
    ).firstMatch(llmResponse);
    if (fenced != null) {
      return llmResponse.replaceAll(fenced.group(0)!, '').trim();
    }
    final jsonText = _extractJsonBlock(llmResponse);
    if (jsonText == null) return llmResponse;
    final idx = llmResponse.lastIndexOf(jsonText);
    return (idx >= 0 ? llmResponse.substring(0, idx) : llmResponse).trim();
  }

  /// Pure derivation: turns a [ClarifyPayload] plus the current graph
  /// contents into a list of operations. No database access.
  static List<EpistemicOperation> derive(
    ClarifyPayload payload,
    List<EpistemicNode> existing,
  ) {
    final operations = <EpistemicOperation>[];

    if (payload.hasDisambiguation) {
      final match = _findByContent(existing, payload.surface!);
      operations.add(
        EpistemicOperation.disambiguate(
          content: payload.surface!,
          deeperContent: payload.deeper!,
          targetNodeId: match?.id,
        ),
      );
    }

    if (payload.hasResolution) {
      final match = _findByContent(existing, payload.resolved!);
      if (match != null && match.confidence < confidenceCeiling) {
        operations.add(
          EpistemicOperation.raiseConfidence(
            targetNodeId: match.id,
            confidenceDelta: confidenceStep,
          ),
        );
      }
    }

    return operations;
  }

  Future<void> _applyOne(EpistemicOperation op) async {
    switch (op.type) {
      case EpistemicOperationType.disambiguate:
        await _applyDisambiguate(op);
      case EpistemicOperationType.raiseConfidence:
        final node = await _graph.get(op.targetNodeId!);
        if (node == null) return;
        final raised = (node.confidence + op.confidenceDelta!).clamp(
          0.0,
          confidenceCeiling,
        );
        await _graph.update(node.copyWith(confidence: raised));
    }
  }

  Future<void> _applyDisambiguate(EpistemicOperation op) async {
    final surfaceId =
        op.targetNodeId ??
        (await _graph.create(
          EpistemicNode(content: op.content!, type: EpistemicNodeType.question),
        )).id;

    final existingDeeper = _findByContent(
      await _graph.all(),
      op.deeperContent!,
    );
    final deeperId =
        existingDeeper?.id ??
        (await _graph.create(
          EpistemicNode(
            content: op.deeperContent!,
            type: EpistemicNodeType.question,
          ),
        )).id;

    final edges = await _graph.getRelationshipsForNode(surfaceId);
    final alreadyLinked = edges.any(
      (e) =>
          e.type == EpistemicRelationshipType.refines &&
          e.sourceId == surfaceId &&
          e.targetId == deeperId,
    );
    if (!alreadyLinked && surfaceId != deeperId) {
      await _graph.addRelationship(
        EpistemicRelationship(
          sourceId: surfaceId,
          targetId: deeperId,
          type: EpistemicRelationshipType.refines,
        ),
      );
    }
  }

  static EpistemicNode? _findByContent(
    List<EpistemicNode> nodes,
    String content,
  ) {
    final needle = _normalize(content);
    for (final node in nodes) {
      final haystack = _normalize(node.content);
      if (haystack == needle || haystack.contains(needle)) return node;
    }
    return null;
  }

  static String? _extractJsonBlock(String text) {
    final fenced = RegExp(
      r'```(?:json)?\s*(\{[^{}]*\})\s*```',
      dotAll: true,
    ).firstMatch(text);
    if (fenced != null) return fenced.group(1);
    final bare = RegExp(r'\{[^{}]*\}').allMatches(text);
    if (bare.isEmpty) return null;
    final candidate = bare.last.group(0)!;
    return candidate.contains('"surface"') || candidate.contains('"deeper"')
        ? candidate
        : null;
  }
}
