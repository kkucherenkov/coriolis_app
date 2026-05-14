import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/app/routes.dart';
import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ships_list/ships_list_cubit.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ships_list/ships_list_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/shared/di/injector.dart';

/// Ships list page — entry point for the ships feature.
///
/// Mirrors [`CharactersListPage`]: pull-to-refresh, error/empty/loaded
/// states. Tap a row to open the ship sheet. Ship creation is not yet
/// wired on mobile (web only) — empty state stays informational for now.
class ShipsListPage extends StatelessWidget {
  const ShipsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShipsListCubit>(
      create: (_) => getIt<ShipsListCubit>()..init(),
      child: const _ShipsListView(),
    );
  }
}

class _ShipsListView extends StatelessWidget {
  const _ShipsListView();

  Future<void> _openCreate(BuildContext context) async {
    final cubit = context.read<ShipsListCubit>();
    await Navigator.of(context).pushNamed(AppRoutes.shipsNew);
    // We come back here through Navigator.pop after either user-cancel or
    // the ship sheet's own back gesture — refresh either way so a freshly
    // created ship lands in the list immediately.
    await cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return Scaffold(
      backgroundColor: AppColors.surfaceVoid,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceNight,
        title: Text(
          t.title,
          style: AppTypography.displaySm.copyWith(color: AppColors.brandBrass),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('ships-list-fab-new'),
        backgroundColor: AppColors.brandBrass,
        foregroundColor: AppColors.surfaceVoid,
        onPressed: () => _openCreate(context),
        icon: const Icon(Icons.add),
        label: Text(t.fabNew),
      ),
      body: BlocBuilder<ShipsListCubit, ShipsListState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.brandBrass),
            );
          }
          if (state.isError) {
            return _ErrorView(
              message: state.errorMessage ?? '',
              onRetry: () => context.read<ShipsListCubit>().refresh(),
            );
          }
          if (state.isEmpty) {
            return _EmptyView(onCreate: () => _openCreate(context));
          }
          return RefreshIndicator(
            color: AppColors.brandBrass,
            onRefresh: () => context.read<ShipsListCubit>().refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s4),
              itemCount: state.ships.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.s3),
              itemBuilder: (context, index) {
                final ship = state.ships[index];
                return _ShipRow(
                  ship: ship,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.shipDetail,
                    arguments: ship.id,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ShipRow extends StatelessWidget {
  const _ShipRow({required this.ship, required this.onTap});

  final ShipSummary ship;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return Semantics(
      button: true,
      label: ship.name,
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          child: Row(
            children: [
              const Icon(
                Icons.rocket_launch_outlined,
                color: AppColors.brandBrass,
                size: AppSpacing.s6,
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ship.name,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      '${t.rowClassLabel}: ${_humaniseClass(ship.shipClass)}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
      ),
    );
  }
}

/// Humanises a wire-form class id (`light-freighter`) into a display label
/// (`Light Freighter`). Matches the helper in the web ship sheet.
String _humaniseClass(String cls) => cls
    .split('-')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.rocket_launch_outlined,
                size: 48,
                color: AppColors.brandBrassDeep,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                t.emptyTitle,
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                t.emptyBody,
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s4),
              AppButton(
                key: const Key('ships-list-empty-cta'),
                label: t.emptyCta,
                onPressed: onCreate,
                variant: AppButtonVariant.primary,
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
    final t = context.t.ships;
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
              label: t.retry,
              onPressed: onRetry,
              variant: AppButtonVariant.ghost,
            ),
          ],
        ),
      ),
    );
  }
}
