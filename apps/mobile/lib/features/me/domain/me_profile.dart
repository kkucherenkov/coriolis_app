import 'package:equatable/equatable.dart';

/// Domain entity for the authenticated user's server-side profile.
///
/// Keeps only the fields the mobile app currently consumes; the full wire
/// model lives in the generated `Me` built_value class in `app_api_client`.
class MeProfile extends Equatable {
  const MeProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.chatDockedCollapsed = false,
  });

  final String id;
  final String email;
  final String? displayName;

  /// Persisted state of the chat-dock collapse toggle.
  /// Defaults to `false` when the server returns null (older accounts).
  final bool chatDockedCollapsed;

  MeProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? chatDockedCollapsed,
  }) {
    return MeProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      chatDockedCollapsed: chatDockedCollapsed ?? this.chatDockedCollapsed,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, chatDockedCollapsed];
}
