import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/garage/data/models/garage_response/datum.dart';
import 'package:osta/features/customer/garage/presentation/garage/cubit/garage_cubit.dart';
import 'package:osta/features/customer/garage/presentation/garage/cubit/garage_state.dart';
import 'package:osta/features/customer/garage/presentation/garage/widgets/empty_garage_view.dart';
import 'package:osta/features/customer/garage/presentation/garage/widgets/vehicle_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_confirm_dialog.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

class MyGaragePage extends StatefulWidget {
  const MyGaragePage({super.key});

  @override
  State<MyGaragePage> createState() => _MyGaragePageState();
}

class _MyGaragePageState extends State<MyGaragePage> {
  List<Datum> vehicles = [];

  Future<void> onDelete(BuildContext ctx, Datum vehicle) async {
    final currentState = ctx.read<GarageCubit>().state;
    if (currentState is GarageSetPrimaryLoading ||
        currentState is GarageDeleteLoading) {
      return;
    }
    final l10n = ctx.l10n;
    final confirmed = await AppConfirmDialog.show(
      context: ctx,
      title: l10n.deleteVehicleDialogTitle,
      message: l10n.deleteVehicleDialogMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed != true) return;
    if (!ctx.mounted) return;
    await ctx.read<GarageCubit>().deleteVehicle(vehicle.id!);
  }

  Future<void> onSetPrimary(BuildContext ctx, Datum vehicle) async {
    final currentState = ctx.read<GarageCubit>().state;
    if (currentState is GarageSetPrimaryLoading ||
        currentState is GarageDeleteLoading) {
      return;
    }
    await ctx.read<GarageCubit>().setPrimary(vehicle.id!);
  }

  Future<void> onEdit(BuildContext ctx, Datum vehicle) async {
    final saved = await ctx.push<bool>(AppRoutes.addCar, extra: vehicle);
    if (saved == true && ctx.mounted) {
      unawaited(ctx.read<GarageCubit>().getVehicles());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<GarageCubit>();
        unawaited(cubit.getVehicles());
        return cubit;
      },
      child: BlocConsumer<GarageCubit, GarageState>(
        listener: (context, state) {
          if (state is GarageSuccess) {
            setState(() {
              vehicles = List<Datum>.from(state.response.data ?? []);
            });
          }

          if (state is GarageSetPrimarySuccess) {
            unawaited(context.read<GarageCubit>().getVehicles());
          }

          if (state is GarageSetPrimaryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }

          if (state is GarageDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.deleteVehicleSuccess),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
            unawaited(context.read<GarageCubit>().getVehicles());
          }

          if (state is GarageDeleteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final l10n = context.l10n;
          final isActionBusy =
              state is GarageSetPrimaryLoading || state is GarageDeleteLoading;

          if (state is GarageLoading || state is GarageInitial) {
            return Scaffold(
              appBar: AppTopBar(
                centerTitle: false,
                title: l10n.myGarage,
                subtitle: l10n.garageSubtitle,
              ),
              body: const Center(child: CircularProgressIndicator.adaptive()),
            );
          }

          if (state is GarageError) {
            return Scaffold(
              appBar: AppTopBar(
                centerTitle: false,
                title: l10n.myGarage,
                subtitle: l10n.garageSubtitle,
              ),
              body: Center(
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppTopBar(
              centerTitle: false,
              title: l10n.myGarage,
              subtitle: l10n.garageSubtitle,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: IconButton(
                    onPressed: () => unawaited(
                      context.push(
                        AppRoutes.addCar,
                        extra: context.read<GarageCubit>(),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      textStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                if (vehicles.isEmpty)
                  EmptyGarageView(
                    onAddVehicle: () => unawaited(
                      context.push(
                        AppRoutes.addCar,
                        extra: context.read<GarageCubit>(),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: vehicles.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return VehicleCard(
                        brand: vehicle.make ?? '',
                        model: vehicle.model ?? '',
                        plateNumber: vehicle.plateNumber?.toString() ?? '',
                        year: vehicle.year,
                        mileageKm:
                            (vehicle.currentMileage as num?)?.toInt() ?? 0,
                        isPrimary: vehicle.isPrimary ?? false,
                        isActionLoading: isActionBusy,
                        onDelete: () => onDelete(context, vehicle),
                        onSetPrimary: () => onSetPrimary(context, vehicle),
                        onEdit: () => unawaited(onEdit(context, vehicle)),
                        onTap: () => unawaited(
                          context.push(
                            AppRoutes.maintenance,
                            extra: vehicle.id,
                          ),
                        ),
                      );
                    },
                  ),
                if (isActionBusy)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black12,
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
