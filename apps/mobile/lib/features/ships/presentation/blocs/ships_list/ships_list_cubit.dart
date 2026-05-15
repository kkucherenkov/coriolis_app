import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ships_list/ships_list_state.dart';

/// Manages the ships list screen state. Mirrors [`CharactersListCubit`].
class ShipsListCubit extends Cubit<ShipsListState> {
  ShipsListCubit(this._repository) : super(const ShipsListState());

  final ShipRepository _repository;

  Future<void> init() => _load();

  Future<void> refresh() => _load();

  Future<void> _load() async {
    emit(state.copyWith(
      status: ShipsListStatus.loading,
      errorMessage: null,
    ));
    try {
      final items = await _repository.list(limit: 20);
      if (items.isEmpty) {
        emit(state.copyWith(
          status: ShipsListStatus.empty,
          ships: const [],
        ));
      } else {
        emit(state.copyWith(
          status: ShipsListStatus.loaded,
          ships: items,
        ));
      }
    } on Object catch (e) {
      emit(state.copyWith(
        status: ShipsListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
