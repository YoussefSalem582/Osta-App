import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/service_toggle_card.dart';
import 'package:osta/features/business/services/data/models/services_model/service_item.dart';
import 'package:osta/features/business/services/presentation/cubit/services_cubit.dart';

class ServicesList extends StatelessWidget {
  final List<ServiceItem> services;

  const ServicesList({
    super.key,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final subtitle =
            "${service.durationMinutes ?? 0} دقيقة • ${service.priceType ?? ""}";
        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.sm,
          ),
          child: ServiceToggleCard(
            title: service.name ?? '',
            subtitle: subtitle,
            price: '${service.price ?? 0} ج',
            isSelected: service.isActive ?? false,
            onChanged: (val) {
              if (service.id != null) {
                context.read<ServicesCubit>().toggleService(
                  serviceId: service.id!,
                  isActive: val,
                );
              }
            },
          ),
        );
      },
    );
  }
}
