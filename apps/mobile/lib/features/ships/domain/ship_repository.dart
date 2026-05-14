import 'package:coriolis_companion/features/ships/domain/ship.dart';

/// Repository contract for ship operations. Mirrors the web composable
/// `useShipsApi` surface.
///
/// Implementations live in `data/`. Presentation depends on this interface
/// only — never imports `app_api_client` types directly.
abstract class ShipRepository {
  /// Returns up to [limit] ships owned by the current user.
  Future<List<ShipSummary>> list({int limit = 20});

  /// Fetches the full ship DTO for [id].
  Future<Ship> get(String id);

  /// Creates a new ship for the current user.
  ///
  /// Only `name` and `shipClass` are required by the server; `model` and
  /// `registry` are optional flavour fields. Hull / energy / armor / etc.
  /// default to the class baseline on the server side.
  ///
  /// [shipClass] must be a wire-form `ShipClass` enum value (kebab-case),
  /// e.g. `light-freighter`, `fighter`, `gunboat`.
  Future<Ship> create({
    required String name,
    required String shipClass,
    String? model,
    String? registry,
  });

  /// Partially updates the ship identified by [id]. All fields optional;
  /// only the supplied keys are sent in the PATCH body.
  Future<Ship> update(
    String id, {
    String? name,
    String? model,
    String? registry,
    ShipPoints? hull,
    ShipPoints? energy,
    int? armor,
    int? maneuverability,
    int? signature,
    int? speed,
    List<String>? problems,
    String? history,
    String? notes,
  });

  /// Permanently deletes the ship identified by [id].
  Future<void> delete(String id);

  /// Deep-copies the ship (including modules and problems) under a new
  /// id; the new ship is assigned to the same owner. Returns the copy.
  Future<Ship> duplicate(String id);

  /// Returns the export snapshot for [id] — same `Ship` shape, intended
  /// for the GM to save / share. The backend currently returns 501
  /// (experimental); callers should surface the error gracefully.
  Future<Ship> exportSnapshot(String id);

  /// Assigns [characterId] (must be owned by the caller) to crew [position]
  /// on ship [shipId]. The server validates ownership and applies move
  /// semantics if the character was already on the ship in another slot.
  ///
  /// [position] is the wire-form `CrewPosition` value
  /// (`captain` | `pilot` | `sensorOp` | `gunner` | `engineer` | `serviceCrew`).
  Future<void> assignCrew({
    required String shipId,
    required String position,
    required String characterId,
  });

  /// Removes [characterId] from any crew slot on [shipId].
  Future<void> unassignCrew({
    required String shipId,
    required String characterId,
  });

  /// Adds a generic "other-slot" module to [shipId]. Mobile v1 restricts
  /// the picker to slots that map to `ShipModuleOtherCreate` (i.e.
  /// COMMS / HANGAR / QUARTERS / etc.); the four variant slots
  /// (HOLD / WEAPON / TORPEDO / SENSOR) and their type-specific fields
  /// are deferred to a follow-up that ports the web variant forms.
  ///
  /// [slot] is the wire-form `ShipModuleSlot` value.
  Future<DomainShipModule> addOtherModule({
    required String shipId,
    required String slot,
    required String name,
    int energyUse = 0,
    String? notes,
  });

  /// Patches the editable fields of an existing module. `slot` is immutable
  /// after installation per the spec.
  Future<DomainShipModule> updateOtherModule({
    required String moduleId,
    String? name,
    int? energyUse,
    String? notes,
  });

  /// Deletes a module. Server rejects (`SHIP_MODULE_MANDATORY` / 422) for
  /// the seeded `BRIDGE` / `REACTOR` / `DRIVE` slots.
  Future<void> deleteModule(String moduleId);
}
