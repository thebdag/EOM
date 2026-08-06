import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../models/epistemic_node.dart';
import '../models/epistemic_relationship.dart';

/// Read/write surface of the epistemic graph used by intent-integration
/// services (EOM-T7). Implemented by [EpistemicService]; faked in tests.
abstract class EpistemicGraphStore {
  Future<EpistemicNode> create(EpistemicNode node);
  Future<EpistemicNode> upsert(EpistemicNode node);
  Future<List<EpistemicNode>> all();
  Future<EpistemicRelationship> addRelationship(
    EpistemicRelationship relationship,
  );
}

/// SQLite-backed service for the epistemic graph.
///
/// Owns the `epistemic_nodes` and `epistemic_edges` tables.
/// Domain-query API (EOM-T17) will be added in a later task.
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
class EpistemicService implements EpistemicGraphStore {
  static const _dbFileName = 'epistemic.db';
  static const _tableNodes = 'epistemic_nodes';
  static const _tableEdges = 'epistemic_edges';

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
      version: 2,
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
  }

  /// Handles in-place database schema upgrades.
  ///
  /// Version 1 → 2: adds the nullable `category` column to `epistemic_nodes`.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $_tableNodes ADD COLUMN category TEXT '
        "CHECK(category IN ('empirical','rational','intuitive','abductive','revelatory'))",
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
