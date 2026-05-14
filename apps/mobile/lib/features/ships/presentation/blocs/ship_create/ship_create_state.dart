import 'package:equatable/equatable.dart';

/// Lifecycle of the [ShipCreatePage] form.
enum ShipCreateStatus { idle, submitting, success, error }

/// View-model for the ship-create form.
///
/// Field state lives here so the form survives orientation changes and so
/// the cubit can be exercised by tests without driving a Flutter widget tree.
class ShipCreateState extends Equatable {
  const ShipCreateState({
    this.status = ShipCreateStatus.idle,
    this.name = '',
    this.shipClass = 'light-freighter',
    this.model = '',
    this.registry = '',
    this.errorMessage,
    this.createdShipId,
  });

  final ShipCreateStatus status;

  /// Pilot-visible ship name. Trimmed before submission; empty → form invalid.
  final String name;

  /// Wire-form `ShipClass` value (kebab-case). Defaults to `light-freighter`
  /// to match the web `index.vue` default — it's the most common starter.
  final String shipClass;

  final String model;
  final String registry;

  final String? errorMessage;

  /// Set once the server confirms creation; the page reads this to navigate
  /// to the sheet via `Navigator.pushReplacementNamed`.
  final String? createdShipId;

  bool get canSubmit =>
      status != ShipCreateStatus.submitting && name.trim().isNotEmpty;

  ShipCreateState copyWith({
    ShipCreateStatus? status,
    String? name,
    String? shipClass,
    String? model,
    String? registry,
    Object? errorMessage = _sentinel,
    Object? createdShipId = _sentinel,
  }) {
    return ShipCreateState(
      status: status ?? this.status,
      name: name ?? this.name,
      shipClass: shipClass ?? this.shipClass,
      model: model ?? this.model,
      registry: registry ?? this.registry,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      createdShipId: identical(createdShipId, _sentinel)
          ? this.createdShipId
          : createdShipId as String?,
    );
  }

  static const Object _sentinel = Object();

  @override
  List<Object?> get props => [
        status,
        name,
        shipClass,
        model,
        registry,
        errorMessage,
        createdShipId,
      ];
}
