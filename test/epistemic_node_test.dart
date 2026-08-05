import 'package:flutter_test/flutter_test.dart';
import 'package:eom/models/epistemic_node.dart';

void main() {
  // ── EpistemicNodeType helpers ───────────────────────────────────────────────

  group('epistemicNodeTypeFromString', () {
    test('round-trips every valid type name', () {
      for (final type in EpistemicNodeType.values) {
        expect(epistemicNodeTypeFromString(type.name), type);
      }
    });

    test('throws ArgumentError for unknown type string', () {
      expect(
        () => epistemicNodeTypeFromString('nonsense'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('is case-sensitive — "Belief" is not valid', () {
      expect(
        () => epistemicNodeTypeFromString('Belief'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ── Construction ────────────────────────────────────────────────────────────

  group('EpistemicNode construction', () {
    test('assigns a UUID when id is omitted', () {
      final a = EpistemicNode(content: 'test', type: EpistemicNodeType.belief);
      final b = EpistemicNode(content: 'test', type: EpistemicNodeType.belief);
      expect(a.id, isNotEmpty);
      expect(a.id, isNot(equals(b.id)));
    });

    test('preserves a supplied id', () {
      final node = EpistemicNode(
        id: 'fixed-id',
        content: 'c',
        type: EpistemicNodeType.question,
      );
      expect(node.id, 'fixed-id');
    });

    test('defaults confidence to 0.5', () {
      final node = EpistemicNode(
        content: 'c',
        type: EpistemicNodeType.hypothesis,
      );
      expect(node.confidence, 0.5);
    });

    test('accepts explicit confidence values', () {
      final node = EpistemicNode(
        content: 'c',
        type: EpistemicNodeType.knowledge,
        confidence: 0.95,
      );
      expect(node.confidence, 0.95);
    });

    test('sourceType and sourceTimestamp default to null', () {
      final node = EpistemicNode(
        content: 'c',
        type: EpistemicNodeType.intuition,
      );
      expect(node.sourceType, isNull);
      expect(node.sourceTimestamp, isNull);
    });
  });

  // ── JSON round-trip ─────────────────────────────────────────────────────────

  group('toJson / fromJson', () {
    EpistemicNode make(EpistemicNodeType type) => EpistemicNode(
      id: 'test-$type',
      content: 'content for $type',
      type: type,
      confidence: 0.7,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );

    test('round-trips all six node types', () {
      for (final type in EpistemicNodeType.values) {
        final original = make(type);
        final roundTripped = EpistemicNode.fromJson(original.toJson());

        expect(roundTripped.id, original.id);
        expect(roundTripped.content, original.content);
        expect(roundTripped.type, original.type);
        expect(roundTripped.confidence, original.confidence);
        expect(roundTripped.createdAt, original.createdAt);
        expect(roundTripped.updatedAt, original.updatedAt);
        expect(roundTripped.sourceType, isNull);
        expect(roundTripped.sourceTimestamp, isNull);
      }
    });

    test('round-trips provenance stub fields when set', () {
      final ts = DateTime(2025, 6, 15, 10, 30);
      final original = EpistemicNode(
        id: 'prov-id',
        content: 'I experienced this.',
        type: EpistemicNodeType.belief,
        sourceType: 'experience',
        sourceTimestamp: ts,
      );
      final rt = EpistemicNode.fromJson(original.toJson());
      expect(rt.sourceType, 'experience');
      expect(rt.sourceTimestamp, ts);
    });

    test('type is serialised as camelCase string', () {
      final json = EpistemicNode(
        content: 'x',
        type: EpistemicNodeType.knowledge,
      ).toJson();
      expect(json['type'], 'knowledge');
    });

    test('fromJson throws ArgumentError for invalid type', () {
      final bad = {
        'id': 'x',
        'content': 'c',
        'type': 'INVALID',
        'confidence': 0.5,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'source_type': null,
        'source_timestamp': null,
      };
      expect(() => EpistemicNode.fromJson(bad), throwsA(isA<ArgumentError>()));
    });
  });

  // ── copyWith ────────────────────────────────────────────────────────────────

  group('copyWith', () {
    final base = EpistemicNode(
      id: 'base-id',
      content: 'original',
      type: EpistemicNodeType.hypothesis,
      confidence: 0.4,
      createdAt: DateTime(2026),
    );

    test('preserves unchanged fields', () {
      final copy = base.copyWith(content: 'updated');
      expect(copy.id, 'base-id');
      expect(copy.type, EpistemicNodeType.hypothesis);
      expect(copy.confidence, 0.4);
      expect(copy.createdAt, DateTime(2026));
    });

    test('replaces specified fields', () {
      final copy = base.copyWith(
        content: 'new content',
        type: EpistemicNodeType.knowledge,
        confidence: 0.9,
      );
      expect(copy.content, 'new content');
      expect(copy.type, EpistemicNodeType.knowledge);
      expect(copy.confidence, 0.9);
    });

    test('updates updatedAt when not specified', () {
      final before = DateTime.now();
      final copy = base.copyWith(content: 'changed');
      expect(
        copy.updatedAt.isAfter(before) || copy.updatedAt == before,
        isTrue,
      );
    });
  });

  // ── Equality ────────────────────────────────────────────────────────────────

  group('equality', () {
    test('two nodes with the same id are equal', () {
      final a = EpistemicNode(
        id: 'same',
        content: 'a',
        type: EpistemicNodeType.belief,
      );
      final b = EpistemicNode(
        id: 'same',
        content: 'b',
        type: EpistemicNodeType.question,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('two nodes with different ids are not equal', () {
      final a = EpistemicNode(content: 'a', type: EpistemicNodeType.belief);
      final b = EpistemicNode(content: 'a', type: EpistemicNodeType.belief);
      expect(a, isNot(equals(b)));
    });
  });
}
