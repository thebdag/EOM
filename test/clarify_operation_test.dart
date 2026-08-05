import 'package:eom/models/epistemic_node.dart';
import 'package:eom/models/epistemic_operation.dart';
import 'package:eom/services/clarify_operation.dart';
import 'package:flutter_test/flutter_test.dart';

EpistemicNode node(String id, String content, {double confidence = 0.5}) =>
    EpistemicNode(
      id: id,
      content: content,
      type: EpistemicNodeType.belief,
      confidence: confidence,
    );

void main() {
  group('ClarifyOperation.parsePayload', () {
    test('parses a fenced json block', () {
      const response =
          'Here is some visible text.\n'
          '```json\n'
          '{"surface": "I feel stuck", "deeper": "I fear failure", "resolved": null}\n'
          '```';
      final payload = ClarifyOperation.parsePayload(response);
      expect(payload, isNotNull);
      expect(payload!.surface, 'I feel stuck');
      expect(payload.deeper, 'I fear failure');
      expect(payload.resolved, isNull);
    });

    test('parses a bare trailing json object', () {
      const response =
          'Visible text. {"surface": "a", "deeper": "b", "resolved": "c"}';
      final payload = ClarifyOperation.parsePayload(response);
      expect(payload, isNotNull);
      expect(payload!.resolved, 'c');
    });

    test('returns null when no payload is present', () {
      expect(ClarifyOperation.parsePayload('just plain text'), isNull);
    });

    test('returns null on malformed json', () {
      const response = '```json {"surface": broken} ```';
      expect(ClarifyOperation.parsePayload(response), isNull);
    });

    test('ignores json objects without clarify keys', () {
      const response = 'Result: {"label": "You", "children": []}';
      expect(ClarifyOperation.parsePayload(response), isNull);
    });
  });

  group('ClarifyOperation.stripPayload', () {
    test('removes the fenced block and keeps visible text', () {
      const response =
          'Visible answer.\n```json {"surface": "a", "deeper": "b"}```';
      expect(ClarifyOperation.stripPayload(response), 'Visible answer.');
    });

    test('removes a bare trailing json object', () {
      const response = 'Visible answer. {"surface": "a", "deeper": "b"}';
      expect(ClarifyOperation.stripPayload(response), 'Visible answer.');
    });

    test('returns text unchanged when there is no payload', () {
      const response = 'Nothing to strip.';
      expect(ClarifyOperation.stripPayload(response), response);
    });
  });

  group('ClarifyOperation.derive', () {
    test('derives a disambiguation for a fresh surface/deeper pair', () {
      const payload = ClarifyPayload(
        surface: 'I feel stuck',
        deeper: 'I fear failure',
      );
      final ops = ClarifyOperation.derive(payload, const []);
      expect(ops, hasLength(1));
      expect(ops.single.type, EpistemicOperationType.disambiguate);
      expect(ops.single.content, 'I feel stuck');
      expect(ops.single.deeperContent, 'I fear failure');
      expect(ops.single.targetNodeId, isNull);
    });

    test('reuses an existing node matching the surface text', () {
      final existing = [node('n1', 'I feel stuck')];
      const payload = ClarifyPayload(
        surface: 'i feel   stuck',
        deeper: 'I fear failure',
      );
      final ops = ClarifyOperation.derive(payload, existing);
      expect(ops.single.targetNodeId, 'n1');
    });

    test('skips disambiguation when surface equals deeper', () {
      const payload = ClarifyPayload(surface: 'same', deeper: '  Same ');
      expect(ClarifyOperation.derive(payload, const []), isEmpty);
    });

    test('derives a confidence raise for a resolved belief', () {
      final existing = [node('n1', 'Kindness is fundamental')];
      const payload = ClarifyPayload(resolved: 'kindness is fundamental');
      final ops = ClarifyOperation.derive(payload, existing);
      expect(ops, hasLength(1));
      expect(ops.single.type, EpistemicOperationType.raiseConfidence);
      expect(ops.single.targetNodeId, 'n1');
      expect(ops.single.confidenceDelta, ClarifyOperation.confidenceStep);
    });

    test('matches a resolved belief contained in a longer node', () {
      final existing = [node('n1', 'I believe that kindness is fundamental')];
      const payload = ClarifyPayload(resolved: 'kindness is fundamental');
      final ops = ClarifyOperation.derive(payload, existing);
      expect(ops.single.targetNodeId, 'n1');
    });

    test('does not raise beyond the confidence ceiling', () {
      final existing = [
        node(
          'n1',
          'Kindness is fundamental',
          confidence: ClarifyOperation.confidenceCeiling,
        ),
      ];
      const payload = ClarifyPayload(resolved: 'kindness is fundamental');
      expect(ClarifyOperation.derive(payload, existing), isEmpty);
    });

    test('derives nothing when resolved matches no node', () {
      const payload = ClarifyPayload(resolved: 'no such belief');
      expect(ClarifyOperation.derive(payload, const []), isEmpty);
    });

    test('derives both operations from a full payload', () {
      final existing = [node('n1', 'Kindness is fundamental')];
      const payload = ClarifyPayload(
        surface: 'I feel stuck',
        deeper: 'I fear failure',
        resolved: 'kindness is fundamental',
      );
      final ops = ClarifyOperation.derive(payload, existing);
      expect(ops, hasLength(2));
      expect(ops[0].type, EpistemicOperationType.disambiguate);
      expect(ops[1].type, EpistemicOperationType.raiseConfidence);
    });
  });
}
