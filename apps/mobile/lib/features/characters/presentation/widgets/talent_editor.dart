import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Talent list for the Talents tab.
class TalentsTabContent extends StatelessWidget {
  const TalentsTabContent({super.key, required this.talents});

  final List<DomainTalent> talents;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final cubit = context.read<CharacterSheetCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (talents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
            child: Text(
              t.talentEmpty,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...talents.map((talent) => _TalentRow(
                talent: talent,
                onEdit: () => _openEditor(context, cubit, talent: talent),
              )),
        const SizedBox(height: AppSpacing.s3),
        AppButton(
          label: '+ ${t.talentAddTitle}',
          variant: AppButtonVariant.ghost,
          onPressed: () => _openEditor(context, cubit),
        ),
      ],
    );
  }

  void _openEditor(
    BuildContext context,
    CharacterSheetCubit cubit, {
    DomainTalent? talent,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceNight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _TalentEditorSheet(talent: talent),
      ),
    );
  }
}

class _TalentRow extends StatelessWidget {
  const _TalentRow({required this.talent, required this.onEdit});

  final DomainTalent talent;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        talent.name,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.brandBrassLight,
                          fontWeight: AppFontWeight.semibold,
                        ),
                      ),
                    ),
                    // Rank badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.brandBrassDeep),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${talent.rank}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.brandBrass,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                if (talent.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    talent.description,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Edit ${talent.name}',
            child: GestureDetector(
              onTap: onEdit,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.brandBrassDeep,
                    size: AppSpacing.s4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom-sheet form for adding or editing a talent.
class _TalentEditorSheet extends StatefulWidget {
  const _TalentEditorSheet({this.talent});
  final DomainTalent? talent;

  @override
  State<_TalentEditorSheet> createState() => _TalentEditorSheetState();
}

class _TalentEditorSheetState extends State<_TalentEditorSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late int _rank;

  bool get _isEdit => widget.talent != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.talent?.name ?? '');
    _descCtrl = TextEditingController(text: widget.talent?.description ?? '');
    _rank = widget.talent?.rank ?? 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final cubit = context.read<CharacterSheetCubit>();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s4,
        right: AppSpacing.s4,
        top: AppSpacing.s4,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: AppSpacing.s11,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.brandBrassDeep,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            _isEdit ? t.talentEditTitle : t.talentAddTitle,
            style: AppTypography.displaySm.copyWith(color: AppColors.brandBrass),
          ),
          const SizedBox(height: AppSpacing.s4),
          AppField(
            label: t.talentNameLabel,
            child: AppInput(
              controller: _nameCtrl,
              hintText: t.talentNameHint,
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
            label: '${t.talentRankLabel}: $_rank',
            child: Row(
              children: List.generate(3, (i) {
                final rank = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rank = rank),
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.only(right: AppSpacing.s2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rank <= _rank ? AppColors.brandBrass : Colors.transparent,
                      border: Border.all(color: AppColors.brandBrassDeep),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: AppTypography.bodySm.copyWith(
                          color: rank <= _rank
                              ? AppColors.textOnBrass
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          AppButton(
            label: t.talentSave,
            onPressed: () => _save(context, cubit),
          ),
          if (_isEdit) ...[
            const SizedBox(height: AppSpacing.s2),
            AppButton(
              label: t.talentDelete,
              variant: AppButtonVariant.danger,
              onPressed: () => _delete(context, cubit),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context, CharacterSheetCubit cubit) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final desc = _descCtrl.text.trim();
    if (_isEdit) {
      await cubit.updateTalent(
        widget.talent!.id,
        name: name,
        description: desc,
        rank: _rank,
      );
    } else {
      await cubit.addTalent(name: name, description: desc, rank: _rank);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _delete(BuildContext context, CharacterSheetCubit cubit) async {
    await cubit.removeTalent(widget.talent!.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}
