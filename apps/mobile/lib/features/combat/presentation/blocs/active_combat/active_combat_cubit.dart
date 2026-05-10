import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/combat/domain/combat_repository.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_state.dart';

export 'active_combat_state.dart';

/// Loads and exposes the active combat encounter for a given session.
///
/// Lifecycle:
/// 1. [load] emits [ActiveCombatLoading], then fetches all encounters for
///    [sessionId].
/// 2. It filters to `state == 'active'`; the first item from the server-ordered
///    list is taken (server emits newest-first, matching [CombatRepository.listEncounters]).
/// 3. If no active encounter is found, emits [ActiveCombatEmpty].
/// 4. Otherwise fetches combatants and emits [ActiveCombatReady].
/// 5. Any thrown exception emits [ActiveCombatError].
///
/// [replaceSnapshot] is a synchronous setter for Block 4 realtime wiring —
/// the Centrifugo subscription calls it with an updated snapshot and it
/// emits a new [ActiveCombatReady] without triggering a network fetch.
class ActiveCombatCubit extends Cubit<ActiveCombatState> {
  ActiveCombatCubit({required CombatRepository repository})
      : _repository = repository,
        super(const ActiveCombatLoading());

  final CombatRepository _repository;

  /// Fetches encounters for [sessionId], picks the most-recent active one,
  /// loads its combatants, and emits the appropriate state.
  Future<void> load(String sessionId) async {
    emit(const ActiveCombatLoading());
    try {
      final encounters = await _repository.listEncounters(sessionId);

      // Server returns newest-first; first match is the most recent active.
      final active = encounters.where((e) => e.state == 'active').firstOrNull;

      if (active == null) {
        emit(const ActiveCombatEmpty());
        return;
      }

      final combatants = await _repository.listCombatants(active.id);
      emit(ActiveCombatReady(ActiveCombatSnapshot(
        encounter: active,
        combatants: combatants,
      )));
    } on Object catch (e) {
      emit(ActiveCombatError(e.toString()));
    }
  }

  /// Replaces the current snapshot without a network round-trip.
  ///
  /// Called by the Block 4 realtime adapter when a Centrifugo push arrives.
  /// Always emits [ActiveCombatReady] — callers must not call this while
  /// [ActiveCombatLoading] is in flight.
  void replaceSnapshot(ActiveCombatSnapshot snapshot) {
    emit(ActiveCombatReady(snapshot));
  }
}
