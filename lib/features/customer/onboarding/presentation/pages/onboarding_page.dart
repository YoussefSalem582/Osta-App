import 'package:flutter/material.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/features/shared/onboarding/presentation/widgets/marketing_carousel.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Logged-out **customer** marketing carousel. Shown after the customer role is
/// chosen until the user taps through. Merchants get `MerchantOnboardingPage`
/// at `/onboarding/business` instead; both render a [MarketingCarousel] and
/// differ only in slides.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const String path = AppRoutes.onboarding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MarketingCarousel(
      slides: [
        (
          image: AppImages.fullLogo,
          title: l10n.onboardingSlide1Title,
          body: l10n.onboardingSlide1Body,
        ),
        (
          image: AppImages.mascot,
          title: l10n.onboardingSlide2Title,
          body: l10n.onboardingSlide2Body,
        ),
        (
          image: AppImages.logo,
          title: l10n.onboardingSlide3Title,
          body: l10n.onboardingSlide3Body,
        ),
      ],
    );
  }
}
