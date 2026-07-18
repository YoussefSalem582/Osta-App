import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/data/model/promotion.dart';
import 'package:osta/features/business/services/data/repo/promotion_repo.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_segmented_toggle.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// Create or edit one promotion. Pops with `true` on a successful save.
/// Mirrors `ServiceFormScreen`.
class PromotionFormScreen extends StatefulWidget {
  const PromotionFormScreen({this.promotion, super.key});

  final Promotion? promotion;

  @override
  State<PromotionFormScreen> createState() => _PromotionFormScreenState();
}

class _PromotionFormScreenState extends State<PromotionFormScreen> {
  static const _discountTypes = ['percent', 'fixed'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _discountValue;
  late final TextEditingController _description;
  late final TextEditingController _code;
  late final TextEditingController _maxRedemptions;
  late String _discountType;
  DateTime? _startsAt;
  DateTime? _endsAt;
  late bool _isActive;
  bool _saving = false;
  bool _startsAtError = false;

  @override
  void initState() {
    super.initState();
    final p = widget.promotion;
    _title = TextEditingController(text: p?.title ?? '');
    _discountValue = TextEditingController(
      text: p == null ? '' : p.discountValue.toStringAsFixed(0),
    );
    _description = TextEditingController(text: p?.description ?? '');
    _code = TextEditingController(text: p?.code ?? '');
    _maxRedemptions = TextEditingController(
      text: p?.maxRedemptions == null ? '' : '${p!.maxRedemptions}',
    );
    _discountType = _discountTypes.contains(p?.discountType)
        ? p!.discountType
        : 'percent';
    _startsAt = p?.startsAt;
    _endsAt = p?.endsAt;
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _discountValue.dispose();
    _description.dispose();
    _code.dispose();
    _maxRedemptions.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startsAt : _endsAt) ?? now;
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: initial,
    );
    if (date == null) return;
    setState(() {
      if (isStart) {
        _startsAt = date;
        _startsAtError = false;
      } else {
        _endsAt = date;
      }
    });
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _startsAtError = _startsAt == null);
    if (!formValid || _startsAt == null) return;
    setState(() => _saving = true);
    final l10n = context.l10n;
    final discountValue = num.tryParse(_discountValue.text.trim()) ?? 0;
    final description = _description.text.trim();
    final code = _code.text.trim();
    final maxRedemptions = int.tryParse(_maxRedemptions.text.trim());
    try {
      final existing = widget.promotion;
      if (existing == null) {
        await PromotionRepo.create(
          title: _title.text.trim(),
          discountType: _discountType,
          discountValue: discountValue,
          startsAt: _startsAt!,
          description: description.isEmpty ? null : description,
          code: code.isEmpty ? null : code,
          endsAt: _endsAt,
          maxRedemptions: maxRedemptions,
          isActive: _isActive,
        );
      } else {
        await PromotionRepo.update(
          existing.id,
          title: _title.text.trim(),
          discountType: _discountType,
          discountValue: discountValue,
          startsAt: _startsAt,
          description: description.isEmpty ? null : description,
          code: code.isEmpty ? null : code,
          endsAt: _endsAt,
          maxRedemptions: maxRedemptions,
          isActive: _isActive,
        );
      }
      if (!mounted) return;
      AppToaster.showMessage(l10n.promotionSaved);
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) AppToaster.showError(e.message);
    } on Object catch (_) {
      if (mounted) AppToaster.showError(l10n.promotionSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatDate(DateTime? date, String locale) =>
      date == null ? '' : DateFormat.yMMMd(locale).format(date);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final isEdit = widget.promotion != null;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(
        centerTitle: false,
        title: isEdit ? l10n.promotionEditTitle : l10n.promotionAddTitle,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppTextField(
                controller: _title,
                label: l10n.promotionTitle,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.promotionTitleRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.promotionDiscountType,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppSegmentedToggle(
                options: [
                  l10n.promotionDiscountPercent,
                  l10n.promotionDiscountFixed,
                ],
                selectedIndex: _discountTypes.indexOf(_discountType),
                onSelect: (i) =>
                    setState(() => _discountType = _discountTypes[i]),
                expand: true,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _discountValue,
                label: l10n.promotionDiscountValue,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (num.tryParse(v?.trim() ?? '') == null)
                    ? l10n.promotionDiscountValueRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () => _pickDate(isStart: true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.promotionStartsAt,
                    errorText: _startsAtError
                        ? l10n.promotionStartsAtRequired
                        : null,
                  ),
                  child: Text(
                    _startsAt == null
                        ? l10n.promotionSelectDate
                        : _formatDate(_startsAt, locale),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () => _pickDate(isStart: false),
                child: InputDecorator(
                  decoration: InputDecoration(labelText: l10n.promotionEndsAt),
                  child: Text(
                    _endsAt == null
                        ? l10n.promotionSelectDate
                        : _formatDate(_endsAt, locale),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(controller: _code, label: l10n.promotionCode),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _maxRedemptions,
                label: l10n.promotionMaxRedemptions,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _description,
                label: l10n.promotionDescription,
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: Text(l10n.promotionActive),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.save,
                onPressed: _saving ? null : _submit,
                loading: _saving,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
