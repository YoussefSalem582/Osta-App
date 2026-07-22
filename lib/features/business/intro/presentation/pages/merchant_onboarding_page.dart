import 'package:flutter/material.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/features/shared/onboarding/presentation/widgets/marketing_carousel.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Logged-out merchant marketing carousel; parallel to `OnboardingPage`
/// (differs only in slides). Post-auth center setup is a separate flow in
/// `features/business/onboarding/`.
class MerchantOnboardingPage extends StatelessWidget {
  const MerchantOnboardingPage({super.key});

  static const String path = AppRoutes.merchantOnboarding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MarketingCarousel(
      slides: [
        (
          image: AppImages.fullLogo,
          title: l10n.merchantOnboardingSlide1Title,
          body: l10n.merchantOnboardingSlide1Body,
        ),
        (
          image: AppImages.mascot,
          title: l10n.merchantOnboardingSlide2Title,
          body: l10n.merchantOnboardingSlide2Body,
        ),
        (
          image: AppImages.logo,
          title: l10n.merchantOnboardingSlide3Title,
          body: l10n.merchantOnboardingSlide3Body,
        ),
      ],
    );
  }
}
