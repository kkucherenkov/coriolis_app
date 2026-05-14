import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Canonical CrewConcept enum values (Dart-side `EnumClass.name` form).
const List<String> kCanonicalCrewConcepts = <String>[
  'freeTrader',
  'mercenary',
  'explorer',
  'agents',
  'pilgrim',
];

/// Wizard step 1 — Biography.
///
/// Per [CHARACTER_WIZARD §3.1](../../../../../../specs/design/CHARACTER_WIZARD.md):
///
/// > Inputs: upbringing (required), origin (optional free text ≤200 chars),
/// > crewConcept (optional), age (optional positive integer).
///
/// Mobile additionally captures `name` here — Step 2 onwards never asks for
/// it again. Age stays local (no canonical field on the API contract).
class Step1Biography extends StatefulWidget {
  const Step1Biography({super.key});

  @override
  State<Step1Biography> createState() => _Step1BiographyState();
}

class _Step1BiographyState extends State<Step1Biography> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _originCtrl;
  late final TextEditingController _ageCtrl;
  late final FocusNode _nameFocus;

  @override
  void initState() {
    super.initState();
    final draft = context.read<CharacterWizardCubit>().state.draft;
    _nameCtrl = TextEditingController(text: draft.name ?? '');
    _originCtrl = TextEditingController(text: draft.origin ?? '');
    _ageCtrl = TextEditingController(
      text: draft.age != null ? draft.age.toString() : '',
    );
    _nameFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _originCtrl.dispose();
    _ageCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;

    final upbringingOptions = [
      AppSegOption(value: 'plebeian', label: t.wizardUpbringingPlebeian),
      AppSegOption(value: 'stationary', label: t.wizardUpbringingStationary),
      AppSegOption(value: 'aristocrat', label: t.wizardUpbringingAristocrat),
    ];

    return BlocListener<CharacterWizardCubit, CharacterWizardState>(
      listenWhen: (p, n) => p.character?.id != n.character?.id,
      listener: (_, state) {
        final serverName = state.character?.name;
        if (serverName != null &&
            serverName != 'Untitled' &&
            _nameCtrl.text.isEmpty) {
          _nameCtrl.text = serverName;
        }
      },
      child: BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
        buildWhen: (p, n) =>
            p.draft.upbringing != n.draft.upbringing ||
            p.draft.crewConcept != n.draft.crewConcept,
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WizardStepHeader(
                  title: t.wizardStep1Title,
                  blurb: t.wizardStep1Blurb,
                ),
                const SizedBox(height: AppSpacing.s6),
                // ── Name ───────────────────────────────────────────────────
                AppField(
                  label: t.wizardNameLabel,
                  required: true,
                  labelFocusNode: _nameFocus,
                  child: AppInput(
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    hintText: t.wizardNameHint,
                    autofocus: true,
                    onChanged: (v) {
                      if (v.length <= 80) {
                        context.read<CharacterWizardCubit>().updateName(v);
                      }
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                // ── Origin (free text) ──────────────────────────────────
                AppField(
                  label: t.wizardOriginLabel,
                  child: AppInput(
                    controller: _originCtrl,
                    hintText: t.wizardOriginHint,
                    onChanged: (v) {
                      if (v.length <= 200) {
                        context
                            .read<CharacterWizardCubit>()
                            .updateOrigin(v);
                      }
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                // ── Upbringing (3 canonical options) ────────────────────
                AppField(
                  label: t.wizardUpbringingLabel,
                  child: AppSegControl<String>(
                    value: state.draft.upbringing ?? 'plebeian',
                    options: upbringingOptions,
                    onChanged: (v) => context
                        .read<CharacterWizardCubit>()
                        .updateUpbringing(v),
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                // ── Crew concept (5 canonical options) ──────────────────
                AppField(
                  label: t.wizardCrewConceptLabel,
                  child: _CrewConceptGrid(
                    selected: state.draft.crewConcept,
                    onChanged: (v) => context
                        .read<CharacterWizardCubit>()
                        .updateCrewConcept(v),
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                // ── Age (local-only) ───────────────────────────────────
                AppField(
                  label: t.wizardAgeLabel,
                  child: AppInput(
                    controller: _ageCtrl,
                    hintText: t.wizardAgeHint,
                    inputType: AppInputType.number,
                    onChanged: (v) {
                      final parsed = int.tryParse(v);
                      if (parsed != null && parsed > 0) {
                        context.read<CharacterWizardCubit>().updateAge(parsed);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Shared step-header used by every wizard step.
class WizardStepHeader extends StatelessWidget {
  const WizardStepHeader({super.key, required this.title, this.blurb});

  final String title;
  final String? blurb;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.displayMd.copyWith(
            color: AppColors.brandBrassLight,
          ),
        ),
        const SizedBox(height: AppSpacing.s2),
        Container(
          height: 1,
          color: AppColors.brandBrassDeep,
        ),
        if (blurb != null) ...[
          const SizedBox(height: AppSpacing.s3),
          Text(
            blurb!,
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

/// 2×3 grid of crew-concept cards.
class _CrewConceptGrid extends StatelessWidget {
  const _CrewConceptGrid({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s2,
      crossAxisSpacing: AppSpacing.s2,
      childAspectRatio: 1.8,
      children: kCanonicalCrewConcepts.map((id) {
        final isSelected = id == selected;
        return Semantics(
          button: true,
          selected: isSelected,
          label: _crewLabel(t, id),
          child: GestureDetector(
            onTap: () => onChanged(id),
            child: AppCard(
              variant: isSelected
                  ? AppCardVariant.featured
                  : AppCardVariant.defaultVariant,
              padding: const EdgeInsets.all(AppSpacing.s2),
              child: Center(
                child: Text(
                  _crewLabel(t, id),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    color: isSelected
                        ? AppColors.brandBrassLight
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? AppFontWeight.semibold
                        : AppFontWeight.regular,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

String _crewLabel(TranslationsCharactersEn t, String id) => switch (id) {
      'freeTrader' => t.crewFreeTrader,
      'mercenary' => t.crewMercenary,
      'explorer' => t.crewExplorer,
      'agents' => t.crewAgents,
      'pilgrim' => t.crewPilgrim,
      _ => id,
    };
