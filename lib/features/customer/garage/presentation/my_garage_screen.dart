import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/garage/data/model.dart';
import 'package:osta/features/customer/garage/presentation/widgets/vehicle_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

class MyGarageScreen extends StatefulWidget {
  const MyGarageScreen({super.key});

  @override
  State<MyGarageScreen> createState() => _MyGarageScreenState();
}

class _MyGarageScreenState extends State<MyGarageScreen> {
  void onEdit(DummyVehicle vehicle) {}

  Future<void> onDelete(DummyVehicle vehicle) async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteCar),
        content: Text(
          l10n.deleteCarConfirm(vehicle.brand, vehicle.model),
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
              setState(() => vehicles.removeWhere((v) => v.id == vehicle.id));
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void onSetPrimary(DummyVehicle vehicle) {
    setState(() {
      final updated = vehicles.map((v) {
        return DummyVehicle(
          id: v.id,
          brand: v.brand,
          model: v.model,
          plateNumber: v.plateNumber,
          year: v.year,
          mileageKm: v.mileageKm,
          isPrimary: v.id == vehicle.id,
          icon: v.icon,
        );
      }).toList();
      vehicles
        ..clear()
        ..addAll(updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
            child: AddVehicleButton(
              onPressed: () => unawaited(context.push(AppRoutes.addCar)),
            ),
          ),
        ],
      ),
      body: vehicles.isEmpty

          ? EmptyGarageView(
              onAddVehicle: () => unawaited(context.push(AppRoutes.addCar)),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              itemCount: vehicles.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return VehicleCard(
                  brand: vehicle.brand,
                  model: vehicle.model,
                  plateNumber: vehicle.plateNumber,
                  year: vehicle.year,
                  mileageKm: vehicle.mileageKm,
                  isPrimary: vehicle.isPrimary,
                  icon: vehicle.icon,
                  onEdit: () => onEdit(vehicle),
                  onDelete: () => onDelete(vehicle),
                  onSetPrimary: () => onSetPrimary(vehicle),
                );
              },
            ),
    );
  }
}

class AddVehicleButton extends StatelessWidget {
  const AddVehicleButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brandGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
      icon: const Icon(Icons.add_rounded, size: 18),
    );
  }
}

class EmptyGarageView extends StatelessWidget {
  const EmptyGarageView({required this.onAddVehicle, super.key});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.garage_outlined,
              size: 80,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.emptyGarageTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.emptyGarageSubtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAddVehicle,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addCar),
            ),
          ],
        ),
      ),
    );
  }
}
