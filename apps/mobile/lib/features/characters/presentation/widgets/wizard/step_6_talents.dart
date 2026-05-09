import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_1_concept.dart' show WizardStepHeader;

// TODO(wizard-step-7-relationships): Step 7 Relationships is deferred.

/// Wizard step 6 — Talents preview.
///
/// Pick 0–3 free-form talents. Each talent has a name, description, and
/// optional icon affinity. "Add talent" opens a bottom sheet.
class Step6Talents extends StatelessWidget {
  const Step6Talents({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;

    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      buildWhen: (p, n) => p.draft.pendingTalents != n.draft.pendingTalents,
      builder: (context, state) {
        final talents = state.draft.pendingTalents ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WizardStepHeader(
                title: t.wizardStep6Title,
                blurb: t.wizardStep6Blurb,
              ),
              const SizedBox(height: AppSpacing.s4),
              // Talent count indicator
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.wizardTalentsChosen.toUpperCase(),
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.18 * 11,
                        color: AppColors.brandBrass,
                      ),
                    ),
                    Text(
                      '${talents.length} / 3',
                      style: AppTypography.monoStatMd.copyWith(
                        color: talents.length == 3
                            ? AppColors.stateSuccess
                            : AppColors.brandBrassLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Talent cards
              ...List.generate(talents.length, (i) {
                final talent = talents[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s3),
                  child: _TalentCard(
                    talent: talent,
                    onRemove: () => context
                        .read<CharacterWizardCubit>()
                        .removePendingTalent(i),
                  ),
                );
              }),
              // "Add talent" button (visible when < 3 talents).
              if (talents.length < 3) ...[
                const SizedBox(height: AppSpacing.s2),
                AppButton(
                  label: t.wizardAddTalent,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => _openAddTalentSheet(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddTalentSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceNight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<CharacterWizardCubit>(),
        child: const _AddTalentSheet(),
      ),
    );
  }
}

/// Card showing a single pending talent with a remove button.
class _TalentCard extends StatelessWidget {
  const _TalentCard({required this.talent, required this.onRemove});

  final PendingTalent talent;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return AppCard(
      variant: AppCardVariant.featured,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  talent.name,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.brandBrassLight,
                    fontWeight: AppFontWeight.semibold,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: t.talentDelete,
                child: GestureDetector(
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.s2),
                    child: Icon(
                      Icons.close,
                      size: AppSpacing.s4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (talent.iconAffinity != null) ...[
            const SizedBox(height: 2),
            Text(
              talent.iconAffinity!.toUpperCase(),
              style: AppTypography.bodySm.copyWith(
                fontSize: 9,
                letterSpacing: 0.16 * 9,
                color: AppColors.brandBrass,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s2),
          Text(
            talent.description,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for adding a new talent.
class _AddTalentSheet extends StatefulWidget {
  const _AddTalentSheet();

  @override
  State<_AddTalentSheet> createState() => _AddTalentSheetState();
}

class _AddTalentSheetState extends State<_AddTalentSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _affinityCtrl = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _affinityCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = context.t.characters.talentNameHint);
      return;
    }
    final talent = PendingTalent(
      name: name,
      description: _descCtrl.text.trim(),
      iconAffinity: _affinityCtrl.text.trim().isEmpty
          ? null
          : _affinityCtrl.text.trim(),
    );
    context.read<CharacterWizardCubit>().addPendingTalent(talent);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s4,
        right: AppSpacing.s4,
        top: AppSpacing.s5,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.talentAddTitle,
            style: AppTypography.displaySm.copyWith(
              color: AppColors.brandBrassLight,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          AppField(
            label: t.talentNameLabel,
            required: true,
            errorText: _nameError,
            child: AppInput(
              controller: _nameCtrl,
              hintText: t.talentNameHint,
              autofocus: true,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          AppField(
            label: t.talentDescLabel,
            child: AppTextarea(
              controller: _descCtrl,
              placeholder: t.talentDescHint,
              rows: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          AppField(
            label: t.wizardTalentAffinityLabel,
            child: AppInput(
              controller: _affinityCtrl,
              hintText: t.wizardTalentAffinityHint,
            ),
          ),
          const SizedBox(height: AppSpacing.s5),
          AppButton(
            label: t.talentSave,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
