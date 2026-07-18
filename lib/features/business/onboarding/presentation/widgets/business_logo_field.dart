import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/logo_upload_box.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';

/// Business logo picker — shows the stored remote logo (with a change button)
/// if present, else [LogoUploadBox]; a freshly-picked local file always wins.
class BusinessLogoField extends StatelessWidget {
  const BusinessLogoField({
    required this.existingLogoUrl,
    required this.newLogoPath,
    required this.onPickLogo,
    super.key,
  });

  final String? existingLogoUrl;
  final String? newLogoPath;
  final VoidCallback onPickLogo;

  @override
  Widget build(BuildContext context) {
    if (newLogoPath == null &&
        existingLogoUrl != null &&
        existingLogoUrl!.isNotEmpty) {
      return Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: CachedNetworkImage(
              imageUrl: existingLogoUrl!,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) =>
                  const Icon(Icons.storefront_outlined, size: 40),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppButton(
              label: context.l10n.businessProfileChangeLogo,
              variant: AppButtonVariant.secondary,
              icon: Icons.image_outlined,
              onPressed: onPickLogo,
            ),
          ),
        ],
      );
    }
    return LogoUploadBox(onTap: onPickLogo, imagePath: newLogoPath);
  }
}
