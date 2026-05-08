import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:app_mobile/i18n/strings.g.dart';
import 'step_1_concept.dart' show _StepHeader;

/// Wizard step 2 — People & Background.
///
/// - Origin (AppSegControl — 4 options matching rulebook p.32–37).
/// - Upbringing (AppSegControl — 2 options).
/// - Age (numeric AppInput).
class Step2Background extends StatefulWidget {
  const Step2Background({super.key});

  @override
  State<Step2Background> createState() => _Step2BackgroundState();
}

class _Step2BackgroundState extends State<Step2Background> {
  late final TextEditingController _ageCtrl;

  @override
  void initState() {
    super.initState();
    final draft = context.read<CharacterWizardCubit>().state.draft;
    _ageCtrl = TextEditingController(
      text: draft.age != null ? draft.age.toString() : '',
    );
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;

    final originOptions = [
      AppSegOption(value: 'stationary', label: t.wizardOriginStationary),
      AppSegOption(value: 'zenithian', label: t.wizardOriginZenithian),
      AppSegOption(value: 'firstcome', label: t.wizardOriginFirstcome),
      AppSegOption(value: 'nomad', label: t.wizardOriginNomad),
    ];

    final upbringingOptions = [
      AppSegOption(value: 'plebeian', label: t.wizardUpbringingPlebeian),
      AppSegOption(value: 'statesman', label: t.wizardUpbringingStatesman),
    ];

    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      buildWhen: (p, n) =>
          p.draft.origin != n.draft.origin ||
          p.draft.upbringing != n.draft.upbringing,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeader(
                title: t.wizardStep2Title,
                blurb: t.wizardStep2Blurb,
              ),
              const SizedBox(height: AppSpacing.s6),
              // ── Origin ──────────────────────────────────────────────────
              AppField(
                label: t.wizardOriginLabel,
                child: _OriginPicker(
                  selected: state.draft.origin,
                  options: originOptions,
                  onChanged: (v) =>
                      context.read<CharacterWizardCubit>().updateOrigin(v),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              // ── Upbringing ───────────────────────────────────────────────
              AppField(
                label: t.wizardUpbringingLabel,
                child: AppSegControl<String>(
                  value: state.draft.upbringing ?? 'plebeian',
                  options: upbringingOptions,
                  onChanged: (v) =>
                      context.read<CharacterWizardCubit>().updateUpbringing(v),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              // ── Age ─────────────────────────────────────────────────────
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
    );
  }
}

/// 2×2 grid of origin cards (too wide for AppSegControl's 4-option constraint
/// on narrow screens). Each card shows the origin name and a short summary.
class _OriginPicker extends StatelessWidget {
  const _OriginPicker({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final String? selected;
  final List<AppSegOption<String>> options;
  final ValueChanged<String> onChanged;

  static const _originBlurbs = {
    'stationary':
        'Born on a station or planet. Shaped by the Consortium.',
    'zenithian':
        'Descended from colonists through the second portal on the Zenith.',
    'firstcome':
        'Bloodline of the first wave. Old families, ancestral debts.',
    'nomad':
        'Of the Nomad Federation — wanderers between the stars.',
  };

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s2,
      crossAxisSpacing: AppSpacing.s2,
      childAspectRatio: 2.2,
      children: options.map((o) {
        final isSelected = o.value == selected;
        return Semantics(
          button: true,
          selected: isSelected,
          label: o.label,
          child: GestureDetector(
            onTap: () => onChanged(o.value),
            child: AppCard(
              variant: isSelected
                  ? AppCardVariant.featured
                  : AppCardVariant.defaultVariant,
              padding: const EdgeInsets.all(AppSpacing.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    o.label,
                    style: AppTypography.bodySm.copyWith(
                      color: isSelected
                          ? AppColors.brandBrassLight
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? AppFontWeight.semibold
                          : AppFontWeight.regular,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _originBlurbs[o.value] ?? '',
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
