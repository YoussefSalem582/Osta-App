import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/wallet/presentation/widgets/bank_card_logo.dart';
import 'package:osta/features/customer/wallet/presentation/widgets/confirm_payment_bar.dart';
import 'package:osta/features/customer/wallet/presentation/widgets/payment_badge.dart';
import 'package:osta/features/customer/wallet/presentation/widgets/payment_method_card.dart';
import 'package:osta/features/customer/wallet/presentation/widgets/price_summary_card.dart';
import 'package:osta/features/customer/wallet/presentation/widgets/wallet_chip.dart';
import 'package:osta/shared/extensions/context_ext.dart';
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
                  PriceSummaryCard(
                    serviceFeeLabel: l10n.paymentServiceFee,
                    taxLabel: l10n.paymentTax,
                    totalLabel: l10n.paymentTotal,
                    serviceFee: l10n.paymentServiceFeeAmount,
                    tax: l10n.paymentTaxAmount,
                    total: l10n.paymentTotalAmount,
                  ),
                  const SizedBox(height: AppSpacing.md),

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
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),

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
