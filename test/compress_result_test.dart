import 'package:eom/models/compress_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompressResult.fromJson', () {
    test('parses a full payload', () {
      final result = CompressResult.fromJson({
        'principle': 'Attention is the currency of thought.',
        'type': 'belief',
        'category': 'rational',
        'confidence': 0.7,
        'keywords': ['attention', 'thought'],
      });

      expect(result.principle, 'Attention is the currency of thought.');
      expect(result.nodeType, 'belief');
      expect(result.category, 'rational');
      expect(result.confidence, 0.7);
      expect(result.keywords, ['attention', 'thought']);
    });

    test('round-trips through toJson', () {
      const original = CompressResult(
        principle: 'Stillness reveals signal.',
        nodeType: 'knowledge',
        category: 'intuitive',
        confidence: 0.6,
        keywords: ['stillness'],
      );

      final restored = CompressResult.fromJson(original.toJson());

      expect(restored.principle, original.principle);
      expect(restored.nodeType, original.nodeType);
      expect(restored.category, original.category);
      expect(restored.confidence, original.confidence);
      expect(restored.keywords, original.keywords);
    });

    test('applies defaults for missing optional fields', () {
      final result = CompressResult.fromJson({'principle': 'Less is more.'});

      expect(result.nodeType, 'knowledge');
      expect(result.category, isNull);
      expect(result.confidence, CompressResult.defaultConfidence);
      expect(result.keywords, isEmpty);
    });

    test('throws FormatException when principle is missing or blank', () {
      expect(() => CompressResult.fromJson({}), throwsFormatException);
      expect(
        () => CompressResult.fromJson({'principle': '   '}),
        throwsFormatException,
      );
    });

    test('clamps out-of-range confidence', () {
      final high = CompressResult.fromJson({
        'principle': 'p',
        'confidence': 1.7,
      });
      final low = CompressResult.fromJson({'principle': 'p', 'confidence': -2});

      expect(high.confidence, 1.0);
      expect(low.confidence, 0.0);
    });

    test('falls back to default confidence for non-numeric values', () {
      final result = CompressResult.fromJson({
        'principle': 'p',
        'confidence': 'high',
      });

      expect(result.confidence, CompressResult.defaultConfidence);
    });

    test('filters non-string and blank keywords', () {
      final result = CompressResult.fromJson({
        'principle': 'p',
        'keywords': ['focus', 42, '  ', null, 'calm'],
      });

      expect(result.keywords, ['focus', 'calm']);
    });

    test('normalises empty type and category strings', () {
      final result = CompressResult.fromJson({
        'principle': 'p',
        'type': ' ',
        'category': '',
      });

      expect(result.nodeType, 'knowledge');
      expect(result.category, isNull);
    });
  });
}
