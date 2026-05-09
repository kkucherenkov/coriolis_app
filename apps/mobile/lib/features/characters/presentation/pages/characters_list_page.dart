import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/app/routes.dart';
import 'package:coriolis_companion/features/characters/domain/character_summary.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/characters_list/characters_list_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/characters_list/characters_list_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/shared/di/injector.dart';

/// Characters list page — the entry point for the characters feature.
///
/// Wires [CharactersListCubit] via [BlocProvider]. Pull-to-refresh supported.
/// FAB navigates to [AppRoutes.charactersNew].
class CharactersListPage extends StatelessWidget {
  const CharactersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CharactersListCubit>(
      create: (_) => getIt<CharactersListCubit>()..init(),
      child: const _CharactersListView(),
    );
  }
}

class _CharactersListView extends StatelessWidget {
  const _CharactersListView();

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return Scaffold(
      backgroundColor: AppColors.surfaceVoid,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceNight,
        title: Text(
          t.title,
          style: AppTypography.displaySm.copyWith(color: AppColors.brandBrass),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandBrass,
        foregroundColor: AppColors.textOnBrass,
        tooltip: t.create,
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoutes.charactersNew),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<CharactersListCubit, CharactersListState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.brandBrass,
              ),
            );
          }
          if (state.isError) {
            return _ErrorView(
              message: state.errorMessage ?? '',
              onRetry: () =>
                  context.read<CharactersListCubit>().refresh(),
            );
          }
          if (state.isEmpty) {
            return _EmptyView(
              onCreateTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.charactersNew),
            );
          }
          return RefreshIndicator(
            color: AppColors.brandBrass,
            onRefresh: () =>
                context.read<CharactersListCubit>().refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s4),
              itemCount: state.characters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.s3),
              itemBuilder: (context, index) => _CharacterRow(
                character: state.characters[index],
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.characterDetail,
                  arguments: state.characters[index].id,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CharacterRow extends StatelessWidget {
  const _CharacterRow({
    required this.character,
    required this.onTap,
  });

  final CharacterSummary character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Row(
          children: [
            AppAvatar(
              name: character.name,
              size: AppAvatarSize.md,
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    character.name,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (character.concept != null &&
                      character.concept!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      character.concept!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.brandBrassDeep,
            ),
          ],
        ),
      ),
    );
  }

}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_outline,
                size: 48,
                color: AppColors.brandBrassDeep,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                t.emptyTitle,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s4),
              AppButton(
                label: t.create,
                onPressed: onCreateTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.errorLoad,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.stateCrimsonBright,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s4),
            AppButton(
              label: context.t.common.retry,
              onPressed: onRetry,
              variant: AppButtonVariant.ghost,
            ),
          ],
        ),
      ),
    );
  }
}
