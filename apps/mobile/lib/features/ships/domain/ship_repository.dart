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
}
