import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_state.dart';
import 'package:cinemora/features/settings/viewmodels/edit_profile_cubit.dart';
import 'package:cinemora/features/settings/viewmodels/edit_profile_state.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AppAuthCubit>().state;
    final user = authState is AppAuthAuthenticated ? authState.user : null;

    return BlocProvider(
      create: (ctx) => EditProfileCubit(
        ctx.read<UserRepository>(),
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

  static const _allGenres = [
    'Drama', 'Thriller', 'Sci-Fi', 'Crime', 'Horror', 'Action',
    'Psychological', 'Mystery', 'Romance', 'Fantasy', 'Documentary',
    'Animation',
  ];

  static const _languages = [
    'English', 'Japanese', 'Korean', 'French', 'Spanish', 'German', 'Hindi',
  ];

  static const _eras = [
    'Pre-1970s', '1970s', '1980s', '1990s', '2000s', '2010s', '2020s',
  ];

  static const _profileImage =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80';

  static const _coverImage =
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=80';

  @override
  void initState() {
    super.initState();
    // Pre-populate from the AppAuthCubit user so fields reflect live data.
    final authState = context.read<AppAuthCubit>().state;
    final user =
        authState is AppAuthAuthenticated ? authState.user : null;

    _nameController =
        TextEditingController(text: user?.name ?? '');
    _usernameController =
        TextEditingController(text: user?.displayUsername ?? '');
    _bioController =
        TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context) {
    context.read<EditProfileCubit>().save(
          name: _nameController.text,
          username: _usernameController.text,
          bio: _bioController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state.status == EditProfileStatus.success && state.savedUser != null) {
          // Propagate the updated user up to AppAuthCubit so every screen
          // that reads auth state (profile card, settings, etc.) refreshes.
          context.read<AppAuthCubit>().updateUser(state.savedUser!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully',
                style: TextStyle(fontSize: 14.sp),
              ),
              backgroundColor: WColors.chartGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              margin:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          );
          Navigator.maybePop(context);
        }

        if (state.status == EditProfileStatus.error &&
            state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!, style: TextStyle(fontSize: 14.sp)),
              backgroundColor: WColors.accentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              margin:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          );
          context.read<EditProfileCubit>().clearError();
        }
      },
      child: BlocBuilder<EditProfileCubit, EditProfileState>(
        builder: (context, state) {
          final cubit = context.read<EditProfileCubit>();
          final isSaving = state.status == EditProfileStatus.saving;

          return Scaffold(
            backgroundColor: WColors.background,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _TopBar(
                    onSave: isSaving ? null : () => _handleSave(context),
                    isSaving: isSaving,
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 100.h),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _CoverAvatarSection(
                          coverImage: _coverImage,
                          profileImage: _profileImage,
                        ),
                        SizedBox(height: 24.h),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: WSizes.screenPadding.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormCard(
                                children: [
                                  _PremiumTextField(
                                    label: 'DISPLAY NAME',
                                    controller: _nameController,
                                    hint: 'Your display name',
                                  ),
                                  const _Divider(),
                                  _PremiumTextField(
                                    label: 'USERNAME',
                                    controller: _usernameController,
                                    hint: 'your_username',
                                    prefix: '@',
                                  ),
                                  const _Divider(),
                                  _PremiumTextField(
                                    label: 'BIO',
                                    controller: _bioController,
                                    hint: 'Tell us about yourself...',
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                              const _SectionLabel(label: 'TASTE'),
                              SizedBox(height: 12.h),
                              _FormCard(
                                children: [
                                  const _FieldLabel(
                                      label: 'FAVORITE GENRES'),
                                  SizedBox(height: 10.h),
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    children: _allGenres.map((genre) {
                                      final selected = state.selectedGenres
                                          .contains(genre);
                                      return GestureDetector(
                                        onTap: () =>
                                            cubit.toggleGenre(genre),
                                        child: _GenreChip(
                                          label: genre,
                                          selected: selected,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              _FormCard(
                                children: [
                                  const _FieldLabel(
                                      label: 'FAVORITE LANGUAGE'),
                                  SizedBox(height: 10.h),
                                  SizedBox(
                                    height: 36.h,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      physics:
                                          const BouncingScrollPhysics(),
                                      itemCount: _languages.length,
                                      itemBuilder: (_, i) =>
                                          GestureDetector(
                                        onTap: () => cubit
                                            .selectLanguage(_languages[i]),
                                        child: _SelectChip(
                                          label: _languages[i],
                                          selected: state.selectedLanguage ==
                                              _languages[i],
                                        ),
                                      ),
                                      separatorBuilder: (_, __) =>
                                          SizedBox(width: 8.w),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              _FormCard(
                                children: [
                                  const _FieldLabel(label: 'FAVORITE ERA'),
                                  SizedBox(height: 10.h),
                                  SizedBox(
                                    height: 36.h,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      physics:
                                          const BouncingScrollPhysics(),
                                      itemCount: _eras.length,
                                      itemBuilder: (_, i) =>
                                          GestureDetector(
                                        onTap: () =>
                                            cubit.selectEra(_eras[i]),
                                        child: _SelectChip(
                                          label: _eras[i],
                                          selected:
                                              state.selectedEra == _eras[i],
                                        ),
                                      ),
                                      separatorBuilder: (_, __) =>
                                          SizedBox(width: 8.w),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                              GestureDetector(
                                onTap: cubit.togglePreview,
                                child: Row(
                                  children: [
                                    const _SectionLabel(
                                        label: 'PROFILE PREVIEW'),
                                    const Spacer(),
                                    Text(
                                      state.showPreview ? 'Hide' : 'Show',
                                      style: TextStyle(
                                        color: WColors.accentRed,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (state.showPreview) ...[
                                SizedBox(height: 12.h),
                                // Rebuild the preview on every keystroke by
                                // listening to the controllers via ValueListenableBuilder.
                                ValueListenableBuilder(
                                  valueListenable: _nameController,
                                  builder: (_, __, ___) =>
                                      ValueListenableBuilder(
                                    valueListenable: _usernameController,
                                    builder: (_, __, ___) =>
                                        ValueListenableBuilder(
                                      valueListenable: _bioController,
                                      builder: (_, __, ___) =>
                                          _ProfilePreviewCard(
                                        name: _nameController.text,
                                        username:
                                            _usernameController.text,
                                        bio: _bioController.text,
                                        profileImage: _profileImage,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(height: 24.h),
                              _SaveButton(
                                onSave: isSaving
                                    ? null
                                    : () => _handleSave(context),
                                isSaving: isSaving,
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
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback? onSave;
  final bool isSaving;

  const _TopBar({this.onSave, required this.isSaving});

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
                color: WColors.surfaceRaised.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: WColors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: WColors.mutedSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Edit Profile',
              style: TextStyle(
                color: WColors.foreground,
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSave,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: onSave != null
                    ? const LinearGradient(
                        colors: [WColors.accentRed, WColors.accentRedAlt],
                      )
                    : null,
                color: onSave == null
                    ? WColors.surfaceRaised.withValues(alpha: 0.5)
                    : null,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: isSaving
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: WColors.primaryForeground,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: WColors.primaryForeground,
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
  final String coverImage;
  final String profileImage;

  const _CoverAvatarSection({
    required this.coverImage,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    // Read live avatar from auth state so it reflects the real photo.
    final authState = context.read<AppAuthCubit>().state;
    final avatarUrl = authState is AppAuthAuthenticated
        ? authState.user.avatar
        : null;

    return SizedBox(
      height: 200.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(coverImage),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    WColors.background.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 12.h,
            right: 16.w,
            child: const _EditOverlay(label: 'Cover'),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          WColors.accentPurple.withValues(alpha: 0.8),
                          WColors.accentRed.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 48.r,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : NetworkImage(profileImage),
                      backgroundColor: WColors.surfaceRaised2,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: WColors.accentRed,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: WColors.background,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 14.sp,
                        color: WColors.primaryForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        color: WColors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_rounded, size: 13.sp, color: WColors.foreground),
          SizedBox(width: 4.w),
          Text(
            'Edit $label',
            style: TextStyle(
              color: WColors.foreground,
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
      decoration: BoxDecoration(
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: WColors.mutedSecondaryDeep,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: WColors.mutedSecondaryDeep,
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final int maxLines;

  const _PremiumTextField({
    required this.label,
    required this.controller,
    required this.hint,
    this.prefix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            color: WColors.foreground,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: WColors.mutedSecondaryDeep,
              fontSize: 15.sp,
            ),
            prefixText: prefix,
            prefixStyle: TextStyle(
              color: WColors.mutedSecondary,
              fontSize: 15.sp,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      height: 0.5,
      color: WColors.borderStrong,
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _GenreChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: selected
            ? WColors.accentRed.withValues(alpha: 0.12)
            : WColors.surfaceRaised2,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: selected
              ? WColors.accentRed.withValues(alpha: 0.4)
              : WColors.borderStrong,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:
              selected ? WColors.accentRed : WColors.mutedSecondarySoft,
          fontSize: 12.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _SelectChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: selected
            ? WColors.accentRed.withValues(alpha: 0.12)
            : WColors.surfaceRaised2,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: selected
              ? WColors.accentRed.withValues(alpha: 0.4)
              : WColors.borderStrong,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:
              selected ? WColors.accentRed : WColors.mutedSecondarySoft,
          fontSize: 13.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile preview
// ─────────────────────────────────────────────────────────────────────────────

class _ProfilePreviewCard extends StatelessWidget {
  final String name;
  final String username;
  final String bio;
  final String profileImage;

  const _ProfilePreviewCard({
    required this.name,
    required this.username,
    required this.bio,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AppAuthCubit>().state;
    final avatarUrl = authState is AppAuthAuthenticated
        ? authState.user.avatar
        : null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: WColors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Column(
        children: [
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: WColors.accentPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                  color: WColors.accentPurple.withValues(alpha: 0.2)),
            ),
            child: Text(
              'PREVIEW',
              style: TextStyle(
                color: WColors.accentPurple,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      WColors.accentPurple.withValues(alpha: 0.6),
                      WColors.accentRed.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 24.r,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : NetworkImage(profileImage),
                  backgroundColor: WColors.surfaceRaised2,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Display Name' : name,
                      style: TextStyle(
                        color: WColors.foreground,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '@${username.isEmpty ? "username" : username}',
                      style: TextStyle(
                        color: WColors.mutedSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    if (bio.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: WColors.mutedSecondarySoft,
                          fontSize: 11.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Save button
// ─────────────────────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final VoidCallback? onSave;
  final bool isSaving;

  const _SaveButton({this.onSave, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSave,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          gradient: onSave != null
              ? const LinearGradient(
                  colors: [WColors.accentRed, WColors.accentRedAlt],
                )
              : null,
          color: onSave == null
              ? WColors.surfaceRaised.withValues(alpha: 0.5)
              : null,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: isSaving
            ? Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: WColors.primaryForeground,
                  ),
                ),
              )
            : Text(
                'Save Changes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WColors.primaryForeground,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
