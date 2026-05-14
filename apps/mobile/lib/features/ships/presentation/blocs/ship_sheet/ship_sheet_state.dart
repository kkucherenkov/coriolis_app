import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/ships/domain/ship.dart';

/// Save-cycle status — mirrors the character sheet save pulse.
enum ShipSheetSaveStatus { idle, saving, saved, error }

/// State emitted by `ShipSheetCubit`.
class ShipSheetState extends Equatable {
  const ShipSheetState({
    this.isLoading = true,
    this.ship,
    this.saveStatus = ShipSheetSaveStatus.idle,
    this.errorMessage,
    this.saveErrorMessage,
    this.notFound = false,
  });

  final bool isLoading;
  final Ship? ship;
  final ShipSheetSaveStatus saveStatus;

  /// Load-level error (network or server failure).
  final String? errorMessage;

  /// Save-level error (debounced PATCH failed).
  final String? saveErrorMessage;

  /// Set when the initial GET resolves to 404.
  final bool notFound;

  bool get isSaving => saveStatus == ShipSheetSaveStatus.saving;
  bool get hasSaved => saveStatus == ShipSheetSaveStatus.saved;
  bool get hasSaveError => saveStatus == ShipSheetSaveStatus.error;

  ShipSheetState copyWith({
    bool? isLoading,
    Ship? ship,
    ShipSheetSaveStatus? saveStatus,
    String? errorMessage,
    String? saveErrorMessage,
    bool? notFound,
  }) {
    return ShipSheetState(
      isLoading: isLoading ?? this.isLoading,
      ship: ship ?? this.ship,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage,
      saveErrorMessage: saveErrorMessage,
      notFound: notFound ?? this.notFound,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        ship,
        saveStatus,
        errorMessage,
        saveErrorMessage,
        notFound,
      ];
}
