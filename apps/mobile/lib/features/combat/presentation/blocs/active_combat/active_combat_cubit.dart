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
///
/// Write actions ([rollInitiative], [advanceTurn], [endEncounter]) are
/// idempotent re-load wrappers: they call the repository, then refresh the
/// snapshot via [load]. `actionInFlight` is flipped while the round-trip
/// is in flight; on failure `actionError` is set and the previous snapshot
/// is retained so the GM can retry.
class ActiveCombatCubit extends Cubit<ActiveCombatState> {
  ActiveCombatCubit({required CombatRepository repository})
      : _repository = repository,
        super(const ActiveCombatLoading());

  final CombatRepository _repository;
  String? _sessionId;

  /// Fetches encounters for [sessionId], picks the most-recent active one,
  /// loads its combatants, and emits the appropriate state.
  Future<void> load(String sessionId) async {
    _sessionId = sessionId;
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

  /// Rolls initiative for the current encounter (`setup → active`).
  ///
  /// No-op if the current state is not [ActiveCombatReady]. Mirrors the web
  /// pattern: dispatch, then reload to consume the post-transition state.
  Future<void> rollInitiative() async {
    final current = state;
    if (current is! ActiveCombatReady) return;
    emit(current.copyWith(actionInFlight: true, actionError: null));
    try {
      await _repository.rollInitiative(current.snapshot.encounter.id);
      if (_sessionId != null) {
        await load(_sessionId!);
      }
    } on Object catch (e) {
      emit(current.copyWith(actionInFlight: false, actionError: e.toString()));
    }
  }

  /// Advances the active turn to the next combatant.
  Future<void> advanceTurn() async {
    final current = state;
    if (current is! ActiveCombatReady) return;
    emit(current.copyWith(actionInFlight: true, actionError: null));
    try {
      await _repository.advanceTurn(current.snapshot.encounter.id);
      if (_sessionId != null) {
        await load(_sessionId!);
      }
    } on Object catch (e) {
      emit(current.copyWith(actionInFlight: false, actionError: e.toString()));
    }
  }

  /// Advances to the start of the next round, resetting the active combatant
  /// to the top of the initiative order.
  Future<void> advanceRound() async {
    final current = state;
    if (current is! ActiveCombatReady) return;
    emit(current.copyWith(actionInFlight: true, actionError: null));
    try {
      await _repository.advanceRound(current.snapshot.encounter.id);
      if (_sessionId != null) {
        await load(_sessionId!);
      }
    } on Object catch (e) {
      emit(current.copyWith(actionInFlight: false, actionError: e.toString()));
    }
  }

  /// Adds a PC combatant to the active encounter and reloads.
  Future<void> addPcCombatant(String characterId) async {
    final current = state;
    if (current is! ActiveCombatReady) return;
    emit(current.copyWith(actionInFlight: true, actionError: null));
    try {
      await _repository.addPcCombatant(
        encounterId: current.snapshot.encounter.id,
        characterId: characterId,
      );
      if (_sessionId != null) {
        await load(_sessionId!);
      }
    } on Object catch (e) {
      emit(current.copyWith(actionInFlight: false, actionError: e.toString()));
    }
  }

  /// Removes [combatantId] from the active encounter and reloads.
  Future<void> removeCombatant(String combatantId) async {
    final current = state;
    if (current is! ActiveCombatReady) return;
    emit(current.copyWith(actionInFlight: true, actionError: null));
    try {
      await _repository.deleteCombatant(combatantId);
      if (_sessionId != null) {
        await load(_sessionId!);
      }
    } on Object catch (e) {
      emit(current.copyWith(actionInFlight: false, actionError: e.toString()));
    }
  }

  /// Toggles [flag] on the named combatant. Reads the current flag set from
  /// [snapshot] so the caller doesn't have to thread it through; the server
  /// receives the full replaced list per the spec.
  Future<void> toggleCanonicalFlag({
    required String combatantId,
    required String flag,
  }) async {
    final current = state;
    if (current is! ActiveCombatReady) return;
    final target = current.snapshot.combatants
        .where((c) => c.id == combatantId)
        .firstOrNull;
    if (target == null) return;
    final present = target.statusFlags.contains(flag);
    final next = present
        ? [
            for (final f in target.statusFlags)
              if (f != flag) f,
          ]
        : [...target.statusFlags, flag];
    emit(current.copyWith(actionInFlight: true, actionError: null));
    try {
      await _repository.setStatusFlags(
        combatantId: combatantId,
        flags: next,
      );
      if (_sessionId != null) {
        await load(_sessionId!);
      }
    } on Object catch (e) {
      emit(current.copyWith(actionInFlight: false, actionError: e.toString()));
    }
  }

  /// Closes the encounter (`status → ended`). Once successful the tracker
  /// reloads and lands on [ActiveCombatEmpty] since the previously-active
  /// encounter is no longer in `active` status.
  Future<void> endEncounter() async {
    final current = state;
    if (current is! ActiveCombatReady) return;
    emit(current.copyWith(actionInFlight: true, actionError: null));
    try {
      await _repository.endEncounter(current.snapshot.encounter.id);
      if (_sessionId != null) {
        await load(_sessionId!);
      }
    } on Object catch (e) {
      emit(current.copyWith(actionInFlight: false, actionError: e.toString()));
    }
  }
}
