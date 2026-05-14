import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_1_biography.dart'
    show WizardStepHeader;

/// Canonical Concept (амплуа) enum values (Dart-side `EnumClass.name` form).
///
/// Order matches the OpenAPI `Concept` enum / `CONCEPT_KEYS` in the backend
/// `apps/backend/src/modules/rules-engine/rules-engine.ts`.
const List<String> kCanonicalConcepts = <String>[
  'artist',
  'networker',
  'fugitive',
  'negotiator',
  'operative',
  'pilot',
  'pioneer',
  'preacher',
  'scientist',
  'sailor',
  'soldier',
];

/// Wizard step 2 — Concept (амплуа).
///
/// Per [CHARACTER_WIZARD §3.2](../../../../../../specs/design/CHARACTER_WIZARD.md):
///
/// > Inputs: concept (required, enum of 11 amplua).
///
/// Surface: 3×4 grid of medallion cards. Picking a concept also clears any
/// previously chosen role so the Step-3 picker doesn't surface a
/// `ROLE_CONCEPT_MISMATCH` server error.
class Step2Concept extends StatelessWidget {
  const Step2Concept({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      buildWhen: (p, n) => p.draft.concept != n.draft.concept,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WizardStepHeader(
                title: t.wizard.step.concept.title,
                blurb: t.wizard.step.concept.blurb,
              ),
              const SizedBox(height: AppSpacing.s6),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.s2,
                  crossAxisSpacing: AppSpacing.s2,
                  childAspectRatio: 1.4,
                ),
                itemCount: kCanonicalConcepts.length,
                itemBuilder: (ctx, i) {
                  final id = kCanonicalConcepts[i];
                  final isSelected = state.draft.concept == id;
                  return _ConceptCard(
                    conceptId: id,
                    isSelected: isSelected,
                    onTap: () {
                      final cubit = context.read<CharacterWizardCubit>();
                      cubit.updateConcept(id);
                      // Clear stale role so Step 3 doesn't ship a mismatched
                      // role/concept pair to the server.
                      if (cubit.state.draft.role != null) {
                        cubit.updateRole('');
                      }
                    },
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

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({
    required this.conceptId,
    required this.isSelected,
    required this.onTap,
  });

  final String conceptId;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final label = _conceptLabel(t, conceptId);
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          variant: isSelected
              ? AppCardVariant.featured
              : AppCardVariant.defaultVariant,
          padding: const EdgeInsets.all(AppSpacing.s2),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: isSelected
                    ? AppColors.brandBrassLight
                    : AppColors.textSecondary,
                fontWeight: isSelected
                    ? AppFontWeight.semibold
                    : AppFontWeight.regular,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _conceptLabel(TranslationsCharactersEn t, String id) => switch (id) {
      'artist' => t.conceptArtist,
      'networker' => t.conceptNetworker,
      'fugitive' => t.conceptFugitive,
      'negotiator' => t.conceptNegotiator,
      'operative' => t.conceptOperative,
      'pilot' => t.conceptPilot,
      'pioneer' => t.conceptPioneer,
      'preacher' => t.conceptPreacher,
      'scientist' => t.conceptScientist,
      'sailor' => t.conceptSailor,
      'soldier' => t.conceptSoldier,
      _ => id,
    };
