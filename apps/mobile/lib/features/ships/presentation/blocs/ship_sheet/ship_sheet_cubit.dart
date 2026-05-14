import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_sheet/ship_sheet_state.dart';

/// Manages the full ship sheet state.
///
/// Debounce mirrors [`CharacterSheetCubit`]: each edit cancels the pending
/// timer and restarts it. The accumulated patch is flushed after the
/// debounce interval. On success the `saved` status auto-resets to `idle`
/// after the reset interval.
class ShipSheetCubit extends Cubit<ShipSheetState> {
  ShipSheetCubit({
    required ShipRepository repository,
    Duration debounceDuration = const Duration(milliseconds: 500),
    Duration savedResetDuration = const Duration(milliseconds: 1500),
  })  : _repository = repository,
        _debounceDuration = debounceDuration,
        _savedResetDuration = savedResetDuration,
        super(const ShipSheetState());

  final ShipRepository _repository;
  final Duration _debounceDuration;
  final Duration _savedResetDuration;

  Timer? _debounceTimer;
  Timer? _savedResetTimer;

  // Pending patch fields (accumulated until the debounce fires).
  String? _pendingName;
  String? _pendingModel;
  String? _pendingRegistry;
  ShipPoints? _pendingHull;
  ShipPoints? _pendingEnergy;
  int? _pendingArmor;
  int? _pendingManeuverability;
  int? _pendingSignature;
  int? _pendingSpeed;
  List<String>? _pendingProblems;
  String? _pendingHistory;
  String? _pendingNotes;

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> load(String id) async {
    emit(const ShipSheetState(isLoading: true));
    try {
      final ship = await _repository.get(id);
      emit(ShipSheetState(isLoading: false, ship: ship));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        emit(const ShipSheetState(isLoading: false, notFound: true));
        return;
      }
      emit(ShipSheetState(isLoading: false, errorMessage: e.toString()));
    } on Object catch (e) {
      emit(ShipSheetState(isLoading: false, errorMessage: e.toString()));
    }
  }

  // ── Identity edits ───────────────────────────────────────────────────────

  void updateName(String value) {
    final current = state.ship;
    if (current == null) return;
    emit(state.copyWith(ship: current.copyWith(name: value)));
    _pendingName = value;
    _scheduleDebounce(current.id);
  }

  void updateModel(String? value) {
    final current = state.ship;
    if (current == null) return;
    emit(state.copyWith(ship: current.copyWith(model: value)));
    _pendingModel = value ?? '';
    _scheduleDebounce(current.id);
  }

  void updateRegistry(String? value) {
    final current = state.ship;
    if (current == null) return;
    emit(state.copyWith(ship: current.copyWith(registry: value)));
    _pendingRegistry = value ?? '';
    _scheduleDebounce(current.id);
  }

  // ── Stat edits ───────────────────────────────────────────────────────────

  /// Adjusts current hull points by [delta], clamped to `[0, max]`.
  void adjustHullCurrent(int delta) {
    final current = state.ship;
    if (current == null) return;
    final next = (current.hull.current + delta).clamp(0, current.hull.max);
    final updated = current.hull.copyWith(current: next);
    emit(state.copyWith(ship: current.copyWith(hull: updated)));
    _pendingHull = updated;
    _scheduleDebounce(current.id);
  }

  void setHullMax(int value) {
    final current = state.ship;
    if (current == null || value < 0) return;
    final clampedCurrent = current.hull.current.clamp(0, value);
    final updated = ShipPoints(current: clampedCurrent, max: value);
    emit(state.copyWith(ship: current.copyWith(hull: updated)));
    _pendingHull = updated;
    _scheduleDebounce(current.id);
  }

  /// Adjusts current energy by [delta], clamped to `[0, max]`.
  void adjustEnergyCurrent(int delta) {
    final current = state.ship;
    if (current == null) return;
    final next = (current.energy.current + delta).clamp(0, current.energy.max);
    final updated = current.energy.copyWith(current: next);
    emit(state.copyWith(ship: current.copyWith(energy: updated)));
    _pendingEnergy = updated;
    _scheduleDebounce(current.id);
  }

  void setEnergyMax(int value) {
    final current = state.ship;
    if (current == null || value < 0) return;
    final clampedCurrent = current.energy.current.clamp(0, value);
    final updated = ShipPoints(current: clampedCurrent, max: value);
    emit(state.copyWith(ship: current.copyWith(energy: updated)));
    _pendingEnergy = updated;
    _scheduleDebounce(current.id);
  }

  void setArmor(int value) {
    final current = state.ship;
    if (current == null || value < 0) return;
    emit(state.copyWith(ship: current.copyWith(armor: value)));
    _pendingArmor = value;
    _scheduleDebounce(current.id);
  }

  void setManeuverability(int value) {
    final current = state.ship;
    if (current == null) return;
    emit(state.copyWith(ship: current.copyWith(maneuverability: value)));
    _pendingManeuverability = value;
    _scheduleDebounce(current.id);
  }

  void setSignature(int value) {
    final current = state.ship;
    if (current == null) return;
    emit(state.copyWith(ship: current.copyWith(signature: value)));
    _pendingSignature = value;
    _scheduleDebounce(current.id);
  }

  void setSpeed(int value) {
    final current = state.ship;
    if (current == null || value < 0) return;
    emit(state.copyWith(ship: current.copyWith(speed: value)));
    _pendingSpeed = value;
    _scheduleDebounce(current.id);
  }

  // ── Notes / history / problems ───────────────────────────────────────────

  void updateNotes(String value) {
    final current = state.ship;
    if (current == null) return;
    emit(state.copyWith(ship: current.copyWith(notes: value)));
    _pendingNotes = value;
    _scheduleDebounce(current.id);
  }

  void updateHistory(String value) {
    final current = state.ship;
    if (current == null) return;
    emit(state.copyWith(ship: current.copyWith(history: value)));
    _pendingHistory = value;
    _scheduleDebounce(current.id);
  }

  /// Accepts the raw comma-separated input from the UI; parses to the
  /// trimmed-non-empty list the server expects.
  void updateProblemsFromText(String input) {
    final current = state.ship;
    if (current == null) return;
    final parsed = input
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    emit(state.copyWith(ship: current.copyWith(problems: parsed)));
    _pendingProblems = parsed;
    _scheduleDebounce(current.id);
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteShip() async {
    final id = state.ship?.id;
    if (id == null) return;
    emit(state.copyWith(saveStatus: ShipSheetSaveStatus.saving));
    try {
      await _repository.delete(id);
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: ShipSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
    }
  }

  // ── Duplicate ────────────────────────────────────────────────────────────

  /// Deep-copies the current ship and returns the new id on success;
  /// `null` on failure (error surfaced via [ShipSheetState.saveErrorMessage]).
  ///
  /// The page reads the returned id and navigates via
  /// `pushReplacementNamed` so the back gesture still returns to the list.
  Future<String?> duplicate() async {
    final id = state.ship?.id;
    if (id == null) return null;
    emit(state.copyWith(saveStatus: ShipSheetSaveStatus.saving));
    try {
      final copy = await _repository.duplicate(id);
      emit(state.copyWith(saveStatus: ShipSheetSaveStatus.saved));
      _startSavedResetTimer();
      return copy.id;
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: ShipSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
      return null;
    }
  }

  // ── Export ───────────────────────────────────────────────────────────────

  /// Requests an export snapshot for the current ship. Returns the export
  /// `Ship` payload on success, `null` on failure. The page can render the
  /// payload (e.g. share-sheet, clipboard) — currently it just confirms
  /// via SnackBar since the backend is still on the experimental 501 path.
  Future<Ship?> exportSnapshot() async {
    final id = state.ship?.id;
    if (id == null) return null;
    emit(state.copyWith(saveStatus: ShipSheetSaveStatus.saving));
    try {
      final snapshot = await _repository.exportSnapshot(id);
      emit(state.copyWith(saveStatus: ShipSheetSaveStatus.saved));
      _startSavedResetTimer();
      return snapshot;
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: ShipSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
      return null;
    }
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  void _scheduleDebounce(String id) {
    _debounceTimer?.cancel();
    _savedResetTimer?.cancel();

    _debounceTimer = Timer(_debounceDuration, () async {
      final pName = _pendingName;
      final pModel = _pendingModel;
      final pRegistry = _pendingRegistry;
      final pHull = _pendingHull;
      final pEnergy = _pendingEnergy;
      final pArmor = _pendingArmor;
      final pManeuverability = _pendingManeuverability;
      final pSignature = _pendingSignature;
      final pSpeed = _pendingSpeed;
      final pProblems = _pendingProblems;
      final pHistory = _pendingHistory;
      final pNotes = _pendingNotes;
      _pendingName = null;
      _pendingModel = null;
      _pendingRegistry = null;
      _pendingHull = null;
      _pendingEnergy = null;
      _pendingArmor = null;
      _pendingManeuverability = null;
      _pendingSignature = null;
      _pendingSpeed = null;
      _pendingProblems = null;
      _pendingHistory = null;
      _pendingNotes = null;

      emit(state.copyWith(saveStatus: ShipSheetSaveStatus.saving));
      try {
        final updated = await _repository.update(
          id,
          name: pName,
          model: pModel,
          registry: pRegistry,
          hull: pHull,
          energy: pEnergy,
          armor: pArmor,
          maneuverability: pManeuverability,
          signature: pSignature,
          speed: pSpeed,
          problems: pProblems,
          history: pHistory,
          notes: pNotes,
        );
        emit(state.copyWith(
          ship: updated,
          saveStatus: ShipSheetSaveStatus.saved,
        ));
        _startSavedResetTimer();
      } on Object catch (e) {
        emit(state.copyWith(
          saveStatus: ShipSheetSaveStatus.error,
          saveErrorMessage: e.toString(),
        ));
      }
    });
  }

  void _startSavedResetTimer() {
    _savedResetTimer?.cancel();
    _savedResetTimer = Timer(_savedResetDuration, () {
      if (!isClosed) {
        emit(state.copyWith(saveStatus: ShipSheetSaveStatus.idle));
      }
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _savedResetTimer?.cancel();
    return super.close();
  }
}
