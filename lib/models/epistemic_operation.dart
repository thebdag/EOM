import 'epistemic_node.dart';

/// The kinds of mutation an intent can perform on the epistemic graph.
///
/// Each cognitive intent maps to one or more operation types (EOM-T6..T10):
///
/// - [disambiguate]    — Split a fuzzy statement into a surface node and a
///                       deeper node, linked by a `refines` edge (Clarify).
/// - [raiseConfidence] — Increase the confidence of an existing node after
///                       an exchange has resolved it (Clarify).
enum EpistemicOperationType { disambiguate, raiseConfidence }

/// A single, atomic mutation proposed against the epistemic graph.
///
/// Operations are pure value objects: an `IntentOperation` implementation
/// (e.g. `ClarifyOperation`) *derives* them from an LLM response and then
/// *applies* them via `EpistemicService`. Keeping them free of service
/// references makes the derivation logic unit-testable without a database.
class EpistemicOperation {
  /// A disambiguation: ensure [content] (the surface concern) and
  /// [deeperContent] (the deeper current) exist as nodes, with the deeper
  /// node refining the surface one.
  ///
  /// [targetNodeId] is the existing node matching [content], if any — when
  /// null, a new node is created on apply.
  const EpistemicOperation.disambiguate({
    required String content,
    required String deeperContent,
    String? targetNodeId,
  }) : this._(
         type: EpistemicOperationType.disambiguate,
         content: content,
         deeperContent: deeperContent,
         targetNodeId: targetNodeId,
       );

  /// A confidence raise on the existing node [targetNodeId].
  const EpistemicOperation.raiseConfidence({
    required String targetNodeId,
    required double confidenceDelta,
  }) : this._(
         type: EpistemicOperationType.raiseConfidence,
         targetNodeId: targetNodeId,
         confidenceDelta: confidenceDelta,
       );

  const EpistemicOperation._({
    required this.type,
    this.targetNodeId,
    this.content,
    this.deeperContent,
    this.confidenceDelta,
  });

  /// What kind of mutation this operation performs.
  final EpistemicOperationType type;

  /// The existing node this operation targets, if one was matched during
  /// derivation. Null means apply must create a new node.
  final String? targetNodeId;

  /// Disambiguate only: the surface concern text.
  final String? content;

  /// Disambiguate only: the deeper current text.
  final String? deeperContent;

  /// RaiseConfidence only: how much to add to the node's confidence.
  /// Callers must clamp the result; see [EpistemicNode.confidence].
  final double? confidenceDelta;

  @override
  String toString() =>
      'EpistemicOperation(type: ${type.name}, targetNodeId: $targetNodeId, '
      'content: "$content", deeperContent: "$deeperContent", '
      'confidenceDelta: $confidenceDelta)';
}
