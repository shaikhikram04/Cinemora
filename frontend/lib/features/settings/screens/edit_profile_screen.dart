import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Ikram');
  final _usernameController = TextEditingController(text: 'ikram_watches');
  final _bioController =
      TextEditingController(text: 'Film • Anime • Series\nEnthusiast');

  final _allGenres = [
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

  final _selectedGenres = <String>{'Drama', 'Thriller', 'Psychological'};

  final _languages = [
    'English',
    'Japanese',
    'Korean',
    'French',
    'Spanish',
    'German',
    'Hindi',
  ];
  String _selectedLanguage = 'English';

  final _eras = [
    'Pre-1970s',
    '1970s',
    '1980s',
    '1990s',
    '2000s',
    '2010s',
    '2020s',
  ];
  String _selectedEra = '2010s';

  bool _showPreview = false;

  static const _profileImage =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80';

  static const _coverImage =
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=80';

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              onSave: () => _handleSave(context),
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
                            _Divider(),
                            _PremiumTextField(
                              label: 'USERNAME',
                              controller: _usernameController,
                              hint: 'your_username',
                              prefix: '@',
                            ),
                            _Divider(),
                            _PremiumTextField(
                              label: 'BIO',
                              controller: _bioController,
                              hint: 'Tell us about yourself...',
                              maxLines: 3,
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        _SectionLabel(label: 'TASTE'),
                        SizedBox(height: 12.h),
                        _FormCard(
                          children: [
                            _FieldLabel(label: 'FAVORITE GENRES'),
                            SizedBox(height: 10.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _allGenres.map((genre) {
                                final selected =
                                    _selectedGenres.contains(genre);
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    if (selected) {
                                      _selectedGenres.remove(genre);
                                    } else {
                                      _selectedGenres.add(genre);
                                    }
                                  }),
                                  child: _GenreChip(
                                      label: genre, selected: selected),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _FormCard(
                          children: [
                            _FieldLabel(label: 'FAVORITE LANGUAGE'),
                            SizedBox(height: 10.h),
                            SizedBox(
                              height: 36.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _languages.length,
                                itemBuilder: (_, i) => GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedLanguage = _languages[i]),
                                  child: _SelectChip(
                                    label: _languages[i],
                                    selected:
                                        _selectedLanguage == _languages[i],
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
                            _FieldLabel(label: 'FAVORITE ERA'),
                            SizedBox(height: 10.h),
                            SizedBox(
                              height: 36.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _eras.length,
                                itemBuilder: (_, i) => GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedEra = _eras[i]),
                                  child: _SelectChip(
                                    label: _eras[i],
                                    selected: _selectedEra == _eras[i],
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
                          onTap: () =>
                              setState(() => _showPreview = !_showPreview),
                          child: Row(
                            children: [
                              _SectionLabel(label: 'PROFILE PREVIEW'),
                              const Spacer(),
                              Text(
                                _showPreview ? 'Hide' : 'Show',
                                style: TextStyle(
                                  color: WColors.accentRed,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_showPreview) ...[
                          SizedBox(height: 12.h),
                          _ProfilePreviewCard(
                            name: _nameController.text,
                            username: _usernameController.text,
                            bio: _bioController.text,
                            profileImage: _profileImage,
                          ),
                        ],
                        SizedBox(height: 24.h),
                        _SaveButton(onSave: () => _handleSave(context)),
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
  }

  void _handleSave(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated successfully',
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: WColors.chartGreen,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
    Navigator.maybePop(context);
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback? onSave;

  const _TopBar({this.onSave});

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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [WColors.accentRed, WColors.accentRedAlt],
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
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

// ── Cover + avatar ───────────────────────────────────────────────────────────

class _CoverAvatarSection extends StatelessWidget {
  final String coverImage;
  final String profileImage;

  const _CoverAvatarSection({
    required this.coverImage,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover image
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
          // Edit cover overlay
          Positioned(
            top: 12.h,
            right: 16.w,
            child: _EditOverlay(label: 'Cover'),
          ),
          // Avatar
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
                      backgroundImage: NetworkImage(profileImage),
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

// ── Form components ──────────────────────────────────────────────────────────

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
          color: selected ? WColors.accentRed : WColors.mutedSecondarySoft,
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
          color: selected ? WColors.accentRed : WColors.mutedSecondarySoft,
          fontSize: 13.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ── Profile preview ──────────────────────────────────────────────────────────

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
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
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
                  backgroundImage: NetworkImage(profileImage),
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

// ── Save button ──────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final VoidCallback? onSave;

  const _SaveButton({this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSave,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [WColors.accentRed, WColors.accentRedAlt],
          ),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Text(
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
