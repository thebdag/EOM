import 'package:eom/models/epistemic_operation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClarifyOperation.fromJson', () {
    test('parses a full payload', () {
      final op = ClarifyOperation.fromJson({
        'clarified': 'I fear irrelevance, not failure.',
        'type': 'belief',
        'category': 'intuitive',
        'confidence': 0.8,
        'keywords': ['fear', 'failure'],
      });

      expect(op.clarified, 'I fear irrelevance, not failure.');
      expect(op.nodeType, 'belief');
      expect(op.category, 'intuitive');
      expect(op.confidence, 0.8);
      expect(op.keywords, ['fear', 'failure']);
    });

    test('applies defaults for missing optional fields', () {
      final op = ClarifyOperation.fromJson({'clarified': 'Clear now.'});

      expect(op.nodeType, 'belief');
      expect(op.category, isNull);
      expect(op.confidence, ClarifyOperation.defaultConfidence);
      expect(op.keywords, isEmpty);
    });

    test('throws FormatException when clarified is missing or blank', () {
      expect(() => ClarifyOperation.fromJson({}), throwsFormatException);
      expect(
        () => ClarifyOperation.fromJson({'clarified': '  '}),
        throwsFormatException,
      );
    });

    test('clamps out-of-range confidence', () {
      final op = ClarifyOperation.fromJson({
        'clarified': 'c',
        'confidence': 9.4,
      });

      expect(op.confidence, 1.0);
    });

    test('round-trips through toJson', () {
      const original = ClarifyOperation(
        clarified: 'Stillness is a skill.',
        nodeType: 'knowledge',
        category: 'rational',
        confidence: 0.75,
        keywords: ['stillness'],
      );

      final restored = ClarifyOperation.fromJson(original.toJson());

      expect(restored.clarified, original.clarified);
      expect(restored.nodeType, original.nodeType);
      expect(restored.category, original.category);
      expect(restored.confidence, original.confidence);
      expect(restored.keywords, original.keywords);
    });
  });

  group('CompressOperation.fromJson', () {
    test('parses a full payload', () {
      final op = CompressOperation.fromJson({
        'principle': 'Attention is the currency of thought.',
        'type': 'belief',
        'category': 'rational',
        'confidence': 0.7,
        'keywords': ['attention', 'thought'],
      });

      expect(op.principle, 'Attention is the currency of thought.');
      expect(op.nodeType, 'belief');
      expect(op.category, 'rational');
      expect(op.confidence, 0.7);
      expect(op.keywords, ['attention', 'thought']);
    });

    test('round-trips through toJson', () {
      const original = CompressOperation(
        principle: 'Stillness reveals signal.',
        nodeType: 'knowledge',
        category: 'intuitive',
        confidence: 0.6,
        keywords: ['stillness'],
      );

      final restored = CompressOperation.fromJson(original.toJson());

      expect(restored.principle, original.principle);
      expect(restored.nodeType, original.nodeType);
      expect(restored.category, original.category);
      expect(restored.confidence, original.confidence);
      expect(restored.keywords, original.keywords);
    });

    test('applies defaults for missing optional fields', () {
      final op = CompressOperation.fromJson({'principle': 'Less is more.'});

      expect(op.nodeType, 'knowledge');
      expect(op.category, isNull);
      expect(op.confidence, CompressOperation.defaultConfidence);
      expect(op.keywords, isEmpty);
    });

    test('throws FormatException when principle is missing or blank', () {
      expect(() => CompressOperation.fromJson({}), throwsFormatException);
      expect(
        () => CompressOperation.fromJson({'principle': '   '}),
        throwsFormatException,
      );
    });

    test('clamps out-of-range confidence', () {
      final high = CompressOperation.fromJson({
        'principle': 'p',
        'confidence': 1.7,
      });
      final low = CompressOperation.fromJson({
        'principle': 'p',
        'confidence': -2,
      });

      expect(high.confidence, 1.0);
      expect(low.confidence, 0.0);
    });

    test('falls back to default confidence for non-numeric values', () {
      final op = CompressOperation.fromJson({
        'principle': 'p',
        'confidence': 'high',
      });

      expect(op.confidence, CompressOperation.defaultConfidence);
    });

    test('filters non-string and blank keywords', () {
      final op = CompressOperation.fromJson({
        'principle': 'p',
        'keywords': ['focus', 42, '  ', null, 'calm'],
      });

      expect(op.keywords, ['focus', 'calm']);
    });

    test('normalises empty type and category strings', () {
      final op = CompressOperation.fromJson({
        'principle': 'p',
        'type': ' ',
        'category': '',
      });

      expect(op.nodeType, 'knowledge');
      expect(op.category, isNull);
    });
  });

  group('MapOperation.fromJson', () {
    test('parses label and relationships', () {
      final op = MapOperation.fromJson({
        'label': 'You',
        'children': [
          {'label': 'Focus'},
        ],
        'relationships': [
          {'source': 'Focus', 'target': 'Rest', 'type': 'supports'},
          {'source': 'Guilt', 'target': 'Rest', 'type': 'contradicts'},
        ],
      });

      expect(op.rootLabel, 'You');
      expect(op.relationships, hasLength(2));
      expect(op.relationships[0].source, 'Focus');
      expect(op.relationships[0].type, 'supports');
      expect(op.relationships[1].target, 'Rest');
    });

    test('defaults to "You" root and empty relationships', () {
      final op = MapOperation.fromJson({});

      expect(op.rootLabel, 'You');
      expect(op.relationships, isEmpty);
    });

    test('skips relationships with blank endpoints', () {
      final op = MapOperation.fromJson({
        'relationships': [
          {'source': '', 'target': 'Rest', 'type': 'supports'},
          {'source': 'Focus', 'type': 'supports'},
          'not-a-map',
          {'source': 'Focus', 'target': 'Rest'},
        ],
      });

      expect(op.relationships, hasLength(1));
      expect(op.relationships.single.type, 'supports');
    });

    test('round-trips through toJson', () {
      const original = MapOperation(
        rootLabel: 'Cluster',
        relationships: [
          MappedRelationship(source: 'A', target: 'B', type: 'refines'),
        ],
      );

      final restored = MapOperation.fromJson(original.toJson());

      expect(restored.rootLabel, original.rootLabel);
      expect(restored.relationships, hasLength(1));
      expect(restored.relationships.single.source, 'A');
      expect(restored.relationships.single.type, 'refines');
    });
  });

  group('ReflectOperation.fromJson', () {
    test('parses contradictions and low-confidence nodes', () {
      final op = ReflectOperation.fromJson({
        'contradictions': [
          {'statement': 'I need rest.', 'conflicts_with': 'Rest is laziness.'},
        ],
        'low_confidence': ['Maybe I am not cut out for this.'],
      });

      expect(op.contradictions, hasLength(1));
      expect(op.contradictions.single.statement, 'I need rest.');
      expect(op.contradictions.single.conflictsWith, 'Rest is laziness.');
      expect(op.lowConfidenceNodes, ['Maybe I am not cut out for this.']);
    });

    test('defaults to empty lists', () {
      final op = ReflectOperation.fromJson({});

      expect(op.contradictions, isEmpty);
      expect(op.lowConfidenceNodes, isEmpty);
    });

    test('skips contradictions with blank statements', () {
      final op = ReflectOperation.fromJson({
        'contradictions': [
          {'statement': ' ', 'conflicts_with': 'x'},
          'junk',
          {'statement': 'Real tension.'},
        ],
      });

      expect(op.contradictions, hasLength(1));
      expect(op.contradictions.single.conflictsWith, '');
    });

    test('round-trips through toJson', () {
      const original = ReflectOperation(
        contradictions: [Contradiction(statement: 'A', conflictsWith: 'B')],
        lowConfidenceNodes: ['C'],
      );

      final restored = ReflectOperation.fromJson(original.toJson());

      expect(restored.contradictions.single.statement, 'A');
      expect(restored.contradictions.single.conflictsWith, 'B');
      expect(restored.lowConfidenceNodes, ['C']);
    });
  });

  group('ActOperation.fromJson', () {
    test('parses a full payload', () {
      final op = ActOperation.fromJson({
        'actionable': 'Walking daily stabilises my focus.',
        'confidence': 0.85,
        'keywords': ['walking', 'focus'],
      });

      expect(op.actionable, 'Walking daily stabilises my focus.');
      expect(op.confidence, 0.85);
      expect(op.keywords, ['walking', 'focus']);
    });

    test('applies defaults for missing optional fields', () {
      final op = ActOperation.fromJson({'actionable': 'Ship it.'});

      expect(op.confidence, ActOperation.defaultConfidence);
      expect(op.keywords, isEmpty);
    });

    test('throws FormatException when actionable is missing or blank', () {
      expect(() => ActOperation.fromJson({}), throwsFormatException);
      expect(
        () => ActOperation.fromJson({'actionable': ''}),
        throwsFormatException,
      );
    });

    test('clamps out-of-range confidence', () {
      final op = ActOperation.fromJson({'actionable': 'a', 'confidence': -1});

      expect(op.confidence, 0.0);
    });

    test('round-trips through toJson', () {
      const original = ActOperation(
        actionable: 'Call the dentist.',
        confidence: 0.9,
        keywords: ['health'],
      );

      final restored = ActOperation.fromJson(original.toJson());

      expect(restored.actionable, original.actionable);
      expect(restored.confidence, original.confidence);
      expect(restored.keywords, original.keywords);
    });
  });
}
