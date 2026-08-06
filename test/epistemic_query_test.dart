import 'package:eom/models/epistemic_node.dart';
import 'package:eom/models/epistemic_relationship.dart';
import 'package:eom/services/epistemic_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/in_memory_epistemic_store.dart';

EpistemicNode node(String content) =>
    EpistemicNode(content: content, type: EpistemicNodeType.belief);

EpistemicRelationship edge(String sourceId, String targetId) =>
    EpistemicRelationship(
      sourceId: sourceId,
      targetId: targetId,
      type: EpistemicRelationshipType.supports,
    );

void main() {
  group('sanitizeFtsQuery', () {
    test('quotes plain tokens and ANDs them', () {
      expect(sanitizeFtsQuery('stoic virtue'), '"stoic" "virtue"');
    });

    test('strips punctuation that would break FTS5 syntax', () {
      expect(
        sanitizeFtsQuery('what do I know about X?'),
        '"what" "do" "I" "know" "about" "X"',
      );
    });

    test('neutralises FTS operators in user input', () {
      // Quoted tokens are literal in FTS5 — "OR"/"NEAR" lose operator meaning.
      expect(
        sanitizeFtsQuery('kindness OR cruelty NEAR/3 death'),
        '"kindness" "OR" "cruelty" "NEAR3" "death"',
      );
      expect(sanitizeFtsQuery('"unmatched paren ('), '"unmatched" "paren"');
    });

    test('returns empty string for blank or fully-stripped input', () {
      expect(sanitizeFtsQuery(''), '');
      expect(sanitizeFtsQuery('   '), '');
      expect(sanitizeFtsQuery('?!... '), '');
    });
  });

  group('traverse', () {
    late InMemoryStore store;

    setUp(() => store = InMemoryStore());

    test('returns empty result when the root does not exist', () async {
      final result = await store.traverse('missing');
      expect(result.isEmpty, isTrue);
      expect(result.nodes, isEmpty);
      expect(result.edges, isEmpty);
    });

    test('visits neighbours breadth-first up to the depth limit', () async {
      final a = node('A');
      final b = node('B');
      final c = node('C');
      store.nodes.addAll([a, b, c]);
      store.edges.addAll([edge(a.id, b.id), edge(b.id, c.id)]);

      final result = await store.traverse(a.id, depth: 1);
      expect(result.nodes.map((n) => n.content), ['A', 'B']);
      expect(result.edges, hasLength(1));
    });

    test('is cycle-safe and reports each edge once', () async {
      final a = node('A');
      final b = node('B');
      final c = node('C');
      store.nodes.addAll([a, b, c]);
      store.edges.addAll([
        edge(a.id, b.id),
        edge(b.id, c.id),
        edge(c.id, a.id), // closes the cycle
      ]);

      final result = await store.traverse(a.id, depth: 5);
      expect(result.nodes, hasLength(3));
      expect(result.edges, hasLength(3));
    });

    test('treats edges as undirected', () async {
      final a = node('A');
      final b = node('B');
      store.nodes.addAll([a, b]);
      store.edges.add(edge(b.id, a.id)); // points B → A

      final result = await store.traverse(a.id, depth: 1);
      expect(result.nodes, hasLength(2));
    });

    test('skips edges to missing nodes without failing', () async {
      final a = node('A');
      store.nodes.add(a);
      store.edges.add(edge(a.id, 'ghost'));

      final result = await store.traverse(a.id, depth: 2);
      expect(result.nodes.single.content, 'A');
      expect(result.edges, hasLength(1));
    });
  });

  group('search (in-memory fake)', () {
    test('matches case-insensitive substrings', () async {
      final store = InMemoryStore();
      store.nodes.addAll([
        node('Kindness is fundamental.'),
        node('Stoicism teaches detachment.'),
      ]);
      final hits = await store.search('kindness');
      expect(hits.single.content, contains('Kindness'));
    });
  });
}
