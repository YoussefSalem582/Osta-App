import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/wallet/presentation/widgets/payment_method_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

enum PaymentMethod { cashOnDelivery, bankCard, wallet, instaPay }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => PaymentMethodScreenState();
}

class PaymentMethodScreenState extends State<PaymentScreen> {
  PaymentMethod selectedMethod = PaymentMethod.cashOnDelivery;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(title: l10n.paymentSelectMethod),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // ── Price summary ──────────────────────────────────────
                  PriceSummaryCard(
                    serviceFeeLabel: l10n.paymentServiceFee,
                    taxLabel: l10n.paymentTax,
                    totalLabel: l10n.paymentTotal,
                    serviceFee: l10n.paymentServiceFeeAmount,
                    tax: l10n.paymentTaxAmount,
                    total: l10n.paymentTotalAmount,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Cash on delivery ───────────────────────────────────
                  PaymentMethodCard(
                    isSelected: selectedMethod == PaymentMethod.cashOnDelivery,
                    onTap: () => setState(
                      () => selectedMethod = PaymentMethod.cashOnDelivery,
                    ),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.payments_outlined,
                        size: 20,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: l10n.paymentCashOnDelivery,
                    subtitle: l10n.paymentCashOnDeliverySubtitle,
                    badge: PaymentBadge(label: l10n.paymentRecommended),
                    bottomNote: l10n.paymentNoCardNeeded,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Bank card ──────────────────────────────────────────
                  PaymentMethodCard(
                    isSelected: selectedMethod == PaymentMethod.bankCard,
                    onTap: () =>
                        setState(() => selectedMethod = PaymentMethod.bankCard),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.credit_card_outlined,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    title: l10n.paymentBankCard,
                    subtitle: l10n.paymentBankCardSubtitle,
                    trailingLogos: const [
                      BankCardLogo(brand: 'VISA'),
                      BankCardLogo(brand: 'MC'),
                    ],
                    addCardLabel: l10n.paymentAddCard,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Digital wallet ─────────────────────────────────────
                  PaymentMethodCard(
                    isSelected: selectedMethod == PaymentMethod.wallet,
                    onTap: () =>
                        setState(() => selectedMethod = PaymentMethod.wallet),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    title: l10n.paymentWallet,
                    subtitle: l10n.paymentWalletSubtitle,
                    walletChips: [
                      WalletChip(
                        label: l10n.paymentFawryKash,
                        isSelected: true,
                      ),
                      WalletChip(label: l10n.paymentOrangeKash),
                      WalletChip(label: l10n.paymentWePay),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── InstaPay ───────────────────────────────────────────
                  PaymentMethodCard(
                    isSelected: selectedMethod == PaymentMethod.instaPay,
                    onTap: () =>
                        setState(() => selectedMethod = PaymentMethod.instaPay),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.qr_code_2_outlined,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    title: l10n.paymentInstaPay,
                    subtitle: l10n.paymentInstaPaySubtitle,
                  ),
                  // Bottom padding so last card isn't hidden behind the button
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),

            // ── Bottom confirm button ──────────────────────────────────────
            ConfirmPaymentBar(
              buttonLabel: l10n.paymentConfirmCash,
              totalLabel: l10n.paymentTotalAmount,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Price summary card ───────────────────────────────────────────────────────

class PriceSummaryCard extends StatelessWidget {
  const PriceSummaryCard({
    required this.serviceFeeLabel,
    required this.taxLabel,
    required this.totalLabel,
    required this.serviceFee,
    required this.tax,
    required this.total,
    super.key,
  });

  final String serviceFeeLabel;
  final String taxLabel;
  final String totalLabel;
  final String serviceFee;
  final String tax;
  final String total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        children: [
          PriceSummaryRow(
            label: serviceFeeLabel,
            value: serviceFee,
            labelStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            valueStyle: textTheme.bodyMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(
              color: colorScheme.outlineVariant,
              height: 1,
            ),
          ),
          PriceSummaryRow(
            label: taxLabel,
            value: tax,
            labelStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            valueStyle: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          PriceSummaryRow(
            label: totalLabel,
            value: total,
            labelStyle: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
            valueStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Price summary row ────────────────────────────────────────────────────────

class PriceSummaryRow extends StatelessWidget {
  const PriceSummaryRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    super.key,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}


class PaymentBadge extends StatelessWidget {
  const PaymentBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Bank card logo chip ──────────────────────────────────────────────────────

/// Small rectangular chip mimicking a card brand logo (Visa / Mastercard).
class BankCardLogo extends StatelessWidget {
  const BankCardLogo({required this.brand, super.key});

  final String brand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isVisa = brand.toUpperCase() == 'VISA';
    final bg = isVisa
        ? const Color(0xFF1A1F71)
        : const Color(0xFFEB001B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: isVisa ? bg : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        brand == 'MC' ? 'MC' : 'VISA',
        style: textTheme.labelSmall?.copyWith(
          color: isVisa ? Colors.white : const Color(0xFFEB001B),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Wallet chip ──────────────────────────────────────────────────────────────

/// Selectable chip for a digital wallet provider.
class WalletChip extends StatelessWidget {
  const WalletChip({required this.label, this.isSelected = false, super.key});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appColors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? appColors.success.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: isSelected ? appColors.success : colorScheme.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: isSelected ? appColors.success : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

// ─── Confirm payment bar ──────────────────────────────────────────────────────

/// Fixed bottom bar with a confirm button and an inline total amount.
class ConfirmPaymentBar extends StatelessWidget {
  const ConfirmPaymentBar({
    required this.buttonLabel,
    required this.totalLabel,
    super.key,
  });

  final String buttonLabel;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          // Total amount column
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.paymentTotal,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                totalLabel,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Confirm button
          Expanded(
            child: AppButton(
              label: buttonLabel,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
