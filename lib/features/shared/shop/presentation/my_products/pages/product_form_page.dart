import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';
import 'package:osta/features/shared/shop/data/product_categories.dart';
import 'package:osta/features/shared/shop/domain/shop_repository.dart';
import 'package:osta/features/shared/shop/presentation/widgets/product_image.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// The known product statuses (mirrors `ProductStatus` on the backend).
const _statuses = ['active', 'inactive', 'discontinued'];

/// Max images per product (matches the backend `images|max:10` rule).
const _maxImages = 10;

/// Create or edit an own product. Pass [product] to edit, null to create;
/// pops `true` on success so `MyProductsPage` reloads.
class ProductFormPage extends StatefulWidget {
  const ProductFormPage({this.product, super.key});

  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late List<String> _imageUrls;
  late String _status;
  String? _category;
  bool _saving = false;
  bool _uploading = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(
      text: p != null ? _formatPrice(p.price) : '',
    );
    _imageUrls = [...?p?.images];
    _status = p?.status ?? 'active';
    // Only adopt a known category — legacy free-form values reset to "none".
    _category = productCategoryKeys.contains(p?.category) ? p?.category : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  /// Grouped, ASCII, ≤2 decimals for the initial edit value (e.g. `1,250.5`).
  static String _formatPrice(double price) => (NumberFormat.decimalPattern(
    'en',
  )..maximumFractionDigits = 2).format(price);

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 82,
    );
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      final url = await getIt<ShopRepository>().uploadProductImage(file.path);
      if (!mounted) return;
      setState(() => _imageUrls.add(url));
    } on ApiException {
      if (!mounted) return;
      AppToaster.showError(context.l10n.shopImageUploadError);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /// Paste-a-link alternative to the device picker. A bad URL renders the
  /// placeholder, never a crash.
  Future<void> _addUrl() async {
    final url = await showDialog<String>(
      context: context,
      builder: (_) => const _AddUrlDialog(),
    );
    if (url != null && url.isNotEmpty && mounted) {
      setState(() => _imageUrls.add(url));
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final description = _description.text.trim();
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'price': double.parse(_price.text.replaceAll(',', '').trim()),
      'status': _status,
    };
    // On create, omit empty optionals (the backend defaults them to null). On
    // edit, always send them: a PUT fills only the keys present, so an omitted
    // key silently keeps the old value instead of clearing it.
    if (_isEdit || description.isNotEmpty) {
      body['description'] = description.isEmpty ? null : description;
    }
    if (_isEdit || _category != null) {
      body['category'] = _category;
    }
    if (_isEdit || _imageUrls.isNotEmpty) {
      body['images'] = _imageUrls;
    }

    try {
      if (_isEdit) {
        await getIt<ShopRepository>().updateProduct(widget.product!.id, body);
      } else {
        await getIt<ShopRepository>().createProduct(body);
      }
      if (!mounted) return;
      context.pop(true);
      AppToaster.showMessage(context.l10n.productSaved);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToaster.showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppTopBar(title: _isEdit ? l10n.editProduct : l10n.addProduct),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              controller: _name,
              label: l10n.productFormName,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.productFormNameRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _price,
              label: l10n.productFormPrice,
              prefixIcon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [_PriceInputFormatter()],
              validator: (v) {
                final value = double.tryParse(
                  (v ?? '').replaceAll(',', '').trim(),
                );
                if (value == null || value < 0) {
                  return l10n.productFormPriceRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String?>(
              initialValue: _category,
              decoration: InputDecoration(labelText: l10n.productFormCategory),
              items: [
                DropdownMenuItem(child: Text(l10n.shopCategoryNone)),
                for (final key in productCategoryKeys)
                  DropdownMenuItem(
                    value: key,
                    child: Text(categoryLabel(l10n, key)),
                  ),
              ],
              onChanged: _saving ? null : (v) => setState(() => _category = v),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _description,
              label: l10n.productFormDescription,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              minLines: 5,
              maxLines: null,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(labelText: l10n.productFormStatus),
              items: [
                for (final s in _statuses)
                  DropdownMenuItem(
                    value: s,
                    child: Text(_statusLabel(l10n, s)),
                  ),
              ],
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _status = v ?? 'active'),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ImagesEditor(
              urls: _imageUrls,
              uploading: _uploading,
              onAdd: _pickImage,
              onAddUrl: _addUrl,
              onRemove: (i) => setState(() => _imageUrls.removeAt(i)),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.productFormSave,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
    'inactive' => l10n.productStatusInactive,
    'discontinued' => l10n.productStatusDiscontinued,
    _ => l10n.productStatusActive,
  };
}

/// Live price formatting: digits + one optional decimal (≤2 places), with the
/// integer part thousands-grouped (ASCII, so `double.parse` after stripping
/// commas always works regardless of UI locale). Rejects other input.
class _PriceInputFormatter extends TextInputFormatter {
  final NumberFormat _group = NumberFormat.decimalPattern('en');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '');
    if (text.isEmpty) return newValue.copyWith(text: '');
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;

    final parts = text.split('.');
    final intPart = parts[0];
    var out = intPart.isEmpty ? '' : _group.format(int.parse(intPart));
    if (parts.length > 1) {
      final dec = parts[1].length > 2 ? parts[1].substring(0, 2) : parts[1];
      out = '$out.$dec';
    }
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}

/// Paste-a-URL dialog. Owns its `TextEditingController` so it's disposed only
/// when the dialog route is fully gone — disposing it right after `showDialog`
/// returns crashes the exit animation, which still rebuilds the field.
class _AddUrlDialog extends StatefulWidget {
  const _AddUrlDialog();

  @override
  State<_AddUrlDialog> createState() => _AddUrlDialogState();
}

class _AddUrlDialogState extends State<_AddUrlDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.productFormAddUrl),
      content: AppTextField(
        controller: _controller,
        label: l10n.productFormImageUrl,
        keyboardType: TextInputType.url,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(l10n.add),
        ),
      ],
    );
  }
}

/// Photo grid: existing/uploaded thumbnails (each removable) plus an "add photo"
/// tile that picks from the device and shows a spinner while uploading.
class _ImagesEditor extends StatelessWidget {
  const _ImagesEditor({
    required this.urls,
    required this.uploading,
    required this.onAdd,
    required this.onAddUrl,
    required this.onRemove,
  });

  final List<String> urls;
  final bool uploading;
  final VoidCallback onAdd;
  final VoidCallback onAddUrl;
  final ValueChanged<int> onRemove;

  static const double _tile = 88;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final canAdd = urls.length < _maxImages && !uploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productFormImages,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.productFormImagesHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < urls.length; i++)
              _Thumb(url: urls[i], onRemove: () => onRemove(i)),
            if (urls.length < _maxImages) ...[
              _AddTile(
                size: _tile,
                icon: Icons.add_a_photo_outlined,
                label: l10n.productFormAddPhoto,
                busy: uploading,
                onTap: canAdd ? onAdd : null,
              ),
              _AddTile(
                size: _tile,
                icon: Icons.link,
                label: l10n.productFormAddUrl,
                onTap: uploading ? null : onAddUrl,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: _ImagesEditor._tile,
      height: _ImagesEditor._tile,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: ProductImage(url: url),
            ),
          ),
          PositionedDirectional(
            top: 2,
            end: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: CircleAvatar(
                radius: 11,
                backgroundColor: theme.colorScheme.surface,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.size,
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  final double size;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
        ),
        child: busy
            ? const Center(
                child: SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
