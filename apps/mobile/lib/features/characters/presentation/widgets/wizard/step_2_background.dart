import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_1_concept.dart' show WizardStepHeader;

/// Wizard step 2 — People & Background.
///
/// Aligned to the canonical Coriolis ST3001 domain:
///
/// - **Origin** — free-text narrative (max 200 chars per the OpenAPI
///   contract). No mechanical effect.
/// - **Upbringing** — segmented control over the three canonical strata
///   `plebeian | stationary | aristocrat` (drives attribute / skill point
///   budgets, starting reputation and `startingWealth`).
/// - **Age** — local-only numeric input; the canonical biography step
///   (T-WIZARD-MOBILE-REORDER) will own this once the reorder lands.
class Step2Background extends StatefulWidget {
  const Step2Background({super.key});

  @override
  State<Step2Background> createState() => _Step2BackgroundState();
}

class _Step2BackgroundState extends State<Step2Background> {
  late final TextEditingController _ageCtrl;
  late final TextEditingController _originCtrl;

  @override
  void initState() {
    super.initState();
    final draft = context.read<CharacterWizardCubit>().state.draft;
    _ageCtrl = TextEditingController(
      text: draft.age != null ? draft.age.toString() : '',
    );
    _originCtrl = TextEditingController(text: draft.origin ?? '');
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _originCtrl.dispose();
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
              WizardStepHeader(
                title: t.wizardStep2Title,
                blurb: t.wizardStep2Blurb,
              ),
              const SizedBox(height: AppSpacing.s6),
              // ── Origin (free text) ─────────────────────────────────────
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
              // ── Upbringing (3 canonical options) ───────────────────────
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
              // ── Age (local-only) ───────────────────────────────────────
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
