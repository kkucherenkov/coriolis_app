import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_state.dart';
import 'package:app_mobile/i18n/strings.g.dart';
import 'package:app_mobile/shared/di/injector.dart';

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
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.stateCrimsonBright,
                ),
              ),
            ),
          );
        }
        final character = state.character!;
        return Scaffold(
          backgroundColor: AppColors.surfaceVoid,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceNight,
            title: Text(
              character.name,
              style: AppTypography.displaySm
                  .copyWith(color: AppColors.brandBrass),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              _SaveIndicator(saveStatus: state.saveStatus),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.stateCrimsonBright),
                tooltip: t.deleteTooltip,
                onPressed: () => _confirmDelete(context, t),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header card: avatar + editable name + concept
                  AppCard(
                    variant: AppCardVariant.featured,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppAvatar(
                              name: character.name,
                              size: AppAvatarSize.lg,
                            ),
                            const SizedBox(width: AppSpacing.s4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _EditableNameField(
                                    initialValue: character.name,
                                    label: t.nameLabel,
                                    hint: t.nameHint,
                                    onChanged: (v) => context
                                        .read<CharacterSheetCubit>()
                                        .updateName(v),
                                  ),
                                  const SizedBox(height: AppSpacing.s3),
                                  _EditableConceptField(
                                    initialValue: character.concept ?? '',
                                    label: t.conceptLabel,
                                    hint: t.conceptHint,
                                    onChanged: (v) => context
                                        .read<CharacterSheetCubit>()
                                        .updateConcept(v),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  // Body placeholder for Epic 5
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.construction,
                            color: AppColors.brandBrassDeep,
                            size: 32,
                          ),
                          const SizedBox(height: AppSpacing.s3),
                          Text(
                            t.sheetPlaceholder,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.hasSaveError) ...[
                    const SizedBox(height: AppSpacing.s3),
                    Text(
                      state.saveErrorMessage ?? '',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.stateCrimsonBright,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
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
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              t.deleteCancel,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.brandBrassLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              t.deleteConfirm,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.stateCrimsonBright,
              ),
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

/// Trailing AppBar widget showing the save cycle status.
class _SaveIndicator extends StatelessWidget {
  const _SaveIndicator({required this.saveStatus});

  final CharacterSheetSaveStatus saveStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s3),
      child: AnimatedSwitcher(
        duration: AppDuration.fast,
        child: switch (saveStatus) {
          CharacterSheetSaveStatus.saving => const SizedBox(
              key: ValueKey('saving'),
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandBrass,
              ),
            ),
          CharacterSheetSaveStatus.saved => const Icon(
              key: ValueKey('saved'),
              Icons.check_circle_outline,
              color: AppColors.stateSuccess,
              size: 20,
            ),
          CharacterSheetSaveStatus.error => const Icon(
              key: ValueKey('error'),
              Icons.error_outline,
              color: AppColors.stateCrimsonBright,
              size: 20,
            ),
          CharacterSheetSaveStatus.idle => const SizedBox(
              key: ValueKey('idle'),
              width: 20,
            ),
        },
      ),
    );
  }
}

/// Stateful editable field that manages its own [TextEditingController].
///
/// The controller is initialized from [initialValue] once; subsequent changes
/// come from the user — the cubit update is debounced upstream.
class _EditableNameField extends StatefulWidget {
  const _EditableNameField({
    required this.initialValue,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final String initialValue;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<_EditableNameField> createState() => _EditableNameFieldState();
}

class _EditableNameFieldState extends State<_EditableNameField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppField(
      label: widget.label,
      child: AppInput(
        controller: _ctrl,
        hintText: widget.hint,
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _EditableConceptField extends StatefulWidget {
  const _EditableConceptField({
    required this.initialValue,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final String initialValue;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<_EditableConceptField> createState() => _EditableConceptFieldState();
}

class _EditableConceptFieldState extends State<_EditableConceptField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppField(
      label: widget.label,
      child: AppInput(
        controller: _ctrl,
        hintText: widget.hint,
        onChanged: widget.onChanged,
      ),
    );
  }
}
