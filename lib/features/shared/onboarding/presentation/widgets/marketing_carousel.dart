import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// One slide of a [MarketingCarousel].
typedef MarketingSlide = ({String image, String title, String body});

/// The logged-out marketing carousel, shared by both roles — only [slides]
/// differs. Finishing calls [SessionController.acknowledgeOnboarding]; the
/// redirect guard takes it from there.
class MarketingCarousel extends StatefulWidget {
  const MarketingCarousel({required this.slides, super.key});

  final List<MarketingSlide> slides;

  @override
  State<MarketingCarousel> createState() => _MarketingCarouselState();
}

class _MarketingCarouselState extends State<MarketingCarousel> {
  final PageController controller = PageController();

  int currentPage = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Used by both "Get started" and "Skip".
  void _finish() => context.read<SessionController>().acknowledgeOnboarding();

  /// Back to the role chooser — without it the role pick is a one-way door.
  /// Clearing the role is enough; the redirect guard forces `/role` whenever `activeRole` is null.
  void _changeRole() =>
      unawaited(context.read<SessionController>().switchRole());

  void _next() => unawaited(
    controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isLast = currentPage == widget.slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _changeRole,
                    icon: const BackButtonIcon(),
                    tooltip: l10n.onboardingBack,
                  ),
                  const Spacer(),
                  // Skip straight to auth-choose; hidden on the last slide
                  // where the primary button already reads "Get started".
                  Visibility(
                    visible: !isLast,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(l10n.onboardingSkip),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: widget.slides.length,
                onPageChanged: (index) => setState(() => currentPage = index),
                itemBuilder: (context, index) {
                  final slide = widget.slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(slide.image, height: 250),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          slide.body,
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
              count: widget.slides.length,
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
                onPressed: isLast ? _finish : _next,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
