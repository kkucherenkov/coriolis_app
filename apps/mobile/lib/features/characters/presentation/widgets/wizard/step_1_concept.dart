import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Wizard step 1 — Concept.
///
/// - Name field (required, max 80 characters).
/// - Concept phrase textarea (max 120 characters).
class Step1Concept extends StatefulWidget {
  const Step1Concept({super.key});

  @override
  State<Step1Concept> createState() => _Step1ConceptState();
}

class _Step1ConceptState extends State<Step1Concept> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _conceptCtrl;
  late final FocusNode _nameFocus;

  @override
  void initState() {
    super.initState();
    final draft = context.read<CharacterWizardCubit>().state.draft;
    _nameCtrl = TextEditingController(text: draft.name ?? '');
    _conceptCtrl = TextEditingController(text: draft.concept ?? '');
    _nameFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _conceptCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return BlocListener<CharacterWizardCubit, CharacterWizardState>(
      listenWhen: (p, n) => p.character?.id != n.character?.id,
      listener: (_, state) {
        // When the draft is first created, sync any server defaults.
        final serverName = state.character?.name;
        if (serverName != null &&
            serverName != 'Untitled' &&
            _nameCtrl.text.isEmpty) {
          _nameCtrl.text = serverName;
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Step header ──────────────────────────────────────────────
            WizardStepHeader(
              title: t.wizardStep1Title,
              blurb: t.wizardStep1Blurb,
            ),
            const SizedBox(height: AppSpacing.s6),
            // ── Name ──────────────────────────────────────────────────────
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
            // ── Concept phrase ─────────────────────────────────────────────
            AppField(
              label: t.wizardConceptLabel,
              child: AppTextarea(
                controller: _conceptCtrl,
                placeholder: t.wizardConceptHint,
                rows: 3,
                maxLength: 120,
                onChanged: (v) =>
                    context.read<CharacterWizardCubit>().updateConcept(v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared step-header used by all six wizard steps.
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
