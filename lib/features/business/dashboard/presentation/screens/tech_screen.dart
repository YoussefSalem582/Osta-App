import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/dashboard/presentation/bloc/mechanics_bloc.dart';
import 'package:osta/features/business/dashboard/presentation/screens/mechanic_form_screen.dart';
import 'package:osta/features/business/team/data/model/mechanic.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_confirm_dialog.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/status_states.dart';

class TechScreen extends StatelessWidget {
  const TechScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => MechanicsBloc()..add(const MechanicsLoadRequested()),
    child: const _TechView(),
  );
}

class _TechView extends StatefulWidget {
  const _TechView();

  @override
  State<_TechView> createState() => _TechViewState();
}

class _TechViewState extends State<_TechView> {
  Future<void> _openForm({Mechanic? mechanic}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MechanicFormScreen(mechanic: mechanic)),
    );
    if (saved == true && mounted) {
      context.read<MechanicsBloc>().add(const MechanicsLoadRequested());
    }
  }

  Future<void> _confirmDelete(Mechanic mechanic) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: l10n.deleteTechnicianDialogTitle,
      message: l10n.deleteTechnicianDialogMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    // Toast fires from the BlocListener in build() once the delete completes.
    context.read<MechanicsBloc>().add(MechanicsDeleteRequested(mechanic));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<MechanicsBloc, MechanicsState>(
      listener: (context, state) {
        if (state is MechanicsLoaded && state.justDeleted) {
          AppToaster.showMessage(l10n.technicianDeleted);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(AppRadii.sm),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l10n.technicians,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => unawaited(_openForm()),
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.brandGreen,
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadii.sm),
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: BlocBuilder<MechanicsBloc, MechanicsState>(
                    builder: (context, state) {
                      if (state is MechanicsLoading ||
                          state is MechanicsInitial) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                      if (state is MechanicsError) {
                        return ErrorState(
                          title: l10n.techniciansErrorTitle,
                          message: state.message,
                          onRetry: () => context.read<MechanicsBloc>().add(
                            const MechanicsLoadRequested(),
                          ),
                        );
                      }
                      final loaded = state as MechanicsLoaded;
                      if (loaded.mechanics.isEmpty) {
                        return EmptyState(
                          icon: Icons.engineering_outlined,
                          title: l10n.techniciansEmptyTitle,
                          message: l10n.techniciansEmptyMessage,
                        );
                      }
                      return Stack(
                        children: [
                          ListView(
                            children: [
                              for (final mechanic in loaded.mechanics) ...[
                                _MechanicCard(
                                  mechanic: mechanic,
                                  onEdit: () => _openForm(mechanic: mechanic),
                                  onDelete: () => _confirmDelete(mechanic),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              _AddTechnicianTile(
                                label: l10n.addTechnician,
                                onTap: () => unawaited(_openForm()),
                              ),
                            ],
                          ),
                          if (loaded.acting)
                            const Positioned.fill(
                              child: ColoredBox(
                                color: Colors.black12,
                                child: Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MechanicCard extends StatelessWidget {
  const _MechanicCard({
    required this.mechanic,
    required this.onEdit,
    required this.onDelete,
  });

  final Mechanic mechanic;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
      color: Theme.of(context).colorScheme.surface,
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mechanic.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadii.md),
                    ),
                    color: context.appColors.success,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Text(
                      mechanic.specialty,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appColors.onSuccess,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadii.sm),
              ),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            child: IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              tooltip: context.l10n.technicianEditTitle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadii.sm),
              ),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            child: IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: context.l10n.delete,
            ),
          ),
        ],
      ),
    ),
  );
}

class _AddTechnicianTile extends StatelessWidget {
  const _AddTechnicianTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.brandGreen),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.brandGreen, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.brandGreen),
            ),
          ],
        ),
      ),
    ),
  );
}
