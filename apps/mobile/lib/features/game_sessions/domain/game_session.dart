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
///
/// Phase 8 Stream E: the legacy `characterIds` list is gone — the crew
/// roster (incl. PC linkage) is now exposed through the SDK's
/// `memberships` array on the wire DTO, not duplicated here.
class GameSession extends Equatable {
  const GameSession({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.status,
    required this.dpCount,
    required this.members,
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

  /// Active session members (incl. the GM). Single source of truth for
  /// "who is at this table" since Phase 8 Stream E.
  final List<GameSessionMember> members;
  final String? shipId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Character ids linked through memberships — used by the combat tracker
  /// to populate the PC picker.
  List<String> get linkedCharacterIds => [
        for (final m in members)
          if (m.characterId != null) m.characterId!,
      ];

  GameSession copyWith({
    int? dpCount,
    String? status,
    String? name,
    String? description,
    List<GameSessionMember>? members,
  }) {
    return GameSession(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      dpCount: dpCount ?? this.dpCount,
      members: members ?? this.members,
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
        members,
        shipId,
        createdAt,
        updatedAt,
      ];
}

/// A row in the session's `GameSessionMembership` table, as the mobile UI
/// sees it. Mirrors `api_client.GameSessionMembership` minus the wire-only
/// `gameSessionId`/`leftAt` fields the UI never reads.
class GameSessionMember extends Equatable {
  const GameSessionMember({
    required this.id,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.displayName,
    this.characterId,
    this.characterName,
  });

  final String id;
  final String userId;

  /// Wire string: "gm" | "player".
  final String role;
  final String? displayName;
  final String? characterId;
  final String? characterName;
  final DateTime joinedAt;

  bool get isGm => role == 'gm';

  @override
  List<Object?> get props => [id, userId, role, displayName, characterId, characterName, joinedAt];
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
