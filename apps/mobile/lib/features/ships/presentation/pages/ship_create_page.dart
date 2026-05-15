import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/app/routes.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_create/ship_create_cubit.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Mobile parity with the web `apps/web/app/pages/app/ships/index.vue`
/// inline create form. Mounted as its own route so back-stack handling
/// is intuitive: tap FAB → fill form → submit → land on `/app/ships/<id>`
/// (the list page sits behind us via `pushNamed`, so the back gesture
/// returns there from the sheet too).
///
/// The page is `getIt`-free: production wiring lives in `routes.dart`
/// (passes `cubitFactory:` from DI); widget tests inject `cubitOverride:`.
class ShipCreatePage extends StatelessWidget {
  const ShipCreatePage({
    super.key,
    this.cubitFactory,
    this.cubitOverride,
  });

  /// Production factory — `routes.dart` passes `() => getIt<ShipCreateCubit>()`.
  final ShipCreateCubit Function()? cubitFactory;

  /// Widget-test override; mounted via `BlocProvider.value`.
  final ShipCreateCubit? cubitOverride;

  @override
  Widget build(BuildContext context) {
    const view = _ShipCreateView();
    if (cubitOverride != null) {
      return BlocProvider<ShipCreateCubit>.value(
        value: cubitOverride!,
        child: view,
      );
    }
    final factory = cubitFactory;
    if (factory == null) {
      throw StateError(
        'ShipCreatePage requires either cubitFactory or cubitOverride',
      );
    }
    return BlocProvider<ShipCreateCubit>(
      create: (_) => factory(),
      child: view,
    );
  }
}

class _ShipCreateView extends StatelessWidget {
  const _ShipCreateView();

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return BlocConsumer<ShipCreateCubit, ShipCreateState>(
      listenWhen: (prev, next) => prev.createdShipId != next.createdShipId,
      listener: (context, state) {
        final id = state.createdShipId;
        if (id != null) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.shipDetail,
            arguments: id,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceVoid,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceNight,
            title: Text(
              t.createTitle,
              style: AppTypography.bodyLg
                  .copyWith(color: AppColors.brandBrassLight),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.s4),
            children: [
              if (state.errorMessage != null) ...[
                AppBanner(
                  tone: AppBannerTone.danger,
                  child: Text(state.errorMessage!),
                ),
                const SizedBox(height: AppSpacing.s3),
              ],
              _NameField(value: state.name),
              const SizedBox(height: AppSpacing.s3),
              _ClassPicker(value: state.shipClass),
              const SizedBox(height: AppSpacing.s3),
              _ModelField(value: state.model),
              const SizedBox(height: AppSpacing.s3),
              _RegistryField(value: state.registry),
              const SizedBox(height: AppSpacing.s6),
              AppButton(
                key: const Key('ship-create-submit'),
                label: t.createSubmit,
                onPressed: state.canSubmit
                    ? () => context.read<ShipCreateCubit>().submit()
                    : null,
                loading: state.status == ShipCreateStatus.submitting,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Form fields ─────────────────────────────────────────────────────────────

class _NameField extends StatelessWidget {
  const _NameField({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return _Labelled(
      label: t.createNameLabel,
      child: TextFormField(
        key: const Key('ship-create-name'),
        initialValue: value,
        textInputAction: TextInputAction.next,
        maxLength: 80,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onChanged: (v) => context.read<ShipCreateCubit>().setName(v),
      ),
    );
  }
}

class _ModelField extends StatelessWidget {
  const _ModelField({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return _Labelled(
      label: t.createModelLabel,
      child: TextFormField(
        key: const Key('ship-create-model'),
        initialValue: value,
        textInputAction: TextInputAction.next,
        maxLength: 80,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onChanged: (v) => context.read<ShipCreateCubit>().setModel(v),
      ),
    );
  }
}

class _RegistryField extends StatelessWidget {
  const _RegistryField({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return _Labelled(
      label: t.createRegistryLabel,
      child: TextFormField(
        key: const Key('ship-create-registry'),
        initialValue: value,
        textInputAction: TextInputAction.done,
        maxLength: 40,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onChanged: (v) => context.read<ShipCreateCubit>().setRegistry(v),
      ),
    );
  }
}

class _ClassPicker extends StatelessWidget {
  const _ClassPicker({required this.value});
  final String value;

  /// Wire-form `ShipClass` values + display label. Keeping the list explicit
  /// (rather than walking `ShipClass.values`) gives us stable ordering and
  /// lets us localise labels independently later.
  static const _options = <(String, String)>[
    ('fighter', 'Fighter'),
    ('shuttle', 'Shuttle'),
    ('torpedo-boat', 'Torpedo Boat'),
    ('light-freighter', 'Light Freighter'),
    ('light-passenger', 'Light Passenger'),
    ('courier-yacht', 'Courier Yacht'),
    ('clipper', 'Clipper'),
    ('patrol-boat', 'Patrol Boat'),
    ('gunboat', 'Gunboat'),
    ('assault-ship', 'Assault Ship'),
    ('blockade-runner', 'Blockade Runner'),
    ('pleasure-yacht', 'Pleasure Yacht'),
    ('flying-circus', 'Flying Circus'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return _Labelled(
      label: t.createClassLabel,
      child: DropdownButtonFormField<String>(
        key: const Key('ship-create-class'),
        initialValue: value,
        items: [
          for (final (wire, label) in _options)
            DropdownMenuItem<String>(value: wire, child: Text(label)),
        ],
        onChanged: (next) {
          if (next != null) {
            context.read<ShipCreateCubit>().setShipClass(next);
          }
        },
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.brandBrassDeep,
            fontWeight: AppFontWeight.medium,
          ),
        ),
        const SizedBox(height: AppSpacing.s1),
        child,
      ],
    );
  }
}
