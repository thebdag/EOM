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

  // ── ProvenanceSource helpers ────────────────────────────────────────────────

  group('provenanceSourceFromString', () {
    test('round-trips every valid source name', () {
      for (final source in ProvenanceSource.values) {
        expect(provenanceSourceFromString(source.name), source);
      }
    });

    test('throws ArgumentError for unknown source string', () {
      expect(
        () => provenanceSourceFromString('nonsense'),
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

    test('provenance defaults to null', () {
      final node = EpistemicNode(
        content: 'c',
        type: EpistemicNodeType.intuition,
      );
      expect(node.provenance, isNull);
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
        expect(roundTripped.provenance, isNull);
      }
    });

    test('round-trips provenance field when set', () {
      final ts = DateTime(2025, 6, 15, 10, 30);
      final original = EpistemicNode(
        id: 'prov-id',
        content: 'I experienced this.',
        type: EpistemicNodeType.belief,
        provenance: ProvenanceRecord(source: ProvenanceSource.experience, timestamp: ts),
      );
      final rt = EpistemicNode.fromJson(original.toJson());
      expect(rt.provenance?.source, ProvenanceSource.experience);
      expect(rt.provenance?.timestamp, ts);
      expect(rt.provenance, equals(original.provenance));
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
      final prov = ProvenanceRecord(source: ProvenanceSource.reasoning, timestamp: DateTime(2026));
      final copy = base.copyWith(
        content: 'new content',
        type: EpistemicNodeType.knowledge,
        confidence: 0.9,
        provenance: prov,
      );
      expect(copy.content, 'new content');
      expect(copy.type, EpistemicNodeType.knowledge);
      expect(copy.confidence, 0.9);
      expect(copy.provenance, prov);
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

  // ── ProvenanceRecord Equality ───────────────────────────────────────────────

  group('ProvenanceRecord equality', () {
    test('records with same values are equal', () {
      final a = ProvenanceRecord(source: ProvenanceSource.intuition, timestamp: DateTime(2026));
      final b = ProvenanceRecord(source: ProvenanceSource.intuition, timestamp: DateTime(2026));
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('records with different values are not equal', () {
      final a = ProvenanceRecord(source: ProvenanceSource.intuition, timestamp: DateTime(2026));
      final b = ProvenanceRecord(source: ProvenanceSource.reasoning, timestamp: DateTime(2026));
      expect(a, isNot(equals(b)));
    });
  });
}
