import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/app/routes.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/wizard_shell.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_1_biography.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_2_concept.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_3_role.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_4_attributes.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_5_skills.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_6_talents.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_7_icon.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/shared/di/injector.dart';

/// Character creation wizard — 7-step PageView backed by [CharacterWizardCubit].
///
/// Canonical step order (per
/// [`specs/design/CHARACTER_WIZARD.md`](../../../../../../specs/design/CHARACTER_WIZARD.md)):
///   1. Biography (name · origin · upbringing · crew · age)
///   2. Concept (амплуа)
///   3. Role
///   4. Attributes
///   5. Skills
///   6. Talents
///   7. Icon
///
/// Step 8 Gear is deferred until `T-WIZARD-GEAR-UI`.
///
/// Routing:
/// - `/app/characters/new`        → start fresh draft (POST on first advance).
/// - `/app/characters/new?id=xyz` → resume existing draft (GET on mount).
///
/// The query param `id` is passed as a [String?] via [RouteSettings.arguments].
/// When the wizard creates a new draft, it replaces the route to include `?id=`
/// so that a process restart resumes correctly.
class CharacterCreatePage extends StatefulWidget {
  /// Pass the existing draft id to resume, or leave null to start fresh.
  const CharacterCreatePage({super.key, this.draftId});

  final String? draftId;

  @override
  State<CharacterCreatePage> createState() => _CharacterCreatePageState();
}

class _CharacterCreatePageState extends State<CharacterCreatePage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CharacterWizardCubit>(
      create: (innerContext) {
        final cubit = getIt<CharacterWizardCubit>();
        // Capture the navigator synchronously before the async gap.
        final navigator = Navigator.of(innerContext);
        // Start asynchronously; if a new id is returned, replace the route
        // so back button goes to list, not here, and a process restart
        // (deep link / notification) resumes correctly.
        cubit.start(id: widget.draftId).then((newId) {
          if (newId == null || !mounted) return;
          navigator.pushReplacementNamed(
            AppRoutes.charactersNew,
            arguments: newId,
          );
        });
        return cubit;
      },
      child: _WizardView(pageController: _pageController),
    );
  }
}

class _WizardView extends StatelessWidget {
  const _WizardView({required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      buildWhen: (prev, next) => prev.isLoading != next.isLoading,
      builder: (context, state) {
        if (state.isLoading && state.character == null) {
          return const Scaffold(
            backgroundColor: AppColors.surfaceVoid,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.brandBrass),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.surfaceVoid,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceNight,
            titleSpacing: AppSpacing.s4,
            title: BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
              buildWhen: (p, n) => p.step != n.step,
              builder: (_, s) => Text(
                t.wizardTitle(step: s.step),
                style: AppTypography.displaySm.copyWith(
                  color: AppColors.brandBrass,
                ),
              ),
            ),
            leading: const SizedBox.shrink(),
            leadingWidth: 0,
          ),
          body: SafeArea(
            child: WizardShell(
              pageController: pageController,
              steps: const [
                Step1Biography(),
                Step2Concept(),
                Step3Role(),
                Step4Attributes(),
                Step5Skills(),
                Step6Talents(),
                Step7Icon(),
              ],
              onSaveAndExit: () {
                Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.characters);
              },
              onForge: (characterId) {
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.characterDetail,
                  arguments: characterId,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
