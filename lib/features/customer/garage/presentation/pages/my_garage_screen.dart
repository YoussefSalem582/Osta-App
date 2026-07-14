import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/garage/data/model/garage_response/datum.dart';
import 'package:osta/features/customer/garage/presentation/cubit/garage_cubit.dart';
import 'package:osta/features/customer/garage/presentation/cubit/garage_state.dart';
import 'package:osta/features/customer/garage/presentation/widgets/empty_garage_view.dart';
import 'package:osta/features/customer/garage/presentation/widgets/vehicle_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

class MyGarageScreen extends StatefulWidget {
  const MyGarageScreen({super.key});

  @override
  State<MyGarageScreen> createState() => _MyGarageScreenState();
}

class _MyGarageScreenState extends State<MyGarageScreen> {
  List<Datum> _vehicles = [];

  void onEdit(Datum vehicle) {}

  Future<void> onDelete(Datum vehicle) async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteCar),
        content: Text(
          l10n.deleteCarConfirm(
            vehicle.make ?? '',
            vehicle.model ?? '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _vehicles.removeWhere((v) => v.id == vehicle.id));
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void onSetPrimary(Datum vehicle) {
    setState(() {
      _vehicles = _vehicles.map((v) {
        return Datum(
          id: v.id,
          make: v.make,
          model: v.model,
          year: v.year,
          plateNumber: v.plateNumber,
          vin: v.vin,
          color: v.color,
          fuelType: v.fuelType,
          transmission: v.transmission,
          currentMileage: v.currentMileage,
          isPrimary: v.id == vehicle.id,
          deletedAt: v.deletedAt,
          createdAt: v.createdAt,
          updatedAt: v.updatedAt,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = GarageCubit();
        unawaited(cubit.getVehicles());
        return cubit;
      },
      child: BlocConsumer<GarageCubit, GarageState>(
        listener: (context, state) {
          if (state is GarageSuccess) {
            setState(() {
              _vehicles = List<Datum>.from(state.response.data ?? []);
            });
          }
        },
        builder: (context, state) {
          final l10n = context.l10n;

          if (state is GarageLoading || state is GarageInitial) {
            return Scaffold(
              appBar: AppTopBar(
                centerTitle: false,
                title: l10n.myGarage,
                subtitle: l10n.garageSubtitle,
              ),
              body: const Center(child: CircularProgressIndicator()),
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
                    onPressed: () => unawaited(context.push(AppRoutes.addCar)),
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
            body: _vehicles.isEmpty
                ? EmptyGarageView(
                    onAddVehicle: () =>
                        unawaited(context.push(AppRoutes.addCar)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: _vehicles.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final vehicle = _vehicles[index];
                      return VehicleCard(
                        brand: vehicle.make ?? '',
                        model: vehicle.model ?? '',
                        plateNumber: vehicle.plateNumber?.toString() ?? '',
                        year: vehicle.year,
                        mileageKm:
                            (vehicle.currentMileage as num?)?.toInt() ?? 0,
                        isPrimary: vehicle.isPrimary ?? false,
                        onEdit: () => onEdit(vehicle),
                        onDelete: () => onDelete(vehicle),
                        onSetPrimary: () => onSetPrimary(vehicle),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
