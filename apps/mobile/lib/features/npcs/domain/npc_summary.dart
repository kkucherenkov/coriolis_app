import 'package:equatable/equatable.dart';

/// Lightweight list-row model for the NPC picker (Phase 6 T-MOBILE-NPC-PICKER).
///
/// Contains only the fields needed to render a picker row — id + name.
/// Full NPC CRUD and a rich domain entity wait on the NPC feature shell.
class NpcSummary extends Equatable {
  const NpcSummary({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
