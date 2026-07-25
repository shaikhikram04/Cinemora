import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/network_images_path.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/constants/taste_options.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_state.dart';
import 'package:cinemora/features/settings/viewmodels/edit_profile_cubit.dart';
import 'package:cinemora/features/settings/viewmodels/edit_profile_state.dart';
import 'package:cinemora/features/settings/widgets/settings_ui.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AppAuthCubit>().state;
    final user = authState is AppAuthAuthenticated ? authState.user : null;

    return BlocProvider(
      create: (ctx) => EditProfileCubit(
        ctx.read<UserRepository>(),
        ctx.read<AppAuthCubit>(),
        user ?? const UserModel(id: '', name: '', email: '', isOnboarded: true),
      ),
      child: const _EditProfileContent(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileContent extends StatefulWidget {
  const _EditProfileContent();

  @override
  State<_EditProfileContent> createState() => _EditProfileContentState();
}

class _EditProfileContentState extends State<_EditProfileContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  static const _bioMaxLength = 160;

  // Placeholder cover, shown only until the user picks one of their own. There's
  // no avatar equivalent — an unset avatar falls back to a person icon.
  static const _coverImage = NetworkImagesPath.defaultProfileCover;

  @override
  void initState() {
    super.initState();
    // Seed from the cubit, which took its own snapshot of the auth user — so
    // the fields and the dirty check start from exactly the same values.
    final state = context.read<EditProfileCubit>().state;

    _nameController = TextEditingController(text: state.name);
    _usernameController = TextEditingController(text: state.username);
    _bioController = TextEditingController(text: state.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _openMoreLanguagesSheet(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _MoreLanguagesSheet(),
      ),
    );
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Discard changes?',
          style: TextStyle(
            color: context.colors.foreground,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Your edits to this profile haven’t been saved yet.',
          style: TextStyle(
            color: context.colors.mutedSecondarySoft,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Keep Editing',
              style: TextStyle(color: context.colors.mutedSecondarySoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Discard',
              style: TextStyle(
                color: context.colors.accentRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (discard == true && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state.status == EditProfileStatus.success &&
            state.savedUser != null) {
          // Propagate the updated user up to AppAuthCubit so every screen
          // that reads auth state (profile card, settings, etc.) refreshes.
          context.read<AppAuthCubit>().updateUser(state.savedUser!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully',
                style: TextStyle(fontSize: 14.sp),
              ),
              backgroundColor: context.colors.chartGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          );
          Navigator.maybePop(context);
        }

        if (state.status == EditProfileStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!, style: TextStyle(fontSize: 14.sp)),
              backgroundColor: context.colors.accentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          );
          context.read<EditProfileCubit>().clearError();
        }
      },
      child: BlocBuilder<EditProfileCubit, EditProfileState>(
        builder: (context, state) {
          final cubit = context.read<EditProfileCubit>();

          return PopScope(
            // Leaving with pending edits would drop them silently; the guard
            // only engages while there is actually something to lose.
            canPop: !state.isDirty,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _confirmDiscard(context);
            },
            child: Scaffold(
              backgroundColor: context.colors.background,
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _TopBar(
                      canSave: state.canSave,
                      isSaving: state.status == EditProfileStatus.saving,
                      onSave: cubit.save,
                    ),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 48.h),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const _CoverAvatarSection(coverImage: _coverImage),
                          SizedBox(height: 28.h),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: WSizes.screenPadding.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SettingsSectionLabel(label: 'PROFILE'),
                                SizedBox(height: 12.h),
                                _FormCard(
                                  children: [
                                    _ProfileTextField(
                                      label: 'Display name',
                                      controller: _nameController,
                                      hint: 'Your display name',
                                      onChanged: cubit.setName,
                                    ),
                                    SizedBox(height: 16.h),
                                    _ProfileTextField(
                                      label: 'Username',
                                      controller: _usernameController,
                                      hint: 'your_username',
                                      prefix: '@',
                                      onChanged: cubit.setUsername,
                                    ),
                                    SizedBox(height: 16.h),
                                    _ProfileTextField(
                                      label: 'Bio',
                                      controller: _bioController,
                                      hint: 'Tell us about yourself...',
                                      maxLines: 3,
                                      maxLength: _bioMaxLength,
                                      onChanged: cubit.setBio,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.h),
                                const SettingsSectionLabel(label: 'TASTE'),
                                SizedBox(height: 12.h),
                                // Genres and languages are one card: they're
                                // the same question asked twice, and splitting
                                // them read as an accidental break.
                                _FormCard(
                                  children: [
                                    _FieldLabel(label: 'Favorite genres'),
                                    SizedBox(height: 12.h),
                                    _GenreWrap(state: state, cubit: cubit),
                                    const _CardDivider(),
                                    _FieldLabel(label: 'Favorite languages'),
                                    SizedBox(height: 12.h),
                                    _LanguageWrap(
                                      state: state,
                                      cubit: cubit,
                                      onOthers: () =>
                                          _openMoreLanguagesSheet(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Taste selectors
// ─────────────────────────────────────────────────────────────────────────────

class _GenreWrap extends StatelessWidget {
  final EditProfileState state;
  final EditProfileCubit cubit;

  const _GenreWrap({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    // A genre the user holds that this build doesn't know about would otherwise
    // be invisible and un-removable while still being saved. Surfacing it costs
    // one line and makes the list self-healing.
    final extra = state.selectedGenres
        .where((g) => !TasteOptions.genres.contains(g))
        .toList();

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final genre in [...TasteOptions.genres, ...extra])
          _TasteChip(
            label: genre,
            selected: state.selectedGenres.contains(genre),
            onTap: () => cubit.toggleGenre(genre),
          ),
      ],
    );
  }
}

class _LanguageWrap extends StatelessWidget {
  final EditProfileState state;
  final EditProfileCubit cubit;
  final VoidCallback onOthers;

  const _LanguageWrap({
    required this.state,
    required this.cubit,
    required this.onOthers,
  });

  @override
  Widget build(BuildContext context) {
    final extra = state.selectedLanguages
        .where((l) => !TasteOptions.languages.contains(l))
        .toList();

    // Wrapped rather than scrolled horizontally: with this many options a wrap
    // shows everything, and "Others" — the door to the rest — stays on screen
    // instead of waiting past an edge nothing hints at.
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final lang in [...TasteOptions.languages, ...extra])
          _TasteChip(
            label: lang,
            selected: state.selectedLanguages.contains(lang),
            onTap: () => cubit.toggleLanguage(lang),
          ),
        _TasteChip(
          label: 'Others',
          icon: Icons.add_rounded,
          selected: extra.isNotEmpty,
          onTap: onOthers,
        ),
      ],
    );
  }
}

/// One chip shape for every taste selection. Genres and languages are the same
/// interaction, so they get the same pill — previously one was a pill and the
/// other a rounded rectangle, sitting a few dozen pixels apart.
class _TasteChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const _TasteChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tint =
        selected ? context.colors.accentRed : context.colors.mutedSecondarySoft;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? context.colors.accentRed.withValues(alpha: 0.12)
              : context.colors.surfaceRaised2,
          borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
          border: Border.all(
            color: selected
                ? context.colors.accentRed.withValues(alpha: 0.4)
                : context.colors.borderStrong,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14.sp, color: tint),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                color: tint,
                fontSize: 13.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool canSave;
  final bool isSaving;
  final VoidCallback onSave;

  const _TopBar({
    required this.canSave,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          WSizes.screenPadding.w, 12.h, WSizes.screenPadding.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: context.colors.surfaceRaised.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: context.colors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: context.colors.mutedSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Edit Profile',
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          // The screen's only Save. It reads state.canSave, so it is dimmed
          // until something has actually changed and stays dimmed while an
          // image upload is in flight.
          GestureDetector(
            onTap: canSave ? onSave : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: canSave
                    ? LinearGradient(
                        colors: [
                          context.colors.accentRed,
                          context.colors.accentRedAlt
                        ],
                      )
                    : null,
                color: canSave
                    ? null
                    : context.colors.surfaceRaised.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: isSaving
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.primaryForeground,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: canSave
                            ? context.colors.primaryForeground
                            : context.colors.mutedSecondary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cover + avatar
// ─────────────────────────────────────────────────────────────────────────────

class _CoverAvatarSection extends StatelessWidget {
  /// Shown until the user has picked a cover of their own.
  final String coverImage;

  const _CoverAvatarSection({required this.coverImage});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();

    // Derived rather than hardcoded so the avatar always half-overlaps the
    // cover — the two used different scale factors, which made the overlap
    // drift with the device's aspect ratio.
    final coverHeight = 150.h;
    final avatarSize = 102.w;

    return BlocBuilder<EditProfileCubit, EditProfileState>(
      builder: (context, state) {
        return SizedBox(
          height: coverHeight + avatarSize / 2,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: coverHeight,
                child: GestureDetector(
                  onTap: state.isUploading ? null : cubit.pickCover,
                  child: _CoverImage(
                    url: state.coverUrl ?? coverImage,
                    isUploading: state.isUploadingCover,
                  ),
                ),
              ),
              // Sits inside the bottom scrim rather than over the brightest
              // part of the photo, and clear of the centred avatar.
              Positioned(
                top: coverHeight - 38.h,
                right: 16.w,
                child: GestureDetector(
                  onTap: state.isUploading ? null : cubit.pickCover,
                  child: const _EditOverlay(label: 'Cover'),
                ),
              ),
              Positioned(
                bottom: 0,
                child: GestureDetector(
                  onTap: state.isUploading ? null : cubit.pickAvatar,
                  child: _Avatar(
                    url: state.avatarUrl,
                    size: avatarSize,
                    isUploading: state.isUploadingAvatar,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String url;
  final bool isUploading;

  const _CoverImage({required this.url, required this.isUploading});

  @override
  Widget build(BuildContext context) {
    // Width only — constraining both axes would distort the decode when the
    // source aspect ratio doesn't match the box.
    final cacheWidth = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round();

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          // A 404 or an offline launch would otherwise throw while painting.
          errorBuilder: (_, __, ___) =>
              ColoredBox(color: context.colors.surfaceMuted),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                context.colors.background.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
        if (isUploading) const _UploadingScrim(),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final double size;
  final bool isUploading;

  const _Avatar({
    required this.url,
    required this.size,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    const ringWidth = 3.0;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(ringWidth.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                context.colors.accentPurple.withValues(alpha: 0.8),
                context.colors.accentRed.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: context.colors.surfaceRaised2,
                  child: url == null
                      ? _fallbackIcon(context)
                      : Image.network(
                          url!,
                          fit: BoxFit.cover,
                          cacheWidth: (size *
                                  MediaQuery.devicePixelRatioOf(context))
                              .round(),
                          errorBuilder: (_, __, ___) => _fallbackIcon(context),
                        ),
                ),
                if (isUploading) const _UploadingScrim(circular: true),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: context.colors.accentRed,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.background, width: 2),
            ),
            child: Icon(
              Icons.camera_alt_rounded,
              size: 14.sp,
              color: context.colors.primaryForeground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallbackIcon(BuildContext context) => Icon(
        Icons.person_rounded,
        size: 40.sp,
        color: context.colors.mutedSecondary,
      );
}

/// Darkens the image being replaced and spins over it while the upload runs.
class _UploadingScrim extends StatelessWidget {
  final bool circular;

  const _UploadingScrim({this.circular = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background.withValues(alpha: 0.55),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.colors.accentRed,
          ),
        ),
      ),
    );
  }
}

class _EditOverlay extends StatelessWidget {
  final String label;

  const _EditOverlay({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_rounded,
              size: 13.sp, color: context.colors.foreground),
          SizedBox(width: 4.w),
          Text(
            'Edit $label',
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form components
// ─────────────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// Sentence case, not caps — the all-caps section label above is what carries
/// the hierarchy, and two competing caps styles one point apart carried none.
class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: context.colors.mutedSecondary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 18.h),
      height: 0.5,
      color: context.colors.border,
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String> onChanged;

  const _ProfileTextField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.prefix,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    // A field with no border, no fill and no focus state is indistinguishable
    // from static text on a raised card — so it gets all three.
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          maxLength: maxLength,
          style: TextStyle(
            color: context.colors.foreground,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
          buildCounter: maxLength == null ? null : _buildCounter,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.colors.mutedSecondaryDeep,
              fontSize: 15.sp,
            ),
            prefixText: prefix,
            prefixStyle: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 15.sp,
            ),
            filled: true,
            fillColor: context.colors.surfaceRaised2,
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            enabledBorder: border(context.colors.border, 1),
            focusedBorder: border(context.colors.ring, 1.5),
            border: border(context.colors.border, 1),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(
    BuildContext context, {
    required int currentLength,
    required int? maxLength,
    required bool isFocused,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Text(
        '$currentLength/$maxLength',
        style: TextStyle(
          color: context.colors.mutedSecondaryHeader,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Others languages sheet
// ─────────────────────────────────────────────────────────────────────────────

class _MoreLanguagesSheet extends StatelessWidget {
  const _MoreLanguagesSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: context.colors.surfaceRaised,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: context.colors.borderStrong),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.colors.borderStrong,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Other Languages',
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Select as many as you like',
              style: TextStyle(
                color: context.colors.mutedSecondary,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: BlocBuilder<EditProfileCubit, EditProfileState>(
                builder: (context, state) {
                  final cubit = context.read<EditProfileCubit>();
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: TasteOptions.moreLanguages.map((lang) {
                        return _TasteChip(
                          label: lang,
                          selected: state.selectedLanguages.contains(lang),
                          onTap: () => cubit.toggleLanguage(lang),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.accentRed,
                      context.colors.accentRedAlt,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  'Done',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.colors.primaryForeground,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
