import 'package:flutter/material.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/team/data/model/mechanic.dart';
import 'package:osta/features/business/team/data/repo/mechanic_repo.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// Create or edit one roster mechanic. Pops with `true` on a successful save.
class MechanicFormScreen extends StatefulWidget {
  const MechanicFormScreen({this.mechanic, super.key});

  final Mechanic? mechanic;

  @override
  State<MechanicFormScreen> createState() => _MechanicFormScreenState();
}

class _MechanicFormScreenState extends State<MechanicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _specialty;
  late final TextEditingController _phone;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.mechanic;
    _name = TextEditingController(text: m?.name ?? '');
    _specialty = TextEditingController(text: m?.specialty ?? '');
    _phone = TextEditingController(text: m?.phone ?? '');
    _isActive = m?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _specialty.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final l10n = context.l10n;
    final phone = _phone.text.trim();
    try {
      final existing = widget.mechanic;
      if (existing == null) {
        await MechanicRepo.create(
          name: _name.text.trim(),
          specialty: _specialty.text.trim(),
          phone: phone.isEmpty ? null : phone,
          isActive: _isActive,
        );
      } else {
        await MechanicRepo.update(
          existing.id,
          name: _name.text.trim(),
          specialty: _specialty.text.trim(),
          phone: phone.isEmpty ? null : phone,
          isActive: _isActive,
        );
      }
      if (!mounted) return;
      AppToaster.showMessage(l10n.technicianSaved);
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) AppToaster.showError(e.message);
    } on Object catch (_) {
      if (mounted) AppToaster.showError(l10n.technicianSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.mechanic != null;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(
        centerTitle: false,
        title: isEdit ? l10n.technicianEditTitle : l10n.technicianAddTitle,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppTextField(
                controller: _name,
                label: l10n.technicianName,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.technicianNameRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _specialty,
                label: l10n.technicianSpecialty,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.technicianSpecialtyRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _phone,
                label: l10n.technicianPhone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: Text(l10n.technicianActive),
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
