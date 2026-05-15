import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_create/ship_create_state.dart';

export 'ship_create_state.dart';

/// Drives the ship-create form: holds form fields, validates, dispatches
/// the POST through [ShipRepository.create], and surfaces success / error.
///
/// The page consumes [ShipCreateState.createdShipId] via a `BlocListener` and
/// navigates to the ship sheet via `pushReplacementNamed`.
class ShipCreateCubit extends Cubit<ShipCreateState> {
  ShipCreateCubit({required ShipRepository repository})
      : _repository = repository,
        super(const ShipCreateState());

  final ShipRepository _repository;

  // ── Field setters ────────────────────────────────────────────────────────

  void setName(String name) => emit(state.copyWith(name: name));

  void setShipClass(String shipClass) =>
      emit(state.copyWith(shipClass: shipClass));

  void setModel(String model) => emit(state.copyWith(model: model));

  void setRegistry(String registry) =>
      emit(state.copyWith(registry: registry));

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> submit() async {
    if (!state.canSubmit) return;
    final trimmedName = state.name.trim();
    final trimmedModel = state.model.trim();
    final trimmedRegistry = state.registry.trim();

    emit(state.copyWith(
      status: ShipCreateStatus.submitting,
      errorMessage: null,
    ));
    try {
      final ship = await _repository.create(
        name: trimmedName,
        shipClass: state.shipClass,
        model: trimmedModel.isEmpty ? null : trimmedModel,
        registry: trimmedRegistry.isEmpty ? null : trimmedRegistry,
      );
      emit(state.copyWith(
        status: ShipCreateStatus.success,
        createdShipId: ship.id,
      ));
    } on Object catch (e) {
      emit(state.copyWith(
        status: ShipCreateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
