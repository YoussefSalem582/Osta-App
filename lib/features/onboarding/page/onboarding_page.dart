import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Logged-out intro carousel. Shown every launch until the user taps through
/// (see [SessionController.acknowledgeOnboarding] + the redirect guard). Pure
/// marketing slides — language and sign-in each live on their own screens.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const String path = AppRoutes.onboarding;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController controller = PageController();

  int currentPage = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Acknowledge the intro; the guard advances to auth-choose (role + language
  /// were chosen before onboarding). Used by both "Get started" and "Skip".
  void _finish() => context.read<SessionController>().acknowledgeOnboarding();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pages = <({String image, String title, String body})>[
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
    ];
    final isLast = currentPage == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip straight to auth-choose; hidden on the last slide where the
            // primary button already reads "Get started".
            Visibility(
              visible: !isLast,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(l10n.onboardingSkip),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => currentPage = index),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(page.image, height: 250),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: controller,
              count: pages.length,
              effect: WormEffect(
                activeDotColor: theme.colorScheme.primary,
                dotHeight: 10,
                dotWidth: 10,
              ),
              onDotClicked: (index) => unawaited(
                controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppButton(
                label: isLast ? l10n.onboardingStart : l10n.onboardingNext,
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    unawaited(
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
