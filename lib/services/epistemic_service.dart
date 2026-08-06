import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../models/epistemic_node.dart';
import '../models/epistemic_query_result.dart';
import '../models/epistemic_relationship.dart';

/// Sanitises free-text input into a safe FTS5 MATCH expression (EOM-T17).
///
/// Each whitespace-separated token is stripped of non-alphanumeric
/// characters and wrapped in double quotes, which neutralises FTS5
/// operators (`AND`, `OR`, `NEAR`, parentheses, quotes) in user input.
/// Quoted tokens are implicitly ANDed by FTS5.
///
/// Returns an empty string when nothing searchable remains; callers should
/// treat that as "no query" rather than passing it to MATCH.
String sanitizeFtsQuery(String raw) {
  final cleaned = raw
      .trim()
      .split(RegExp(r'\s+'))
      .map((t) => t.replaceAll(RegExp(r'[^\p{L}\p{N}_-]', unicode: true), ''))
      .where((t) => t.isNotEmpty);
  if (cleaned.isEmpty) return '';
  return cleaned.map((t) => '"$t"').join(' ');
}

/// Read/write surface of the epistemic graph used by intent-integration
/// services (EOM-T7) and domain queries (EOM-T17).
/// Implemented by [EpistemicService]; faked in tests.
abstract class EpistemicGraphStore {
  Future<EpistemicNode> create(EpistemicNode node);
  Future<EpistemicNode> upsert(EpistemicNode node);
  Future<EpistemicNode?> get(String id);
  Future<List<EpistemicNode>> all();
  Future<List<EpistemicNode>> byType(EpistemicNodeType type);
  Future<EpistemicRelationship> addRelationship(
    EpistemicRelationship relationship,
  );
  Future<List<EpistemicRelationship>> getRelationshipsForNode(String nodeId);

  /// Full-text search over node content, best match first (EOM-T17).
  ///
  /// [query] is free text ("what do I know about X"); implementations must
  /// not let it error out on punctuation or FTS operator syntax.
  Future<List<EpistemicNode>> search(String query);

  /// Breadth-first traversal from [nodeId] up to [depth] hops (EOM-T17).
  ///
  /// Cycle-safe: each node is visited once; each edge is reported once.
  /// Edges are treated as undirected for traversal purposes. A missing root
  /// yields an empty result rather than an error.
  ///
  /// Concrete default built on [get] and [getRelationshipsForNode] so the
  /// SQLite service and in-memory test fakes share identical semantics.
  Future<EpistemicQueryResult> traverse(String nodeId, {int depth = 2}) async {
    final visited = <String>{};
    final nodes = <EpistemicNode>[];
    final edges = <EpistemicRelationship>[];
    final seenEdgeIds = <String>{};

    var frontier = [nodeId];
    var level = 0;
    while (frontier.isNotEmpty && level <= depth) {
      final next = <String>[];
      for (final id in frontier) {
        if (!visited.add(id)) continue;
        final node = await get(id);
        if (node == null) continue;
        nodes.add(node);
        if (level == depth) continue;
        for (final rel in await getRelationshipsForNode(id)) {
          if (seenEdgeIds.add(rel.id)) edges.add(rel);
          final neighbour = rel.sourceId == id ? rel.targetId : rel.sourceId;
          if (!visited.contains(neighbour)) next.add(neighbour);
        }
      }
      frontier = next;
      level++;
    }
    return EpistemicQueryResult(rootId: nodeId, nodes: nodes, edges: edges);
  }
}

/// SQLite-backed service for the epistemic graph.
///
/// Owns the `epistemic_nodes` and `epistemic_edges` tables plus an FTS5
/// index (`epistemic_nodes_fts`) backing the EOM-T17 query API.
///
/// **Thread safety:** [sqflite] serialises writes internally; no additional
/// locking is required from callers.
///
/// Usage:
/// ```dart
/// final service = EpistemicService();
/// await service.init();
/// final node = await service.create(
///   EpistemicNode(content: 'I believe kindness is fundamental.', type: EpistemicNodeType.belief),
/// );
/// ```
class EpistemicService extends EpistemicGraphStore {
  static const _dbFileName = 'epistemic.db';
  static const _tableNodes = 'epistemic_nodes';
  static const _tableEdges = 'epistemic_edges';
  static const _tableFts = 'epistemic_nodes_fts';

  Database? _db;

  /// Opens (or creates) the SQLite database and runs DDL migrations.
  ///
  /// Must be called once before any other method. Safe to call multiple times —
  /// subsequent calls are no-ops if the database is already open.
  Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$_dbFileName';
    _db = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableNodes (
        id               TEXT PRIMARY KEY,
        content          TEXT NOT NULL,
        type             TEXT NOT NULL CHECK(type IN (
                           'belief','knowledge','hypothesis',
                           'intuition','question','unknown')),
        confidence       REAL NOT NULL DEFAULT 0.5
                           CHECK(confidence BETWEEN 0.0 AND 1.0),
        source_type      TEXT,
        source_timestamp TEXT,
        category         TEXT CHECK(category IN (
                           'empirical','rational','intuitive',
                           'abductive','revelatory')),
        created_at       TEXT NOT NULL,
        updated_at       TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableEdges (
        id               TEXT PRIMARY KEY,
        source_id        TEXT NOT NULL,
        target_id        TEXT NOT NULL,
        type             TEXT NOT NULL,
        created_at       TEXT NOT NULL,
        FOREIGN KEY (source_id) REFERENCES $_tableNodes (id) ON DELETE CASCADE,
        FOREIGN KEY (target_id) REFERENCES $_tableNodes (id) ON DELETE CASCADE
      )
    ''');

    await _createFts(db);
  }

  /// Creates the FTS5 index over node content plus the triggers that keep
  /// it in sync with `epistemic_nodes` (EOM-T17).
  static Future<void> _createFts(Database db) async {
    await db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS $_tableFts USING fts5(
        content,
        node_id UNINDEXED
      )
    ''');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS ${_tableNodes}_fts_ai
      AFTER INSERT ON $_tableNodes BEGIN
        INSERT INTO $_tableFts (node_id, content)
        VALUES (new.id, new.content);
      END
    ''');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS ${_tableNodes}_fts_ad
      AFTER DELETE ON $_tableNodes BEGIN
        DELETE FROM $_tableFts WHERE node_id = old.id;
      END
    ''');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS ${_tableNodes}_fts_au
      AFTER UPDATE OF content ON $_tableNodes BEGIN
        UPDATE $_tableFts SET content = new.content WHERE node_id = old.id;
      END
    ''');
  }

  /// Handles in-place database schema upgrades.
  ///
  /// Version 1 → 2: adds the nullable `category` column to `epistemic_nodes`.
  /// Version 2 → 3: adds the FTS5 index and backfills it from existing rows.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $_tableNodes ADD COLUMN category TEXT '
        "CHECK(category IN ('empirical','rational','intuitive','abductive','revelatory'))",
      );
    }
    if (oldVersion < 3) {
      await _createFts(db);
      await db.execute(
        'INSERT INTO $_tableFts (node_id, content) '
        'SELECT id, content FROM $_tableNodes',
      );
    }
  }

  Database get _requireDb {
    assert(_db != null, 'EpistemicService.init() must be called first.');
    return _db!;
  }

  // ── CRUD ────────────────────────────────────────────────────────────────────

  /// Persists [node] and returns it unchanged.
  @override
  Future<EpistemicNode> create(EpistemicNode node) async {
    await _requireDb.insert(
      _tableNodes,
      node.toJson(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    return node;
  }

  /// Upserts [node] based on exact case-insensitive content match.
  /// If a node with matching content exists, it updates that node with new fields
  /// and returns the merged node (keeping the old ID). Otherwise, inserts it.
  @override
  Future<EpistemicNode> upsert(EpistemicNode node) async {
    final lowerContent = node.content.toLowerCase();
    final rows = await _requireDb.query(
      _tableNodes,
      where: 'LOWER(content) = ?',
      whereArgs: [lowerContent],
      limit: 1,
    );

    if (rows.isNotEmpty) {
      final existing = EpistemicNode.fromJson(rows.first);
      final merged = existing.copyWith(
        type: node.type,
        confidence: node.confidence,
        category: node.category,
        provenance: node.provenance,
      );
      await update(merged);
      return merged;
    } else {
      return await create(node);
    }
  }

  /// Returns the node with [id], or `null` if not found.
  @override
  Future<EpistemicNode?> get(String id) async {
    final rows = await _requireDb.query(
      _tableNodes,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return EpistemicNode.fromJson(rows.first);
  }

  /// Returns all nodes, ordered by creation time (oldest first).
  @override
  Future<List<EpistemicNode>> all() async {
    final rows = await _requireDb.query(_tableNodes, orderBy: 'created_at ASC');
    return rows.map(EpistemicNode.fromJson).toList();
  }

  /// Returns all nodes of the given [type].
  @override
  Future<List<EpistemicNode>> byType(EpistemicNodeType type) async {
    final rows = await _requireDb.query(
      _tableNodes,
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'created_at ASC',
    );
    return rows.map(EpistemicNode.fromJson).toList();
  }

  /// Returns all nodes of the given [category], ordered by creation time.
  ///
  /// Nodes with a null category are not included.
  Future<List<EpistemicNode>> byCategory(EpistemicCategory category) async {
    final rows = await _requireDb.query(
      _tableNodes,
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'created_at ASC',
    );
    return rows.map(EpistemicNode.fromJson).toList();
  }

  /// Overwrites the stored node with [node.id] using all fields from [node].
  ///
  /// Throws [StateError] if no row with that ID exists.
  Future<void> update(EpistemicNode node) async {
    final count = await _requireDb.update(
      _tableNodes,
      node.toJson(),
      where: 'id = ?',
      whereArgs: [node.id],
    );
    if (count == 0) {
      throw StateError('EpistemicNode "${node.id}" not found — cannot update.');
    }
  }

  /// Deletes the node with [id]. No-op if it does not exist.
  Future<void> delete(String id) async {
    await _requireDb.delete(_tableNodes, where: 'id = ?', whereArgs: [id]);
  }

  // ── Query API (EOM-T17) ────────────────────────────────────────────────────

  /// Full-text search over node content, ranked best-first by `bm25`.
  ///
  /// [query] is free text and is sanitised via [sanitizeFtsQuery] before
  /// hitting FTS5, so punctuation and operator syntax never throw.
  /// A blank (or fully stripped) query returns an empty list.
  @override
  Future<List<EpistemicNode>> search(String query) async {
    final match = sanitizeFtsQuery(query);
    if (match.isEmpty) return const [];
    final rows = await _requireDb.rawQuery(
      'SELECT n.* FROM $_tableNodes n '
      'JOIN $_tableFts f ON f.node_id = n.id '
      'WHERE $_tableFts MATCH ? '
      'ORDER BY bm25($_tableFts)',
      [match],
    );
    return rows.map(EpistemicNode.fromJson).toList();
  }

  // ── Relationships ───────────────────────────────────────────────────────────

  /// Persists [relationship] and returns it unchanged.
  @override
  Future<EpistemicRelationship> addRelationship(
    EpistemicRelationship relationship,
  ) async {
    await _requireDb.insert(
      _tableEdges,
      relationship.toJson(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    return relationship;
  }

  /// Deletes the relationship edge with [id]. No-op if it does not exist.
  Future<void> removeRelationship(String id) async {
    await _requireDb.delete(_tableEdges, where: 'id = ?', whereArgs: [id]);
  }

  /// Returns all relationships where [nodeId] is either the source or the target.
  @override
  Future<List<EpistemicRelationship>> getRelationshipsForNode(
    String nodeId,
  ) async {
    final rows = await _requireDb.query(
      _tableEdges,
      where: 'source_id = ? OR target_id = ?',
      whereArgs: [nodeId, nodeId],
      orderBy: 'created_at ASC',
    );
    return rows.map(EpistemicRelationship.fromJson).toList();
  }

  /// Closes the database connection.  Call in tests or when shutting down.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
