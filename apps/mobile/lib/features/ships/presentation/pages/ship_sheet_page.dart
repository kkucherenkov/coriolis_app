import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_sheet/ship_sheet_cubit.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_sheet/ship_sheet_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/shared/di/injector.dart';

/// Ship sheet — parity with `apps/web/app/pages/app/ships/[id].vue`.
///
/// First mobile block scopes:
///   - Header: name + class badge + AppSavePulse + Delete
///   - Identity card: name / model / registry (debounced auto-save)
///   - Stats card: hull / energy steppers, armor / maneuverability /
///     signature / speed inputs, cargo capacity read-only
///   - Modules card: read-only grouped by slot (mandatory first)
///   - Crew card: read-only six-position roster
///   - Notes / History / Problems cards: debounced auto-save
///
/// Module editor + crew assignment are deferred to follow-up blocks
/// (mirrors how the web sheet shipped: read-only block → edit blocks).
class ShipSheetPage extends StatelessWidget {
  const ShipSheetPage({super.key, required this.shipId});

  final String shipId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShipSheetCubit>(
      create: (_) => getIt<ShipSheetCubit>()..load(shipId),
      child: const _ShipSheetView(),
    );
  }
}

class _ShipSheetView extends StatelessWidget {
  const _ShipSheetView();

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return BlocBuilder<ShipSheetCubit, ShipSheetState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.surfaceVoid,
            body: Center(
              child:
                  CircularProgressIndicator(color: AppColors.brandBrass),
            ),
          );
        }
        if (state.notFound) {
          return Scaffold(
            backgroundColor: AppColors.surfaceVoid,
            appBar: AppBar(backgroundColor: AppColors.surfaceNight),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.sheetNotFoundTitle,
                      style: AppTypography.displaySm
                          .copyWith(color: AppColors.brandBrassLight),
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    Text(
                      t.sheetNotFoundBody,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state.errorMessage != null) {
          return Scaffold(
            backgroundColor: AppColors.surfaceVoid,
            appBar: AppBar(backgroundColor: AppColors.surfaceNight),
            body: Center(
              child: Text(
                t.sheetErrorLoad,
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.stateCrimsonBright),
              ),
            ),
          );
        }
        final ship = state.ship!;
        return Scaffold(
          backgroundColor: AppColors.surfaceVoid,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceNight,
            title: Text(
              ship.name,
              style: AppTypography.bodyLg
                  .copyWith(color: AppColors.brandBrassLight),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s2),
                child: Center(
                  child: AppSavePulse(state: _pulseFrom(state.saveStatus)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.stateCrimsonBright),
                tooltip: t.sheetDeleteTooltip,
                onPressed: () => _confirmDelete(context, t),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.s4),
            children: [
              _ClassBadgeHeader(shipClass: ship.shipClass, label: t.sheetClassLabel),
              if (state.hasSaveError && state.saveErrorMessage != null) ...[
                const SizedBox(height: AppSpacing.s3),
                AppBanner(
                  tone: AppBannerTone.danger,
                  child: Text(state.saveErrorMessage!),
                ),
              ],
              const SizedBox(height: AppSpacing.s4),
              _IdentityCard(ship: ship),
              const SizedBox(height: AppSpacing.s4),
              _StatsCard(ship: ship),
              const SizedBox(height: AppSpacing.s4),
              _ModulesCard(modules: ship.modules),
              const SizedBox(height: AppSpacing.s4),
              _CrewCard(crew: ship.crew),
              const SizedBox(height: AppSpacing.s4),
              _NotesCard(ship: ship),
              const SizedBox(height: AppSpacing.s4),
              _HistoryCard(ship: ship),
              const SizedBox(height: AppSpacing.s4),
              _ProblemsCard(ship: ship),
              const SizedBox(height: AppSpacing.s8),
            ],
          ),
        );
      },
    );
  }

  AppSavePulseState _pulseFrom(ShipSheetSaveStatus status) =>
      switch (status) {
        ShipSheetSaveStatus.idle => AppSavePulseState.idle,
        ShipSheetSaveStatus.saving => AppSavePulseState.saving,
        ShipSheetSaveStatus.saved => AppSavePulseState.saved,
        ShipSheetSaveStatus.error => AppSavePulseState.error,
      };

  Future<void> _confirmDelete(
      BuildContext context, TranslationsShipsEn t) async {
    final cubit = context.read<ShipSheetCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceNight,
        title: Text(
          t.sheetDeleteConfirmTitle,
          style:
              AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          t.sheetDeleteConfirmBody,
          style:
              AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              t.sheetDeleteCancel,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.brandBrassLight),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              t.sheetDeleteConfirm,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.stateCrimsonBright),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await cubit.deleteShip();
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

// ── Class badge header ─────────────────────────────────────────────────────

class _ClassBadgeHeader extends StatelessWidget {
  const _ClassBadgeHeader({required this.shipClass, required this.label});

  final String shipClass;
  final String label;

  String _humanise(String cls) => cls
      .split('-')
      .map((w) =>
          w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppBadge(label: '$label: ${_humanise(shipClass)}'),
      ],
    );
  }
}

// ── Identity card ──────────────────────────────────────────────────────────

class _IdentityCard extends StatefulWidget {
  const _IdentityCard({required this.ship});

  final Ship ship;

  @override
  State<_IdentityCard> createState() => _IdentityCardState();
}

class _IdentityCardState extends State<_IdentityCard> {
  late final TextEditingController _name;
  late final TextEditingController _model;
  late final TextEditingController _registry;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.ship.name);
    _model = TextEditingController(text: widget.ship.model ?? '');
    _registry = TextEditingController(text: widget.ship.registry ?? '');
  }

  @override
  void didUpdateWidget(covariant _IdentityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncIfStale(_name, widget.ship.name);
    _syncIfStale(_model, widget.ship.model ?? '');
    _syncIfStale(_registry, widget.ship.registry ?? '');
  }

  void _syncIfStale(TextEditingController c, String next) {
    // Avoid clobbering the user's caret while typing — only sync when the
    // server-side value diverges (e.g. after the debounced PATCH lands).
    if (c.text != next && !c.value.composing.isValid) {
      c.text = next;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _model.dispose();
    _registry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    final cubit = context.read<ShipSheetCubit>();
    return AppCard(
      header: _CardTitle(text: t.sectionIdentity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppField(
            label: t.fieldName,
            required: true,
            child: AppInput(
              controller: _name,
              onChanged: cubit.updateName,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          AppField(
            label: t.fieldModel,
            child: AppInput(
              controller: _model,
              hintText: t.fieldOptionalHint,
              onChanged: (value) => cubit.updateModel(value.isEmpty ? null : value),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          AppField(
            label: t.fieldRegistry,
            child: AppInput(
              controller: _registry,
              hintText: t.fieldOptionalHint,
              onChanged: (value) =>
                  cubit.updateRegistry(value.isEmpty ? null : value),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats card ─────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.ship});

  final Ship ship;

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    final cubit = context.read<ShipSheetCubit>();
    return AppCard(
      header: _CardTitle(text: t.sectionStats),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CounterRow(
            label: t.statHull,
            current: ship.hull.current,
            max: ship.hull.max,
            onMinus: () => cubit.adjustHullCurrent(-1),
            onPlus: () => cubit.adjustHullCurrent(1),
            onMaxChanged: cubit.setHullMax,
          ),
          const SizedBox(height: AppSpacing.s3),
          _CounterRow(
            label: t.statEnergy,
            current: ship.energy.current,
            max: ship.energy.max,
            onMinus: () => cubit.adjustEnergyCurrent(-1),
            onPlus: () => cubit.adjustEnergyCurrent(1),
            onMaxChanged: cubit.setEnergyMax,
          ),
          const Divider(color: AppColors.brandBrassShadow, height: AppSpacing.s5),
          _StatField(
            label: t.statArmor,
            value: ship.armor,
            onChanged: cubit.setArmor,
          ),
          const SizedBox(height: AppSpacing.s3),
          _StatField(
            label: t.statManeuverability,
            value: ship.maneuverability,
            allowNegative: true,
            onChanged: cubit.setManeuverability,
          ),
          const SizedBox(height: AppSpacing.s3),
          _StatField(
            label: t.statSignature,
            value: ship.signature,
            allowNegative: true,
            onChanged: cubit.setSignature,
          ),
          const SizedBox(height: AppSpacing.s3),
          _StatField(
            label: t.statSpeed,
            value: ship.speed,
            onChanged: cubit.setSpeed,
          ),
          const SizedBox(height: AppSpacing.s3),
          _StatField(
            label: t.statCargoCapacity,
            value: ship.cargoCapacity,
            readOnly: true,
          ),
        ],
      ),
    );
  }
}

class _CounterRow extends StatefulWidget {
  const _CounterRow({
    required this.label,
    required this.current,
    required this.max,
    required this.onMinus,
    required this.onPlus,
    required this.onMaxChanged,
  });

  final String label;
  final int current;
  final int max;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<int> onMaxChanged;

  @override
  State<_CounterRow> createState() => _CounterRowState();
}

class _CounterRowState extends State<_CounterRow> {
  late final TextEditingController _maxCtrl;

  @override
  void initState() {
    super.initState();
    _maxCtrl = TextEditingController(text: widget.max.toString());
  }

  @override
  void didUpdateWidget(covariant _CounterRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.max.toString();
    if (_maxCtrl.text != next && !_maxCtrl.value.composing.isValid) {
      _maxCtrl.text = next;
    }
  }

  @override
  void dispose() {
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.label,
            style: AppTypography.bodyMd
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        AppButton(
          label: '−',
          variant: AppButtonVariant.ghost,
          size: AppButtonSize.sm,
          disabled: widget.current <= 0,
          onPressed: widget.onMinus,
        ),
        const SizedBox(width: AppSpacing.s2),
        Text(
          '${widget.current}',
          style: AppTypography.bodyLg
              .copyWith(color: AppColors.brandBrassLight, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: AppSpacing.s1),
        Text(
          '/',
          style: AppTypography.bodyMd
              .copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.s1),
        SizedBox(
          width: 56,
          child: AppInput(
            controller: _maxCtrl,
            inputType: AppInputType.number,
            size: AppInputSize.sm,
            onChanged: (raw) {
              final parsed = int.tryParse(raw);
              if (parsed != null) widget.onMaxChanged(parsed);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.s2),
        AppButton(
          label: '+',
          variant: AppButtonVariant.ghost,
          size: AppButtonSize.sm,
          onPressed: widget.onPlus,
        ),
      ],
    );
  }
}

class _StatField extends StatefulWidget {
  const _StatField({
    required this.label,
    required this.value,
    this.onChanged,
    this.allowNegative = false,
    this.readOnly = false,
  });

  final String label;
  final int value;
  final ValueChanged<int>? onChanged;
  final bool allowNegative;
  final bool readOnly;

  @override
  State<_StatField> createState() => _StatFieldState();
}

class _StatFieldState extends State<_StatField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _StatField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.value.toString();
    if (_ctrl.text != next && !_ctrl.value.composing.isValid) {
      _ctrl.text = next;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.label,
            style: AppTypography.bodyMd
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        SizedBox(
          width: 88,
          child: AppInput(
            controller: _ctrl,
            inputType: AppInputType.number,
            size: AppInputSize.sm,
            readOnly: widget.readOnly,
            onChanged: widget.readOnly
                ? null
                : (raw) {
                    final parsed = int.tryParse(raw);
                    if (parsed == null) return;
                    if (!widget.allowNegative && parsed < 0) return;
                    widget.onChanged?.call(parsed);
                  },
          ),
        ),
      ],
    );
  }
}

// ── Modules card ───────────────────────────────────────────────────────────

class _ModulesCard extends StatelessWidget {
  const _ModulesCard({required this.modules});

  final List<DomainShipModule> modules;

  static const _mandatorySlots = {'BRIDGE', 'REACTOR', 'DRIVE'};

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    // Mandatory first, then the rest in API order.
    final sorted = [
      ...modules.where((m) => _mandatorySlots.contains(m.slot)),
      ...modules.where((m) => !_mandatorySlots.contains(m.slot)),
    ];
    return AppCard(
      header: _CardTitle(text: t.sectionModules),
      child: sorted.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
              child: Text(
                t.modulesEmpty,
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.textSecondary),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final mod in sorted) _ModuleRow(module: mod),
              ],
            ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({required this.module});

  final DomainShipModule module;

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: AppBadge(
              label: module.slot,
              tone: AppBadgeTone.darkness,
              size: AppBadgeSize.sm,
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(
              module.name,
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (module.energyUse > 0)
            AppBadge(
              label: t.moduleEnergy(energy: module.energyUse),
              tone: AppBadgeTone.mystic,
              size: AppBadgeSize.sm,
            ),
        ],
      ),
    );
  }
}

// ── Crew card ──────────────────────────────────────────────────────────────

class _CrewCard extends StatelessWidget {
  const _CrewCard({required this.crew});

  final List<DomainCrewSlot> crew;

  static const _orderedPositions = [
    'captain',
    'pilot',
    'sensorOp',
    'gunner',
    'engineer',
    'serviceCrew',
  ];

  String _positionLabel(BuildContext context, String pos) {
    final t = context.t.ships;
    return switch (pos) {
      'captain' => t.crewCaptain,
      'pilot' => t.crewPilot,
      'sensorOp' => t.crewSensorOp,
      'gunner' => t.crewGunner,
      'engineer' => t.crewEngineer,
      'serviceCrew' => t.crewServiceCrew,
      _ => pos,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    final slotMap = <String, String?>{
      for (final s in crew) s.position: s.assignedCharacterId,
    };
    return AppCard(
      header: _CardTitle(text: t.sectionCrew),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final pos in _orderedPositions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _positionLabel(context, pos),
                      style: AppTypography.bodyMd
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    slotMap[pos] == null || slotMap[pos]!.isEmpty
                        ? t.crewVacant
                        : '#${slotMap[pos]!.substring(0, slotMap[pos]!.length.clamp(0, 8))}',
                    style: AppTypography.bodyMd.copyWith(
                      color: slotMap[pos] == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontStyle: slotMap[pos] == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Notes / History / Problems ─────────────────────────────────────────────

class _NotesCard extends StatefulWidget {
  const _NotesCard({required this.ship});

  final Ship ship;

  @override
  State<_NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends State<_NotesCard> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.ship.notes ?? '');
  }

  @override
  void didUpdateWidget(covariant _NotesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.ship.notes ?? '';
    if (_ctrl.text != next && !_ctrl.value.composing.isValid) {
      _ctrl.text = next;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    final cubit = context.read<ShipSheetCubit>();
    return AppCard(
      header: _CardTitle(text: t.sectionNotes),
      child: AppTextarea(
        controller: _ctrl,
        rows: 5,
        maxLength: 4096,
        placeholder: t.notesPlaceholder,
        onChanged: cubit.updateNotes,
      ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  const _HistoryCard({required this.ship});

  final Ship ship;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.ship.history ?? '');
  }

  @override
  void didUpdateWidget(covariant _HistoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.ship.history ?? '';
    if (_ctrl.text != next && !_ctrl.value.composing.isValid) {
      _ctrl.text = next;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    final cubit = context.read<ShipSheetCubit>();
    return AppCard(
      header: _CardTitle(text: t.sectionHistory),
      child: AppTextarea(
        controller: _ctrl,
        rows: 6,
        maxLength: 4096,
        placeholder: t.historyPlaceholder,
        onChanged: cubit.updateHistory,
      ),
    );
  }
}

class _ProblemsCard extends StatefulWidget {
  const _ProblemsCard({required this.ship});

  final Ship ship;

  @override
  State<_ProblemsCard> createState() => _ProblemsCardState();
}

class _ProblemsCardState extends State<_ProblemsCard> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.ship.problems.join(', '));
  }

  @override
  void didUpdateWidget(covariant _ProblemsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.ship.problems.join(', ');
    if (_ctrl.text != next && !_ctrl.value.composing.isValid) {
      _ctrl.text = next;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    final cubit = context.read<ShipSheetCubit>();
    return AppCard(
      header: _CardTitle(text: t.sectionProblems),
      child: AppField(
        label: t.problemsLabel,
        helpText: t.problemsHelp,
        child: AppInput(
          controller: _ctrl,
          onChanged: cubit.updateProblemsFromText,
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          AppTypography.bodyLg.copyWith(color: AppColors.brandBrassLight),
    );
  }
}
