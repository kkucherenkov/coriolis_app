import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_mobile/features/characters/domain/character_repository.dart';
import 'package:app_mobile/features/characters/presentation/blocs/characters_list/characters_list_state.dart';

/// Manages the characters list screen state.
///
/// Call [init] (or let the page call it) to fetch the first page. Call
/// [refresh] to pull-to-refresh. The cubit is registered as a factory in
/// DI — each `BlocProvider` gets a fresh instance.
class CharactersListCubit extends Cubit<CharactersListState> {
  CharactersListCubit(this._repository) : super(const CharactersListState());

  final CharacterRepository _repository;

  /// Fetch the first page (limit = 20). Emits `loading` → `loaded` | `empty`
  /// | `error`.
  Future<void> init() => _load();

  /// Pull-to-refresh: re-emit `loading` then reload.
  Future<void> refresh() => _load();

  Future<void> _load() async {
    emit(state.copyWith(
      status: CharactersListStatus.loading,
      errorMessage: null,
    ));
    try {
      final items = await _repository.list(limit: 20);
      if (items.isEmpty) {
        emit(state.copyWith(
          status: CharactersListStatus.empty,
          characters: [],
        ));
      } else {
        emit(state.copyWith(
          status: CharactersListStatus.loaded,
          characters: items,
        ));
      }
    } on Object catch (e) {
      emit(state.copyWith(
        status: CharactersListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
