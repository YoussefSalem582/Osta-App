import 'package:flutter/material.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/shop/domain/shop_repository.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';

/// Opens the "contact seller" bottom sheet for [productId]. Posts the enquiry
/// (no cart/checkout — just a lead), toasts on success, returns `true` if sent.
Future<bool> showEnquireSheet(
  BuildContext context, {
  required Object productId,
}) async {
  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _EnquireSheet(productId: productId),
  );
  return sent ?? false;
}

class _EnquireSheet extends StatefulWidget {
  const _EnquireSheet({required this.productId});

  final Object productId;

  @override
  State<_EnquireSheet> createState() => _EnquireSheetState();
}

class _EnquireSheetState extends State<_EnquireSheet> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _controller.text.trim();
    if (message.length < 2) {
      setState(() => _error = context.l10n.shopEnquireEmptyError);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await getIt<ShopRepository>().enquire(widget.productId, message);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      AppToaster.showMessage(context.l10n.shopEnquireSuccess);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: AppSpacing.lg + viewInsets,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.shopEnquireTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.shopEnquireSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _controller,
            label: l10n.shopEnquireMessageLabel,
            hint: l10n.shopEnquireMessageHint,
            errorText: _error,
            keyboardType: TextInputType.multiline,
            enabled: !_sending,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.shopEnquireSend,
            icon: Icons.send_outlined,
            loading: _sending,
            onPressed: _sending ? null : _send,
          ),
        ],
      ),
    );
  }
}
