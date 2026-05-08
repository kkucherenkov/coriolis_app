import 'package:equatable/equatable.dart';

/// Lightweight list-row model for the characters list screen.
///
/// Derived from the full [Character] domain entity. Contains only the
/// fields needed to render a card row — avoid pulling full inventory /
/// talent collections onto the list page.
class CharacterSummary extends Equatable {
  const CharacterSummary({
    required this.id,
    required this.name,
    this.concept,
  });

  final String id;
  final String name;
  final String? concept;

  @override
  List<Object?> get props => [id, name, concept];
}
