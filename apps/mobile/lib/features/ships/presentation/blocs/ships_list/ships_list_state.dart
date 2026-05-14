import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/ships/domain/ship.dart';

enum ShipsListStatus { loading, empty, loaded, error }

class ShipsListState extends Equatable {
  const ShipsListState({
    this.status = ShipsListStatus.loading,
    this.ships = const [],
    this.errorMessage,
  });

  final ShipsListStatus status;
  final List<ShipSummary> ships;
  final String? errorMessage;

  bool get isLoading => status == ShipsListStatus.loading;
  bool get isEmpty => status == ShipsListStatus.empty;
  bool get isLoaded => status == ShipsListStatus.loaded;
  bool get isError => status == ShipsListStatus.error;

  ShipsListState copyWith({
    ShipsListStatus? status,
    List<ShipSummary>? ships,
    String? errorMessage,
  }) {
    return ShipsListState(
      status: status ?? this.status,
      ships: ships ?? this.ships,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, ships, errorMessage];
}
