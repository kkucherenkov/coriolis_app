import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_1_biography.dart'
    show WizardStepHeader;

/// Concept (amplua) → ordered list of canonical role ids (Dart-side
/// `EnumClass.name` form). Mirrors the OpenAPI `Role` enum grouped by
/// concept and the backend `update-character` `ROLE_CONCEPT_MISMATCH`
/// validation table.
const Map<String, List<String>> kRolesByConcept = <String, List<String>>{
  'artist': ['companion', 'musician', 'poet'],
  'networker': ['analyst', 'correspondent', 'networkDjinn'],
  'fugitive': ['criminal', 'mystic', 'revolutionary'],
  'negotiator': ['agitator', 'diplomat', 'dealer'],
  'operative': ['assassin', 'guard', 'spy'],
  'pilot': ['ace', 'driver', 'trucker'],
  'pioneer': ['colonist', 'prospector', 'scout'],
  'preacher': ['ascetic', 'missionary', 'prophet'],
  'scientist': ['archaeologist', 'medicurg', 'technologist'],
  'sailor': ['shipEngineer', 'labourer', 'loader'],
  'soldier': ['legionnaire', 'mercenary', 'officer'],
};

/// Wizard step 3 — Role (роль within the chosen amplua).
///
/// Per [CHARACTER_WIZARD §3.3](../../../../../../specs/design/CHARACTER_WIZARD.md):
///
/// > Inputs: role (required, string; validated against concept by the
/// > server — ROLE_CONCEPT_MISMATCH).
///
/// Empty state: if no concept is picked yet, render a placeholder and let
/// the wizard shell disable the Next button (Step 3 surfaces a static
/// `wizardRolePlaceholderNoConcept` blurb so the user knows what to do).
class Step3Role extends StatelessWidget {
  const Step3Role({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      buildWhen: (p, n) =>
          p.draft.role != n.draft.role ||
          p.draft.concept != n.draft.concept,
      builder: (context, state) {
        final concept = state.draft.concept;
        final roles = concept == null ? const <String>[] : (kRolesByConcept[concept] ?? const <String>[]);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WizardStepHeader(
                title: t.wizardStep3Title,
                blurb: t.wizardStep3Blurb,
              ),
              const SizedBox(height: AppSpacing.s6),
              if (concept == null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.s4,
                  ),
                  child: Text(
                    t.wizardRolePlaceholderNoConcept,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                Column(
                  children: roles.map((id) {
                    final isSelected = state.draft.role == id;
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.s2),
                      child: _RoleCard(
                        roleId: id,
                        isSelected: isSelected,
                        onTap: () => context
                            .read<CharacterWizardCubit>()
                            .updateRole(id),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.roleId,
    required this.isSelected,
    required this.onTap,
  });

  final String roleId;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final label = _roleLabel(t, roleId);
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
          padding: const EdgeInsets.all(AppSpacing.s3),
          child: Center(
            child: Text(
              label,
              style: AppTypography.bodyMd.copyWith(
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

String _roleLabel(TranslationsCharactersEn t, String id) => switch (id) {
      'companion' => t.roleCompanion,
      'musician' => t.roleMusician,
      'poet' => t.rolePoet,
      'analyst' => t.roleAnalyst,
      'correspondent' => t.roleCorrespondent,
      'networkDjinn' => t.roleNetworkDjinn,
      'criminal' => t.roleCriminal,
      'mystic' => t.roleMystic,
      'revolutionary' => t.roleRevolutionary,
      'agitator' => t.roleAgitator,
      'diplomat' => t.roleDiplomat,
      'dealer' => t.roleDealer,
      'assassin' => t.roleAssassin,
      'guard' => t.roleGuard,
      'spy' => t.roleSpy,
      'ace' => t.roleAce,
      'driver' => t.roleDriver,
      'trucker' => t.roleTrucker,
      'colonist' => t.roleColonist,
      'prospector' => t.roleProspector,
      'scout' => t.roleScout,
      'ascetic' => t.roleAscetic,
      'missionary' => t.roleMissionary,
      'prophet' => t.roleProphet,
      'archaeologist' => t.roleArchaeologist,
      'medicurg' => t.roleMedicurg,
      'technologist' => t.roleTechnologist,
      'shipEngineer' => t.roleShipEngineer,
      'labourer' => t.roleLabourer,
      'loader' => t.roleLoader,
      'legionnaire' => t.roleLegionnaire,
      'mercenary' => t.roleMercenary,
      'officer' => t.roleOfficer,
      _ => id,
    };
