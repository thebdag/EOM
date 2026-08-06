import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/epistemic_query_result.dart';
import '../theme/eom_colors.dart';

/// Maps a confidence value in [0, 1] to a node colour (EOM-T18).
///
/// Low confidence trends toward [EomColors.error], neutral sits at
/// [EomColors.textTertiary], high confidence resolves to [EomColors.sageMuted] —
/// all palette tokens, no hardcoded hues.
Color confidenceColor(double confidence) {
  final c = confidence.clamp(0.0, 1.0);
  if (c < 0.5) {
    return Color.lerp(EomColors.error, EomColors.textTertiary, c * 2)!;
  }
  return Color.lerp(
    EomColors.textTertiary,
    EomColors.sageMuted,
    (c - 0.5) * 2,
  )!;
}

/// Renders an epistemic subgraph as a static radial overlay (EOM-T18).
///
/// The root node sits at the centre; each BFS depth forms a concentric
/// ring. Layout is deterministic — no physics, no springs — matching the
/// "Epistemic Calm" motion standard. Nodes are coloured by confidence via
/// [confidenceColor]; edges are 0.5px [EomColors.surfaceBorder] strokes.
///
/// Renders nothing when fewer than two nodes are present. Fades in over
/// 300ms with [Curves.easeOut].
class EpistemicGraphView extends StatelessWidget {
  const EpistemicGraphView({super.key, required this.graph});

  final EpistemicQueryResult graph;

  static const double height = 260;

  @override
  Widget build(BuildContext context) {
    if (graph.nodes.length < 2) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: EomColors.surface,
          border: Border.all(color: EomColors.surfaceBorder, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) => CustomPaint(
            size: Size(constraints.maxWidth, height),
            painter: _EpistemicGraphPainter(graph),
          ),
        ),
      ),
    );
  }
}

class _EpistemicGraphPainter extends CustomPainter {
  _EpistemicGraphPainter(this.graph);

  final EpistemicQueryResult graph;

  static const double _nodeRadius = 9;
  static const double _labelWidth = 96;

  /// BFS depth per node from the root (undirected). Unreached nodes are
  /// placed one ring beyond the furthest reached depth.
  Map<String, int> _depths() {
    final depth = <String, int>{};
    final adjacency = <String, List<String>>{};
    for (final e in graph.edges) {
      adjacency.putIfAbsent(e.sourceId, () => []).add(e.targetId);
      adjacency.putIfAbsent(e.targetId, () => []).add(e.sourceId);
    }
    var frontier = [graph.rootId];
    var level = 0;
    while (frontier.isNotEmpty) {
      final next = <String>[];
      for (final id in frontier) {
        if (depth.containsKey(id)) continue;
        depth[id] = level;
        next.addAll(adjacency[id] ?? const []);
      }
      frontier = next;
      level++;
    }
    final fallback = level;
    for (final n in graph.nodes) {
      depth.putIfAbsent(n.id, () => fallback);
    }
    return depth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final depths = _depths();
    final maxDepth = depths.values.fold(0, math.max);
    final ringGap =
        (math.min(size.width, size.height) / 2 - _nodeRadius * 3) /
        math.max(maxDepth, 1);

    // Position: root at centre, each ring evenly spaced by BFS order.
    final positions = <String, Offset>{};
    final byRing = <int, List<String>>{};
    for (final n in graph.nodes) {
      byRing.putIfAbsent(depths[n.id]!, () => []).add(n.id);
    }
    byRing.forEach((depth, ids) {
      if (depth == 0) {
        positions[ids.first] = centre;
        // Defensive: multiple depth-0 entries shouldn't happen, but never
        // crash a paint over it.
        for (var i = 1; i < ids.length; i++) {
          positions[ids[i]] = centre + Offset(_nodeRadius * 3.0 * i, 0);
        }
        return;
      }
      final radius = ringGap * depth;
      for (var i = 0; i < ids.length; i++) {
        final angle = (2 * math.pi * i / ids.length) - math.pi / 2;
        positions[ids[i]] =
            centre + Offset(radius * math.cos(angle), radius * math.sin(angle));
      }
    });

    // Edges first so nodes paint over the line ends.
    final edgePaint = Paint()
      ..color = EomColors.surfaceBorder
      ..strokeWidth = 0.5;
    for (final e in graph.edges) {
      final a = positions[e.sourceId];
      final b = positions[e.targetId];
      if (a == null || b == null) continue;
      canvas.drawLine(a, b, edgePaint);
    }

    final nodeById = {for (final n in graph.nodes) n.id: n};
    for (final entry in positions.entries) {
      final node = nodeById[entry.key];
      if (node == null) continue;
      final fill = Paint()..color = confidenceColor(node.confidence);
      canvas.drawCircle(entry.value, _nodeRadius, fill);
      canvas.drawCircle(
        entry.value,
        _nodeRadius,
        Paint()
          ..color = EomColors.surfaceBorder
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
      _paintLabel(canvas, entry.value, node.content);
    }
  }

  void _paintLabel(Canvas canvas, Offset at, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: EomColors.textSecondary, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: _labelWidth);
    painter.paint(canvas, at + Offset(-painter.width / 2, _nodeRadius + 3));
  }

  @override
  bool shouldRepaint(_EpistemicGraphPainter oldDelegate) =>
      oldDelegate.graph != graph;
}
