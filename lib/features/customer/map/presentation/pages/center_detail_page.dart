import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/presentation/pages/booking_create_screen.dart';
import 'package:osta/features/customer/map/presentation/bloc/center_detail_bloc.dart';
import 'package:osta/features/customer/map/presentation/widgets/center_header.dart';
import 'package:osta/features/customer/map/presentation/widgets/center_review_row.dart';
import 'package:osta/features/customer/map/presentation/widgets/center_service_row.dart';
import 'package:osta/features/customer/map/presentation/widgets/write_review_sheet.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_section_title.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

/// A single service center's profile — header, services, reviews — with a Book
/// CTA that opens the booking-create flow. Reached from the map marker sheet's
/// "Details" / "Book" buttons. `extra` is the center id (`String`).
class CenterDetailPage extends StatelessWidget {
  const CenterDetailPage({required this.centerId, super.key});

  final String centerId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CenterDetailBloc(centerId)..add(const CenterDetailStarted()),
    child: const _CenterDetailView(),
  );
}

class _CenterDetailView extends StatelessWidget {
  const _CenterDetailView();

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<CenterDetailBloc, CenterDetailState>(
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
          if (state is CenterDetailLoading || state is CenterDetailInitial) {
            return const Center(child: CircularProgressIndicator());
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
          final loaded = state as CenterDetailLoaded;
          return _loadedBody(context, loaded);
        },
      ),
    );
  }

  Widget _loadedBody(BuildContext context, CenterDetailLoaded state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final detail = state.detail;
    final services = state.services;

    return Scaffold(
      appBar: AppTopBar(centerTitle: false, title: detail.name),
      bottomNavigationBar: services.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(AppSpacing.md),
              child: AppButton(
                label: l10n.centerDetailBook,
                icon: Icons.calendar_month_outlined,
                onPressed: () => context.push(
                  AppRoutes.bookingCreate,
                  extra: BookingCreateArgs(
                    centerId: detail.id,
                    centerName: detail.name,
                    services: services,
                  ),
                ),
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          CenterHeader(detail: detail),
          if (detail.description != null && detail.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(detail.description!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppSectionTitle(title: l10n.centerDetailServices),
          const SizedBox(height: AppSpacing.sm),
          if (services.isEmpty)
            Text(
              l10n.centerDetailNoServices,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...services.map((s) => CenterServiceRow(service: s)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppSectionTitle(title: l10n.centerDetailReviews),
              ),
              TextButton.icon(
                onPressed: () => _writeReview(context),
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: Text(l10n.writeReview),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.reviews.isEmpty)
            Text(
              l10n.centerDetailNoReviews,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...state.reviews.map((r) => CenterReviewRow(review: r)),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
