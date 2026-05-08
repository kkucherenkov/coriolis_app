import 'package:equatable/equatable.dart';

/// Domain model for a Coriolis character.
///
/// Immutable; mirrors the web's CharacterReadModel surface. Built from
/// the `app_api_client` generated `Character` in the data layer — the
/// presentation layer must never import `app_api_client` types directly.
///
/// Only the fields needed by Epic 3.4 (skeleton) are exposed here; the
/// remaining fields (inventory, talents, skills, etc.) are added in Epic 5.
class Character extends Equatable {
  const Character({
    required this.id,
    required this.ownerId,
    required this.name,
    this.concept,
    required this.updatedAt,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String? concept;
  final DateTime updatedAt;
  final DateTime createdAt;

  /// Derive initials for [AppAvatar] rendering: up to two characters from
  /// the first two words of [name].
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(1, 2)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Character copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? concept,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Character(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      concept: concept ?? this.concept,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, ownerId, name, concept, updatedAt, createdAt];
}
