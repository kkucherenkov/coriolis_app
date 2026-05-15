import 'package:equatable/equatable.dart';

/// A game session as the mobile UI sees it (Phase 4 Feature 7.2).
///
/// Domain model — the `data/session_repository_impl.dart` adapter
/// translates between this and the SDK's `GameSession`. `dpCount` is
/// always the latest snapshot from the server; the live update path
/// (Block 4) patches it via Centrifugo `dp.changed` payloads. `status`
/// is the wire string ("active" | "archived") rather than an enum so
/// the UI can render whatever the server returns even if the contract
/// adds a new value before the mobile app catches up.
class GameSession extends Equatable {
  const GameSession({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.status,
    required this.dpCount,
    required this.characterIds,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.shipId,
  });

  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String status;
  final int dpCount;
  final List<String> characterIds;
  final String? shipId;
  final DateTime createdAt;
  final DateTime updatedAt;

  GameSession copyWith({
    int? dpCount,
    List<String>? characterIds,
    String? status,
    String? name,
    String? description,
  }) {
    return GameSession(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      dpCount: dpCount ?? this.dpCount,
      characterIds: characterIds ?? this.characterIds,
      shipId: shipId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        description,
        status,
        dpCount,
        characterIds,
        shipId,
        createdAt,
        updatedAt,
      ];
}

/// Audit row for a single Darkness Points adjustment (Phase 4 Feature 7.3).
class DpEvent extends Equatable {
  const DpEvent({
    required this.id,
    required this.gameSessionId,
    required this.delta,
    required this.source,
    required this.createdAt,
    this.reason,
    this.rollId,
  });

  final String id;
  final String gameSessionId;
  final int delta;

  /// Wire enum: "gm-manual" | "roll-push" | "system". Kept as a string
  /// so the UI tolerates a future fourth value gracefully.
  final String source;
  final String? reason;
  final String? rollId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, gameSessionId, delta, source, reason, rollId, createdAt];
}
