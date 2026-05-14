import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Persistent chrome for the character creation wizard.
///
/// Renders:
/// - A brass progress bar underneath the AppBar showing step N/7.
/// - A [PageView] body hosting the step widget supplied by the parent.
/// - A bottom navigation row: Back | Save & exit | Next (or Forge on step 7).
///
/// Navigation logic (next/back) is delegated to [CharacterWizardCubit].
/// The [onSaveAndExit] callback lets the parent navigate to the dashboard
/// without losing the draft.
/// The [onForge] callback is invoked after [CharacterWizardCubit.forge]
/// succeeds on step 6.
class WizardShell extends StatelessWidget {
  const WizardShell({
    super.key,
    required this.pageController,
    required this.steps,
    required this.onSaveAndExit,
    required this.onForge,
  });

  /// Controls the inner [PageView].
  final PageController pageController;

  /// One widget per step (indices 0..5).
  final List<Widget> steps;

  /// Called when "Save & exit" is tapped (draft already persisted on server).
  final VoidCallback onSaveAndExit;

  /// Called after [CharacterWizardCubit.forge] returns a non-null character.
  final void Function(String characterId) onForge;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CharacterWizardCubit, CharacterWizardState>(
      listener: (context, state) {
        // Sync the page view when the cubit step changes (e.g. on resume).
        final targetPage = state.step - 1;
        if (pageController.hasClients &&
            pageController.page?.round() != targetPage) {
          pageController.animateToPage(
            targetPage,
            duration: AppDuration.dDefault,
            curve: AppEasing.standard,
          );
        }
      },
      builder: (context, state) {
        final t = context.t.characters;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Progress bar ──────────────────────────────────────────────
            AppProgress(
              value: state.step.toDouble(),
              max: 7.0,
              size: AppProgressSize.sm,
              semanticLabel: t.wizardProgressLabel,
            ),
            // ── Step label row ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s2,
              ),
              child: _StepLabels(currentStep: state.step),
            ),
            // ── Step content ──────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (_, i) => steps[i],
              ),
            ),
            // ── Bottom navigation ──────────────────────────────────────────
            _WizardNavBar(
              step: state.step,
              isBusy: state.isLoading || state.isSaving,
              onBack: state.step > 1
                  ? () => context.read<CharacterWizardCubit>().back()
                  : null,
              onSaveAndExit: onSaveAndExit,
              onNext: state.step < 7
                  ? () async {
                      final ok =
                          await context.read<CharacterWizardCubit>().next();
                      if (!ok && context.mounted) {
                        _showSaveError(context, state.lastError);
                      }
                    }
                  : null,
              onForge: state.step == 7
                  ? () async {
                      final character =
                          await context.read<CharacterWizardCubit>().forge();
                      if (character != null && context.mounted) {
                        onForge(character.id);
                      } else if (context.mounted) {
                        _showSaveError(
                            context,
                            context
                                .read<CharacterWizardCubit>()
                                .state
                                .lastError);
                      }
                    }
                  : null,
            ),
            // ── Error banner ──────────────────────────────────────────────
            if (state.hasError && state.lastError != null)
              _ErrorBanner(message: state.lastError!),
          ],
        );
      },
    );
  }

  static void _showSaveError(BuildContext context, String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.stateCrimson,
        content: Text(
          message,
          style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// Step label strip showing all 6 steps with active/inactive styling.
class _StepLabels extends StatelessWidget {
  const _StepLabels({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final labels = [
      t.wizard.step.biography.label,
      t.wizard.step.concept.label,
      t.wizard.step.role.label,
      t.wizard.step.attributes.label,
      t.wizard.step.skills.label,
      t.wizard.step.talents.label,
      t.wizard.step.icon.label,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (i) {
        final active = i < currentStep;
        return Flexible(
          child: Text(
            labels[i].toUpperCase(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(
              fontSize: 9,
              letterSpacing: 0.18 * 9,
              color: active ? AppColors.brandBrassLight : AppColors.textSecondary,
              fontWeight:
                  i == currentStep - 1 ? AppFontWeight.semibold : AppFontWeight.regular,
            ),
          ),
        );
      }),
    );
  }
}

/// Bottom navigation row.
class _WizardNavBar extends StatelessWidget {
  const _WizardNavBar({
    required this.step,
    required this.isBusy,
    required this.onSaveAndExit,
    this.onBack,
    this.onNext,
    this.onForge,
  });

  final int step;
  final bool isBusy;
  final VoidCallback onSaveAndExit;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onForge;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.brandBrassDeep)),
        color: AppColors.surfaceNight,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s3,
      ),
      child: Row(
        children: [
          // Back button
          AppButton(
            label: t.wizardBack,
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.sm,
            disabled: onBack == null || isBusy,
            onPressed: onBack,
          ),
          const SizedBox(width: AppSpacing.s2),
          // Save & exit
          AppButton(
            label: t.wizardSaveExit,
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.sm,
            disabled: isBusy,
            onPressed: isBusy ? null : onSaveAndExit,
          ),
          const Spacer(),
          // Next or Forge
          if (onForge != null)
            AppButton(
              label: t.wizardForge,
              variant: AppButtonVariant.primary,
              size: AppButtonSize.sm,
              loading: isBusy,
              onPressed: isBusy ? null : onForge,
            )
          else
            AppButton(
              label: t.wizardNext,
              variant: AppButtonVariant.primary,
              size: AppButtonSize.sm,
              loading: isBusy,
              disabled: onNext == null,
              onPressed: onNext,
            ),
        ],
      ),
    );
  }
}

/// Collapsible error banner at the bottom of the shell.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
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
                message,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
