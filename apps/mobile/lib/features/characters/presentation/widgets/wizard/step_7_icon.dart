import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_1_biography.dart'
    show WizardStepHeader;

/// Canonical Icon ids (Dart-side EnumClass names).
///
/// Order matches the OpenAPI `IconId` enum:
///   ladyOfTears, traveler, messenger, merchant, dancer,
///   gambler, judge, facelessOne, deckhand
const List<String> kCanonicalIconIds = <String>[
  'ladyOfTears',
  'traveler',
  'messenger',
  'merchant',
  'dancer',
  'gambler',
  'judge',
  'facelessOne',
  'deckhand',
];

/// Wizard step 3 — Nine Icons.
///
/// Renders a 3×3 grid of labelled cards. The selected card pulses a teal
/// aura via an [AnimationController] scale + opacity tween.
///
/// [MediaQuery.disableAnimations] → no animation, static teal border only.
class Step7Icon extends StatelessWidget {
  const Step7Icon({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      buildWhen: (p, n) => p.draft.iconId != n.draft.iconId,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WizardStepHeader(
                title: t.wizard.step.icon.title,
                blurb: t.wizard.step.icon.blurb,
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
                itemCount: kCanonicalIconIds.length,
                itemBuilder: (ctx, i) {
                  final iconId = kCanonicalIconIds[i];
                  final isSelected = state.draft.iconId == iconId;
                  return _IconCard(
                    iconId: iconId,
                    isSelected: isSelected,
                    onTap: () => context
                        .read<CharacterWizardCubit>()
                        .selectIconId(iconId),
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
    required this.iconId,
    required this.isSelected,
    required this.onTap,
  });

  final String iconId;
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    final name = _iconName(t, widget.iconId);
    final domain = _iconDomain(t, widget.iconId);
    final letter = _iconLetter(widget.iconId);
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
                child: card,
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

String _iconName(TranslationsCharactersEn t, String iconId) => switch (iconId) {
      'ladyOfTears' => t.iconNameLadyOfTears,
      'traveler' => t.iconNameTraveler,
      'messenger' => t.iconNameMessenger,
      'merchant' => t.iconNameMerchant,
      'dancer' => t.iconNameDancer,
      'gambler' => t.iconNameGambler,
      'judge' => t.iconNameJudge,
      'facelessOne' => t.iconNameFacelessOne,
      'deckhand' => t.iconNameDeckhand,
      _ => iconId,
    };

String _iconDomain(TranslationsCharactersEn t, String iconId) =>
    switch (iconId) {
      'ladyOfTears' => t.iconDomainLadyOfTears,
      'traveler' => t.iconDomainTraveler,
      'messenger' => t.iconDomainMessenger,
      'merchant' => t.iconDomainMerchant,
      'dancer' => t.iconDomainDancer,
      'gambler' => t.iconDomainGambler,
      'judge' => t.iconDomainJudge,
      'facelessOne' => t.iconDomainFacelessOne,
      'deckhand' => t.iconDomainDeckhand,
      _ => '',
    };

/// Single-letter glyph fallback (replaced by the icon SVGs once assets land
/// — keys match `packages/ui/src/assets/icons/<icon-id>.svg`).
String _iconLetter(String iconId) => switch (iconId) {
      'ladyOfTears' => 'L',
      'traveler' => 'T',
      'messenger' => 'M',
      'merchant' => 'Mc',
      'dancer' => 'D',
      'gambler' => 'G',
      'judge' => 'J',
      'facelessOne' => 'F',
      'deckhand' => 'Dh',
      _ => '?',
    };
