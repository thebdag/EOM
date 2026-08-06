import 'package:eom/models/epistemic_relationship.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('epistemicRelationshipTypeTryParse (EOM-S14)', () {
    test('parses exact enum names', () {
      for (final type in EpistemicRelationshipType.values) {
        expect(epistemicRelationshipTypeTryParse(type.name), type);
      }
    });

    test('parses kebab-case LLM output', () {
      expect(
        epistemicRelationshipTypeTryParse('is-example-of'),
        EpistemicRelationshipType.isExampleOf,
      );
    });

    test('returns null for unknown values', () {
      expect(epistemicRelationshipTypeTryParse('nope'), isNull);
    });

    test('fromString throws ArgumentError for unknown values', () {
      expect(
        () => epistemicRelationshipTypeFromString('nope'),
        throwsArgumentError,
      );
    });
  });

  group('EpistemicRelationship', () {
    test('constructs with a generated UUID if omitted', () {
      final rel = EpistemicRelationship(
        sourceId: 'src-1',
        targetId: 'tgt-1',
        type: EpistemicRelationshipType.entails,
      );
      expect(rel.id, isNotEmpty);
      expect(rel.sourceId, 'src-1');
      expect(rel.targetId, 'tgt-1');
      expect(rel.type, EpistemicRelationshipType.entails);
    });

    test('serialises and deserialises to/from JSON', () {
      final orig = EpistemicRelationship(
        id: '123',
        sourceId: 'abc',
        targetId: 'def',
        type: EpistemicRelationshipType.contradicts,
      );

      final json = orig.toJson();
      expect(json['id'], '123');
      expect(json['source_id'], 'abc');
      expect(json['target_id'], 'def');
      expect(json['type'], 'contradicts');
      expect(json['created_at'], isNotEmpty);

      final restored = EpistemicRelationship.fromJson(json);
      expect(restored.id, orig.id);
      expect(restored.sourceId, orig.sourceId);
      expect(restored.targetId, orig.targetId);
      expect(restored.type, orig.type);
      expect(restored.createdAt, orig.createdAt);
      expect(restored, equals(orig));
    });

    test('copyWith replaces specified fields', () {
      final orig = EpistemicRelationship(
        sourceId: 'a',
        targetId: 'b',
        type: EpistemicRelationshipType.supports,
      );

      final modified = orig.copyWith(
        sourceId: 'c',
        type: EpistemicRelationshipType.undermines,
      );

      expect(modified.id, orig.id);
      expect(modified.sourceId, 'c');
      expect(modified.targetId, 'b');
      expect(modified.type, EpistemicRelationshipType.undermines);
      expect(modified.createdAt, orig.createdAt);
    });
  });

  group('epistemicRelationshipTypeFromString', () {
    test('parses valid strings', () {
      expect(
        epistemicRelationshipTypeFromString('entails'),
        EpistemicRelationshipType.entails,
      );
      expect(
        epistemicRelationshipTypeFromString('isExampleOf'),
        EpistemicRelationshipType.isExampleOf,
      );
    });

    test('throws ArgumentError on invalid string', () {
      expect(
        () => epistemicRelationshipTypeFromString('nonsense'),
        throwsArgumentError,
      );
    });
  });
}
