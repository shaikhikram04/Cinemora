import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
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

  static const _allGenres = [
    'Drama',
    'Thriller',
    'Sci-Fi',
    'Crime',
    'Horror',
    'Action',
    'Psychological',
    'Mystery',
    'Romance',
    'Fantasy',
    'Documentary',
    'Animation',
  ];

  static const _languages = [
    'English',
    'Japanese',
    'Korean',
    'French',
    'Spanish',
    'German',
    'Hindi',
  ];

  // Full predefined list shown inside the "Others" sheet — leads with the
  // quick-pick row above (so it doubles as a complete picker), followed by
  // the languages already offered during onboarding (taste_setup_view's
  // _kLanguages: Tamil, Telugu, Malayalam, Marathi) for consistency, then a
  // broader predefined set.
  static const _moreLanguages = [
    ..._languages,
    'Tamil',
    'Telugu',
    'Malayalam',
    'Marathi',
    'Mandarin',
    'Cantonese',
    'Italian',
    'Portuguese',
    'Russian',
    'Arabic',
    'Turkish',
    'Thai',
    'Vietnamese',
    'Bengali',
    'Punjabi',
    'Gujarati',
    'Kannada',
    'Urdu',
    'Dutch',
    'Swedish',
    'Polish',
    'Indonesian',
  ];

  // Placeholder cover, shown only until the user picks one of their own. There's
  // no avatar equivalent — an unset avatar falls back to a person icon.
  static const _coverImage =
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=80';

  @override
  void initState() {
    super.initState();
    // Pre-populate from the AppAuthCubit user so fields reflect live data.
    final authState = context.read<AppAuthCubit>().state;
    final user = authState is AppAuthAuthenticated ? authState.user : null;

    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController =
        TextEditingController(text: user?.displayUsername ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
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

  void _openMoreLanguagesSheet(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _MoreLanguagesSheet(options: _moreLanguages),
      ),
    );
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
          final isSaving = state.status == EditProfileStatus.saving;
          // Saving mid-upload would race the image write against the profile
          // write and could return a user without the new URL.
          final canSave = !isSaving && !state.isUploading;

          return Scaffold(
            backgroundColor: context.colors.background,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _TopBar(
                    onSave: canSave ? () => _handleSave(context) : null,
                    isSaving: isSaving,
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 48.h),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const _CoverAvatarSection(coverImage: _coverImage),
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
                                  const _FieldLabel(label: 'FAVORITE GENRES'),
                                  SizedBox(height: 10.h),
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    children: _allGenres.map((genre) {
                                      final selected =
                                          state.selectedGenres.contains(genre);
                                      return GestureDetector(
                                        onTap: () => cubit.toggleGenre(genre),
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
                                      label: 'FAVORITE LANGUAGES'),
                                  SizedBox(height: 10.h),
                                  Builder(builder: (context) {
                                    final extra = state.selectedLanguages
                                        .where((l) => !_languages.contains(l))
                                        .toList();
                                    return SizedBox(
                                      height: 36.h,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: _languages.length +
                                            extra.length +
                                            1,
                                        itemBuilder: (_, i) {
                                          // [primary chips][extra selected
                                          // chips][Others button] — Others
                                          // always sits last.
                                          if (i < _languages.length) {
                                            final lang = _languages[i];
                                            return GestureDetector(
                                              onTap: () =>
                                                  cubit.toggleLanguage(lang),
                                              child: _SelectChip(
                                                label: lang,
                                                selected: state
                                                    .selectedLanguages
                                                    .contains(lang),
                                              ),
                                            );
                                          }
                                          if (i <
                                              _languages.length +
                                                  extra.length) {
                                            final lang =
                                                extra[i - _languages.length];
                                            return GestureDetector(
                                              onTap: () =>
                                                  cubit.toggleLanguage(lang),
                                              child: _SelectChip(
                                                label: lang,
                                                selected: true,
                                              ),
                                            );
                                          }
                                          return GestureDetector(
                                            onTap: () =>
                                                _openMoreLanguagesSheet(
                                                    context),
                                            child: _OthersChip(
                                                active: extra.isNotEmpty),
                                          );
                                        },
                                        separatorBuilder: (_, __) =>
                                            SizedBox(width: 8.w),
                                      ),
                                    );
                                  }),
                                ],
                              ),
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
          GestureDetector(
            onTap: onSave,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: onSave != null
                    ? LinearGradient(
                        colors: [
                          context.colors.accentRed,
                          context.colors.accentRedAlt
                        ],
                      )
                    : null,
                color: onSave == null
                    ? context.colors.surfaceRaised.withValues(alpha: 0.5)
                    : null,
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
                        color: context.colors.primaryForeground,
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

    return BlocBuilder<EditProfileCubit, EditProfileState>(
      builder: (context, state) {
        final coverUrl = state.coverUrl;
        final avatarUrl = state.avatarUrl;

        return SizedBox(
          height: 200.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: state.isUploading ? null : cubit.pickCover,
                child: Container(
                  height: 150.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(coverUrl ?? coverImage),
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
                          context.colors.background.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: state.isUploadingCover
                        ? const _UploadingScrim()
                        : null,
                  ),
                ),
              ),
              Positioned(
                top: 12.h,
                right: 16.w,
                child: GestureDetector(
                  onTap: state.isUploading ? null : cubit.pickCover,
                  child: const _EditOverlay(label: 'Cover'),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: state.isUploading ? null : cubit.pickAvatar,
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                context.colors.accentPurple
                                    .withValues(alpha: 0.8),
                                context.colors.accentRed.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 48.r,
                            backgroundColor: context.colors.surfaceRaised2,
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: state.isUploadingAvatar
                                ? const _UploadingScrim(circular: true)
                                : avatarUrl == null
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: 40.sp,
                                        color: context.colors.mutedSecondary,
                                      )
                                    : null,
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
                              border: Border.all(
                                color: context.colors.background,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 14.sp,
                              color: context.colors.primaryForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
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
        borderRadius: BorderRadius.circular(10.r),
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
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.colors.borderStrong),
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
        color: context.colors.mutedSecondaryDeep,
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
        color: context.colors.mutedSecondaryDeep,
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
            color: context.colors.foreground,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
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
      color: context.colors.borderStrong,
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
            ? context.colors.accentRed.withValues(alpha: 0.12)
            : context.colors.surfaceRaised2,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: selected
              ? context.colors.accentRed.withValues(alpha: 0.4)
              : context.colors.borderStrong,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? context.colors.accentRed
              : context.colors.mutedSecondarySoft,
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
            ? context.colors.accentRed.withValues(alpha: 0.12)
            : context.colors.surfaceRaised2,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: selected
              ? context.colors.accentRed.withValues(alpha: 0.4)
              : context.colors.borderStrong,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? context.colors.accentRed
              : context.colors.mutedSecondarySoft,
          fontSize: 13.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _OthersChip extends StatelessWidget {
  final bool active;

  const _OthersChip({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: active
            ? context.colors.accentRed.withValues(alpha: 0.12)
            : context.colors.surfaceRaised2,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: active
              ? context.colors.accentRed.withValues(alpha: 0.4)
              : context.colors.borderStrong,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_rounded,
            size: 14.sp,
            color: active
                ? context.colors.accentRed
                : context.colors.mutedSecondarySoft,
          ),
          SizedBox(width: 3.w),
          Text(
            'Others',
            style: TextStyle(
              color: active
                  ? context.colors.accentRed
                  : context.colors.mutedSecondarySoft,
              fontSize: 13.sp,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Others languages sheet
// ─────────────────────────────────────────────────────────────────────────────

class _MoreLanguagesSheet extends StatelessWidget {
  final List<String> options;

  const _MoreLanguagesSheet({required this.options});

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
                      children: options.map((lang) {
                        final selected = state.selectedLanguages.contains(lang);
                        return GestureDetector(
                          onTap: () => cubit.toggleLanguage(lang),
                          child: _SelectChip(label: lang, selected: selected),
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
              ? LinearGradient(
                  colors: [
                    context.colors.accentRed,
                    context.colors.accentRedAlt
                  ],
                )
              : null,
          color: onSave == null
              ? context.colors.surfaceRaised.withValues(alpha: 0.5)
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
                    color: context.colors.primaryForeground,
                  ),
                ),
              )
            : Text(
                'Save Changes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.primaryForeground,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
