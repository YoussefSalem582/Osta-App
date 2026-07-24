import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/profile/data/models/profile_response/data.dart';
import 'package:osta/features/shared/profile/presentation/profile/cubit/profile_cubit.dart';
import 'package:osta/features/shared/profile/presentation/profile/cubit/profile_state.dart';
import 'package:osta/features/shared/profile/presentation/profile/widgets/avatar_picker.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({required this.profileData, super.key});

  final Data profileData;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ProfileCubit>(),
    child: EditProfileView(profileData: profileData),
  );
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({required this.profileData, super.key});

  final Data profileData;

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;

  File? pickedImage;

  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    final d = widget.profileData;
    firstNameController = TextEditingController(text: d.firstName ?? '');
    lastNameController = TextEditingController(text: d.lastName ?? '');
    usernameController = TextEditingController(text: d.username ?? '');
    emailController = TextEditingController(text: d.email ?? '');
    phoneController = TextEditingController(text: d.phone ?? '');
    avatarUrl = d.avatarUrl?.toString();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;
    setState(() => pickedImage = File(picked.path));
    if (!mounted) return;
    await context.read<ProfileCubit>().uploadAvatar(picked.path);
  }

  void save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    unawaited(
      context.read<ProfileCubit>().updateProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          AppToaster.showMessage(l10n.editProfileSuccess);
          Navigator.of(context).pop(state.profile.data);
        } else if (state is ProfileUpdateError) {
          AppToaster.showError(state.errorMessage);
        } else if (state is ProfileAvatarSuccess) {
          setState(() {
            avatarUrl = state.profile.data?.avatarUrl?.toString();
            pickedImage = null;
          });
          AppToaster.showMessage(l10n.editProfileAvatarSuccess);
        } else if (state is ProfileAvatarError) {
          setState(() => pickedImage = null);
          AppToaster.showError(l10n.editProfileAvatarError);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppTopBar(title: l10n.editProfileTitle),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final isSaving = state is ProfileUpdateLoading;
            final isUploadingAvatar = state is ProfileAvatarUploading;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                children: [
                  AvatarPicker(
                    avatarUrl: avatarUrl,
                    pickedImage: pickedImage,
                    isUploading: isUploadingAvatar,
                    profileData: widget.profileData,
                    onTap: isUploadingAvatar ? null : pickAndUploadAvatar,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AppTextField(
                    label: l10n.editProfileFirstName,
                    controller: firstNameController,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.validationRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: l10n.editProfileLastName,
                    controller: lastNameController,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.validationRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: l10n.editProfileUsername,
                    controller: usernameController,
                    prefixIcon: Icons.alternate_email_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.validationRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: l10n.editProfileEmail,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.validationRequired;
                      }
                      if (!v.contains('@')) return l10n.validationEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: l10n.editProfilePhone,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.validationRequired
                        : null,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AppButton(
                    label: l10n.editProfileSave,
                    loading: isSaving,
                    onPressed: isSaving ? null : save,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
