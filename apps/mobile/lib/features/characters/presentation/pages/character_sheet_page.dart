import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_sheet/character_sheet_state.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/attributes_block.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/conditions_panel.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/hero_counters.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/item_editor.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/sheet_header.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/skills_block.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/talent_editor.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/shared/di/injector.dart';

/// Character sheet detail page.
///
/// Wraps [CharacterSheetCubit] via [BlocProvider]. The character id is passed
/// as a [Navigator] argument (String).
class CharacterSheetPage extends StatelessWidget {
  const CharacterSheetPage({super.key, required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CharacterSheetCubit>(
      create: (_) => getIt<CharacterSheetCubit>()..load(characterId),
      child: const _CharacterSheetView(),
    );
  }
}

class _CharacterSheetView extends StatelessWidget {
  const _CharacterSheetView();

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return BlocBuilder<CharacterSheetCubit, CharacterSheetState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.surfaceVoid,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.brandBrass),
            ),
          );
        }
        if (state.errorMessage != null) {
          return Scaffold(
            backgroundColor: AppColors.surfaceVoid,
            appBar: AppBar(backgroundColor: AppColors.surfaceNight),
            body: Center(
              child: Text(
                state.errorMessage!,
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.stateCrimsonBright),
              ),
            ),
          );
        }
        final character = state.character!;
        return Scaffold(
          backgroundColor: AppColors.surfaceVoid,
          // Delete action in app bar
          appBar: AppBar(
            backgroundColor: AppColors.surfaceNight,
            titleSpacing: 0,
            title: const SizedBox.shrink(),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.stateCrimsonBright),
                tooltip: t.deleteTooltip,
                onPressed: () => _confirmDelete(context, t),
              ),
            ],
          ),
          body: Column(
            children: [
              // Sticky header: avatar, name, save pulse, HP/MP, conditions
              SheetHeader(
                character: character,
                saveStatus: state.saveStatus,
              ),
              // Tab bar
              _SheetTabBar(activeTab: state.activeTab),
              // Tab content — scrollable
              Expanded(
                child: _SheetTabContent(
                  character: character,
                  activeTab: state.activeTab,
                ),
              ),
              // Save error banner
              if (state.hasSaveError)
                Material(
                  color: AppColors.stateCrimson,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s4,
                      vertical: AppSpacing.s2,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.textPrimary, size: AppSpacing.s4),
                        const SizedBox(width: AppSpacing.s2),
                        Expanded(
                          child: Text(
                            state.saveErrorMessage ?? '',
                            style: AppTypography.bodySm
                                .copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, TranslationsCharactersEn t) async {
    final cubit = context.read<CharacterSheetCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceNight,
        title: Text(
          t.deleteConfirmTitle,
          style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          t.deleteConfirmBody,
          style:
              AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              t.deleteCancel,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.brandBrassLight),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              t.deleteConfirm,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.stateCrimsonBright),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await cubit.deleteCharacter();
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

/// Bottom tab bar (Stats / Gear / Talents / Notes).
class _SheetTabBar extends StatelessWidget {
  const _SheetTabBar({required this.activeTab});

  final CharacterSheetTab activeTab;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final cubit = context.read<CharacterSheetCubit>();
    final tabs = [
      (tab: CharacterSheetTab.stats, label: t.tabStats),
      (tab: CharacterSheetTab.gear, label: t.tabGear),
      (tab: CharacterSheetTab.talents, label: t.tabTalents),
      (tab: CharacterSheetTab.notes, label: t.tabNotes),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceNight,
        border: Border(
          bottom: BorderSide(color: AppColors.brandBrassDeep),
        ),
      ),
      child: Row(
        children: tabs
            .map((entry) => Expanded(
                  child: Semantics(
                    button: true,
                    selected: activeTab == entry.tab,
                    child: GestureDetector(
                      onTap: () => cubit.emit(
                        context
                            .read<CharacterSheetCubit>()
                            .state
                            .copyWith(activeTab: entry.tab),
                      ),
                      child: _TabItem(
                        label: entry.label,
                        isActive: activeTab == entry.tab,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? AppColors.brandBrassLight : AppColors.textSecondary;
    return SizedBox(
      height: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(color: color, fontSize: 11),
          ),
          const SizedBox(height: AppSpacing.s1),
          if (isActive)
            Container(
              width: AppSpacing.s4,
              height: 2,
              color: AppColors.brandBrass,
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }
}

/// Tab content router.
class _SheetTabContent extends StatelessWidget {
  const _SheetTabContent({
    required this.character,
    required this.activeTab,
  });

  final Character character;
  final CharacterSheetTab activeTab;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: switch (activeTab) {
        CharacterSheetTab.stats => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeroCounters(character: character),
              const SizedBox(height: AppSpacing.s3),
              AttributesBlock(attributes: character.attributes),
              const SizedBox(height: AppSpacing.s3),
              SkillsBlock(
                skills: character.skills,
                attributes: character.attributes,
              ),
              const SizedBox(height: AppSpacing.s3),
              ConditionsPanel(
                conditions: character.conditions,
                criticalInjuries: character.criticalInjuries,
              ),
              const SizedBox(height: AppSpacing.s4),
            ],
          ),
        CharacterSheetTab.gear => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GearTabContent(inventory: character.inventory),
              const SizedBox(height: AppSpacing.s4),
            ],
          ),
        CharacterSheetTab.talents => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TalentsTabContent(talents: character.talents),
              const SizedBox(height: AppSpacing.s4),
            ],
          ),
        CharacterSheetTab.notes => _NotesTab(notes: character.notes),
      },
    );
  }
}

/// Notes tab — editable textarea (Markdown; no render in v1).
class _NotesTab extends StatefulWidget {
  const _NotesTab({this.notes});
  final String? notes;

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.notes ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return AppTextarea(
      controller: _ctrl,
      placeholder: t.notesHint,
      rows: 20,
      onChanged: (v) =>
          context.read<CharacterSheetCubit>().updateNotes(v),
    );
  }
}
