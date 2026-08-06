import 'package:eom/models/epistemic_node.dart';
import 'package:eom/models/epistemic_query_result.dart';
import 'package:eom/models/epistemic_relationship.dart';
import 'package:eom/theme/eom_colors.dart';
import 'package:eom/widgets/epistemic_graph_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

EpistemicNode node(String content, {double confidence = 0.5}) => EpistemicNode(
  content: content,
  type: EpistemicNodeType.belief,
  confidence: confidence,
);

EpistemicQueryResult graphOf(List<EpistemicNode> nodes) =>
    EpistemicQueryResult(rootId: nodes.first.id, nodes: nodes, edges: const []);

void main() {
  group('confidenceColor', () {
    test('lerps error → tertiary → sage across the range', () {
      expect(confidenceColor(0.0), EomColors.error);
      expect(confidenceColor(0.5), EomColors.textTertiary);
      expect(confidenceColor(1.0), EomColors.sageMuted);
    });

    test('clamps out-of-range input', () {
      expect(confidenceColor(-1), EomColors.error);
      expect(confidenceColor(2), EomColors.sageMuted);
    });
  });

  group('EpistemicGraphView', () {
    testWidgets('renders nothing for a single node', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EpistemicGraphView(graph: graphOf([node('A')]))),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(EpistemicGraphView),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    });

    testWidgets('paints when two or more nodes are present', (tester) async {
      final a = node('A');
      final b = node('B');
      final graph = EpistemicQueryResult(
        rootId: a.id,
        nodes: [a, b],
        edges: [
          EpistemicRelationship(
            sourceId: a.id,
            targetId: b.id,
            type: EpistemicRelationshipType.supports,
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EpistemicGraphView(graph: graph)),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(EpistemicGraphView),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('fades in over 300ms', (tester) async {
      final a = node('A');
      final b = node('B');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpistemicGraphView(
              graph: EpistemicQueryResult(
                rootId: a.id,
                nodes: [a, b],
                edges: const [],
              ),
            ),
          ),
        ),
      );
      var opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.0);
      await tester.pump(const Duration(milliseconds: 300));
      opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 1.0);
    });
  });
}
