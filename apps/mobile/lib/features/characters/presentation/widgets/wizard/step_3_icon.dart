import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:app_mobile/i18n/strings.g.dart';
import 'step_1_concept.dart' show _StepHeader;

/// Wizard step 3 — Nine Icons.
///
/// Renders a 3×3 grid of labelled cards. The selected card pulses a teal
/// aura via an [AnimationController] scale + opacity tween.
///
/// [MediaQuery.disableAnimations] → no animation, static teal border only.
class Step3Icon extends StatelessWidget {
  const Step3Icon({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      buildWhen: (p, n) => p.draft.selectedIcon != n.draft.selectedIcon,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeader(
                title: t.wizardStep3Title,
                blurb: t.wizardStep3Blurb,
              ),
              const SizedBox(height: AppSpacing.s6),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.s3,
                  crossAxisSpacing: AppSpacing.s3,
                  childAspectRatio: 0.85,
                ),
                itemCount: CoriolisIcon.values.length,
                itemBuilder: (ctx, i) {
                  final icon = CoriolisIcon.values[i];
                  final isSelected = state.draft.selectedIcon == icon;
                  return _IconCard(
                    icon: icon,
                    isSelected: isSelected,
                    onTap: () =>
                        context.read<CharacterWizardCubit>().selectIcon(icon),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One icon card in the 3×3 grid.
///
/// Animates a teal halo pulse on the selected card unless the OS has
/// reduced-motion enabled ([MediaQuery.disableAnimations]).
class _IconCard extends StatefulWidget {
  const _IconCard({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final CoriolisIcon icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_IconCard> createState() => _IconCardState();
}

class _IconCardState extends State<_IconCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: AppEasing.standard),
    );
    _opacityAnim = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _ctrl, curve: AppEasing.standard),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(_IconCard old) {
    super.didUpdateWidget(old);
    if (old.isSelected != widget.isSelected) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final disableAnimations =
        MediaQuery.of(context).disableAnimations;
    if (widget.isSelected && !disableAnimations) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final name = _iconName(t, widget.icon);
    final domain = _iconDomain(t, widget.icon);
    final letter = _iconLetter(widget.icon);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    Widget card = AppCard(
      variant: widget.isSelected
          ? AppCardVariant.featured
          : AppCardVariant.defaultVariant,
      padding: const EdgeInsets.all(AppSpacing.s3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glyph medallion — labelled AppIcon substitute.
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceDawn,
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.stateMysticTeal
                    : AppColors.brandBrassDeep,
                width: widget.isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                letter,
                style: AppTypography.displaySm.copyWith(
                  color: widget.isSelected
                      ? AppColors.stateMysticTeal
                      : AppColors.brandBrass,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: widget.isSelected
                  ? AppColors.brandBrassLight
                  : AppColors.textSecondary,
              fontWeight: widget.isSelected
                  ? AppFontWeight.semibold
                  : AppFontWeight.regular,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            domain,
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    // Teal halo wrapper.
    if (widget.isSelected) {
      if (disableAnimations) {
        // Static teal halo.
        card = DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md + 2),
            boxShadow: AppShadows.iconGlow,
          ),
          child: card,
        );
      } else {
        // Animated pulsing halo.
        card = AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: Opacity(
              opacity: _opacityAnim.value,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md + 2),
                  boxShadow: AppShadows.iconGlow,
                ),
                child: child,
              ),
            ),
          ),
          child: card,
        );
      }
    }

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: name,
      child: GestureDetector(
        onTap: widget.onTap,
        child: card,
      ),
    );
  }
}

// ── Icon data helpers ──────────────────────────────────────────────────────

String _iconName(TranslationsCharactersEn t, CoriolisIcon icon) =>
    switch (icon) {
      CoriolisIcon.theJudiciary => t.iconNameJudiciary,
      CoriolisIcon.theTraveler => t.iconNameTraveler,
      CoriolisIcon.theMessenger => t.iconNameMessenger,
      CoriolisIcon.theLegionnaire => t.iconNameLegionnaire,
      CoriolisIcon.theNurse => t.iconNameNurse,
      CoriolisIcon.theMerchant => t.iconNameMerchant,
      CoriolisIcon.theSymbiont => t.iconNameSymbiont,
      CoriolisIcon.theFaceless => t.iconNameFaceless,
      CoriolisIcon.theChained => t.iconNameChained,
    };

String _iconDomain(TranslationsCharactersEn t, CoriolisIcon icon) =>
    switch (icon) {
      CoriolisIcon.theJudiciary => t.iconDomainJudiciary,
      CoriolisIcon.theTraveler => t.iconDomainTraveler,
      CoriolisIcon.theMessenger => t.iconDomainMessenger,
      CoriolisIcon.theLegionnaire => t.iconDomainLegionnaire,
      CoriolisIcon.theNurse => t.iconDomainNurse,
      CoriolisIcon.theMerchant => t.iconDomainMerchant,
      CoriolisIcon.theSymbiont => t.iconDomainSymbiont,
      CoriolisIcon.theFaceless => t.iconDomainFaceless,
      CoriolisIcon.theChained => t.iconDomainChained,
    };

String _iconLetter(CoriolisIcon icon) => switch (icon) {
      CoriolisIcon.theJudiciary => 'J',
      CoriolisIcon.theTraveler => 'T',
      CoriolisIcon.theMessenger => 'M',
      CoriolisIcon.theLegionnaire => 'L',
      CoriolisIcon.theNurse => 'N',
      CoriolisIcon.theMerchant => 'Mc',
      CoriolisIcon.theSymbiont => 'Sy',
      CoriolisIcon.theFaceless => 'F',
      CoriolisIcon.theChained => 'Ch',
    };
