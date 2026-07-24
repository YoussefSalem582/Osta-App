import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/presentation/pages/booking_create_screen.dart';
import 'package:osta/features/customer/map/presentation/center_detail/bloc/center_detail_bloc.dart';
import 'package:osta/features/customer/map/presentation/center_detail/widgets/center_hero.dart';
import 'package:osta/features/customer/map/presentation/center_detail/widgets/center_info_card.dart';
import 'package:osta/features/customer/map/presentation/center_detail/widgets/center_overview_card.dart';
import 'package:osta/features/customer/map/presentation/center_detail/widgets/center_review_row.dart';
import 'package:osta/features/customer/map/presentation/center_detail/widgets/center_section_card.dart';
import 'package:osta/features/customer/map/presentation/center_detail/widgets/center_service_row.dart';
import 'package:osta/features/customer/map/presentation/center_detail/widgets/write_review_sheet.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

/// A center's profile page (hero, overview, services, reviews) with a Book
/// CTA; `extra` is the center id. Backed by [CenterDetailBloc].
class CenterDetailPage extends StatelessWidget {
  const CenterDetailPage({required this.centerId, super.key});

  final String centerId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<CenterDetailBloc>(param1: centerId)
          ..add(const CenterDetailStarted()),
    child: const _CenterDetailView(),
  );
}

class _CenterDetailView extends StatelessWidget {
  const _CenterDetailView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<CenterDetailBloc, CenterDetailState>(
      listenWhen: (previous, current) =>
          current is CenterDetailLoaded && current.review != null,
      listener: (context, state) {
        final review = (state as CenterDetailLoaded).review;
        if (review == ReviewSubmission.success) {
          AppToaster.showMessage(context.l10n.reviewSubmitted);
        } else {
          AppToaster.showError(context.l10n.reviewSubmitError);
        }
        context.read<CenterDetailBloc>().add(
          const CenterDetailReviewNoticeCleared(),
        );
      },
      builder: (context, state) {
        if (state is CenterDetailLoaded) {
          return _CenterDetailBody(state: state);
        }
        if (state is CenterDetailError) {
          return Scaffold(
            appBar: AppTopBar(title: l10n.centerDetailTitle),
            body: ErrorState(
              title: l10n.centerDetailErrorTitle,
              message: state.message,
              onRetry: () => context.read<CenterDetailBloc>().add(
                const CenterDetailStarted(),
              ),
            ),
          );
        }
        // Initial / loading — keep the app bar so back always works.
        return Scaffold(
          appBar: AppTopBar(title: l10n.centerDetailTitle),
          body: const Center(child: CircularProgressIndicator.adaptive()),
        );
      },
    );
  }
}

/// The loaded profile: hero + stacked section cards, with the Book CTA docked
/// at the bottom once the center has bookable services.
class _CenterDetailBody extends StatelessWidget {
  const _CenterDetailBody({required this.state});

  final CenterDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = state.detail;
    final services = state.services;
    final description = detail.description;
    final hasDescription = description != null && description.isNotEmpty;

    return Scaffold(
      bottomNavigationBar: services.isEmpty ? null : _bookBar(context),
      body: CustomScrollView(
        slivers: [
          CenterHero(detail: detail),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList.list(
              children: [
                CenterOverviewCard(detail: detail),
                if (hasDescription) ...[
                  const SizedBox(height: AppSpacing.md),
                  CenterSectionCard(
                    title: l10n.centerDetailAbout,
                    children: [Text(description)],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                CenterInfoCard(detail: detail),
                const SizedBox(height: AppSpacing.md),
                CenterSectionCard(
                  title: l10n.centerDetailServices,
                  count: services.length,
                  emptyLabel: l10n.centerDetailNoServices,
                  children: [
                    for (final s in services) CenterServiceRow(service: s),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                CenterSectionCard(
                  title: l10n.centerDetailReviews,
                  count: state.reviews.length,
                  emptyLabel: l10n.centerDetailNoReviews,
                  action: TextButton.icon(
                    onPressed: () => _writeReview(context),
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: Text(l10n.writeReview),
                  ),
                  children: [
                    for (final r in state.reviews) CenterReviewRow(review: r),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _writeReview(BuildContext context) async {
    final result = await showWriteReviewSheet(context);
    if (result == null || !context.mounted) return;
    context.read<CenterDetailBloc>().add(
      CenterDetailReviewSubmitted(
        rating: result.rating,
        comment: result.comment,
      ),
    );
  }

  Widget _bookBar(BuildContext context) {
    final detail = state.detail;
    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.md),
      child: AppButton(
        label: context.l10n.centerDetailBook,
        icon: Icons.calendar_month_outlined,
        onPressed: () => context.push(
          AppRoutes.bookingCreate,
          extra: BookingCreateArgs(
            centerId: detail.id,
            centerName: detail.name,
            services: state.services,
          ),
        ),
      ),
    );
  }
}
