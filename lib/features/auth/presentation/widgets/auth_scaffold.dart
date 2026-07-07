import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Branded scaffold shared by every auth screen: a collapsing brand-green
/// [SliverAppBar] whose hero band holds the white logo (back button pinned over
/// it), then a bold centered title, an optional subtitle, and the screen body
/// on the normal surface. The header shrinks as the body scrolls and gains a
/// subtle shadow once content passes under it.
///
/// The logo assets are white, so they read on [AppColors.brandGreen] (the same
/// green + white pairing the splash uses) but not on the light scaffold — hence
/// the coloured band.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.logo,
    required this.title,
    required this.children,
    this.subtitle,
    this.logoHeight = heroLogoHeight,
    this.onBack,
    super.key,
  });

  /// Auth logo sizes — the two supported heights live here, not as magic
  /// numbers at the call sites. [logoHeight] is the *expanded* size; the band's
  /// height is toolbar + this, so lowering it is what shortens the header.
  static const double heroLogoHeight = 200; // full lockup on the chooser
  static const double markLogoHeight = 180; // wordmark on the inner screens

  /// Logo size once the bar is fully collapsed (stays visible next to the back
  /// button after scrolling).
  static const double collapsedLogoHeight = 36;

  /// Asset path (e.g. `AppImages.fullLogo` on the chooser, `AppImages.logo`
  /// on the inner screens).
  final String logo;
  final String title;
  final String? subtitle;
  final double logoHeight;

  /// Body content rendered (already inside the page padding) below the header.
  final List<Widget> children;

  /// Back handler. `null` falls back to the framework's implicit back arrow
  /// (correct for pushed routes like forgot/reset).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Band = status bar + toolbar (back button) + the logo, no extra slack.
    // Collapses to the standard toolbar height as the body scrolls.
    final collapsedHeight = topInset + kToolbarHeight;
    final expandedHeight = collapsedHeight + logoHeight;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: expandedHeight,
            backgroundColor: AppColors.brandGreen,
            surfaceTintColor: Colors.transparent, // keep pure brand green
            foregroundColor: Colors.white, // back arrow reads on green
            elevation: AppElevation.none,
            // Subtle shadow once content scrolls under the bar (separates the
            // header from the body per Material app-bar guidance).
            scrolledUnderElevation: AppElevation.medium,
            leading: onBack == null ? null : BackButton(onPressed: onBack),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppRadii.lg),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                // Shrink the logo from expanded size down to [collapsedLogo
                // Height] as the bar collapses, so it stays visible (centred
                // next to the back button) after scrolling.
                final t =
                    ((constraints.maxHeight - collapsedHeight) / logoHeight)
                        .clamp(0.0, 1.0);
                final currentLogoHeight =
                    collapsedLogoHeight +
                    (logoHeight - collapsedLogoHeight) * t;
                return SafeArea(
                  bottom: false,
                  child: Center(
                    child: Image.asset(logo, height: currentLogoHeight),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg + bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  ...children,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
