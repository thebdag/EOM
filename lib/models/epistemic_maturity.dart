import 'epistemic_node.dart';

/// Confidence at or above which a node counts as *high-confidence*.
const double kMaturityHighThreshold = 0.7;

/// Confidence below which a node counts as *uncertain*.
const double kMaturityUncertainThreshold = 0.4;

/// Maturity of one epistemic domain (EOM-T16).
///
/// Domains are keyed by [EpistemicCategory] (the "how the mind produced it"
/// axis) for v1 — no schema change. Nodes with no category are grouped
/// under the `null` domain.
///
/// [score] is the ratio of high-confidence nodes to all *decided* nodes
/// (high + uncertain), normalised to [0, 1]. Nodes in the neutral band
/// between the thresholds count toward [total] but not the ratio. [score]
/// is null when the domain has no decided nodes — insufficient signal
/// rather than 0% maturity.
class EpistemicMaturity {
  const EpistemicMaturity({
    required this.domain,
    required this.total,
    required this.highConfidence,
    required this.uncertain,
  });

  /// The domain these counts describe; null = uncategorised nodes.
  final EpistemicCategory? domain;

  /// All nodes in the domain, including the neutral band.
  final int total;

  /// Nodes with confidence ≥ [kMaturityHighThreshold].
  final int highConfidence;

  /// Nodes with confidence < [kMaturityUncertainThreshold].
  final int uncertain;

  /// high / (high + uncertain), or null when both are zero.
  double? get score {
    final decided = highConfidence + uncertain;
    if (decided == 0) return null;
    return highConfidence / decided;
  }

  @override
  String toString() =>
      'EpistemicMaturity(${domain?.name ?? "uncategorised"}: '
      '$highConfidence high / $uncertain uncertain / $total total)';
}

/// Groups [nodes] by category and computes per-domain maturity (EOM-T16).
///
/// Thresholds default to [kMaturityHighThreshold] /
/// [kMaturityUncertainThreshold]. Domains are returned with the
/// categorised domains first (enum order), uncategorised last.
Map<EpistemicCategory?, EpistemicMaturity> computeMaturityByDomain(
  Iterable<EpistemicNode> nodes, {
  double highThreshold = kMaturityHighThreshold,
  double uncertainThreshold = kMaturityUncertainThreshold,
}) {
  final totals = <EpistemicCategory?, int>{};
  final highs = <EpistemicCategory?, int>{};
  final uncertains = <EpistemicCategory?, int>{};

  for (final node in nodes) {
    final domain = node.category;
    totals[domain] = (totals[domain] ?? 0) + 1;
    if (node.confidence >= highThreshold) {
      highs[domain] = (highs[domain] ?? 0) + 1;
    } else if (node.confidence < uncertainThreshold) {
      uncertains[domain] = (uncertains[domain] ?? 0) + 1;
    }
  }

  final result = <EpistemicCategory?, EpistemicMaturity>{};
  for (final domain in [...EpistemicCategory.values, null]) {
    final total = totals[domain] ?? 0;
    if (total == 0) continue;
    result[domain] = EpistemicMaturity(
      domain: domain,
      total: total,
      highConfidence: highs[domain] ?? 0,
      uncertain: uncertains[domain] ?? 0,
    );
  }
  return result;
}
