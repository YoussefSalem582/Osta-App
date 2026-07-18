import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/features/shared/profile/data/model/profile_response/data.dart';

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    required this.avatarUrl,
    required this.pickedImage,
    required this.isUploading,
    required this.profileData,
    required this.onTap,
    super.key,
  });

  final String? avatarUrl;
  final File? pickedImage;
  final bool isUploading;
  final Data profileData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget avatar;

    if (pickedImage != null) {
      avatar = CircleAvatar(
        radius: 52,
        backgroundImage: FileImage(pickedImage!),
      );
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 52,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl!,
            width: 104,
            height: 104,
            fit: BoxFit.cover,
            placeholder: (_, _) =>
                const CircularProgressIndicator.adaptive(strokeWidth: 2),
            errorWidget: (_, _, _) => Icon(
              Icons.person_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    } else {
      final name = profileData.fullName ?? '';
      final firstChar = name.isNotEmpty ? name.characters.first : '؟';
      avatar = CircleAvatar(
        radius: 52,
        backgroundColor: AppColors.brandLime,
        child: Text(
          firstChar,
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            avatar,
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: isUploading
                    ? Padding(
                        padding: const EdgeInsets.all(6),
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: colorScheme.onPrimary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
