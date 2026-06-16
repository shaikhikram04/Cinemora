import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/features/watch_together/viewmodels/create_session_cubit.dart';
import 'package:cinemora/features/watch_together/viewmodels/create_session_state.dart';

// ─── View ─────────────────────────────────────────────────────────────────────

class CreateSessionView extends StatelessWidget {
  const CreateSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateSessionCubit(),
      child: const _CreateSessionContent(),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _CreateSessionContent extends StatefulWidget {
  const _CreateSessionContent();

  static const _contentTypes = ['Movies', 'Series', 'Both'];
  static const _genres = [
    'Action',
    'Comedy',
    'Sci-Fi',
    'Drama',
    'Thriller',
    'Horror',
    'Romance',
    'Animation',
    'Documentary',
    'Fantasy',
    'Mystery',
    'Adventure',
  ];

  @override
  State<_CreateSessionContent> createState() => _CreateSessionContentState();
}

class _CreateSessionContentState extends State<_CreateSessionContent> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  void _createSession() {
    final code = _generateCode();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _InviteCodeSheet(code: code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateSessionCubit, CreateSessionState>(
      builder: (context, state) {
        final cubit = context.read<CreateSessionCubit>();
        return Scaffold(
          backgroundColor: context.colors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      _BackButton(),
                      SizedBox(width: 12.w),
                      Text(
                        'Create Session',
                        style: TextStyle(
                          color: context.colors.foreground,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        _SectionLabel('Session Name'),
                        SizedBox(height: 8.h),
                        _NameField(controller: _nameController),
                        SizedBox(height: 24.h),
                        _SectionLabel('Content Type'),
                        SizedBox(height: 10.h),
                        _ContentTypeRow(
                          selected: state.contentType,
                          options: _CreateSessionContent._contentTypes,
                          onSelected: cubit.selectContentType,
                        ),
                        SizedBox(height: 24.h),
                        _SectionLabel('Genre Filter'),
                        SizedBox(height: 4.h),
                        Text(
                          'Select genres you both enjoy',
                          style: TextStyle(
                            color: context.colors.mutedSecondary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children:
                              _CreateSessionContent._genres.map((genre) {
                            final selected =
                                state.selectedGenres.contains(genre);
                            return _GenreChip(
                              label: genre,
                              selected: selected,
                              onTap: () => cubit.toggleGenre(genre),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 36.h),
                        _CreateButton(onTap: _createSession),
                        SizedBox(height: 28.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Shared header widgets ─────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: context.colors.surfaceMuted,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: context.colors.borderStrong),
        ),
        child: Icon(Icons.arrow_back_rounded,
            color: context.colors.foreground, size: 18.sp),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.colors.foreground,
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ── Form widgets ──────────────────────────────────────────────────────────────

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: context.colors.foreground,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'e.g. Movie Night 🎬',
          hintStyle: TextStyle(
            color: context.colors.mutedSecondary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }
}

class _ContentTypeRow extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _ContentTypeRow({
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.asMap().entries.map((entry) {
        final isLast = entry.key == options.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8.w),
            child: _ContentTypeChip(
              label: entry.value,
              selected: entry.value == selected,
              onTap: () => onSelected(entry.value),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ContentTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ContentTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: selected
            ? LinearGradient(
                colors: [const Color(0xFF9B1C35), context.colors.accentRed],
              )
            : null,
        color: selected ? null : context.colors.surfaceRaised,
        border: Border.all(
          color: selected ? Colors.transparent : context.colors.borderStrong,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: context.colors.accentRed.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: SizedBox(
            height: 44.h,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : context.colors.mutedSecondary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenreChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? context.colors.accentPurple.withValues(alpha: 0.18)
            : context.colors.surfaceChip,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: selected ? context.colors.accentPurple : context.colors.surfaceChipBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(999.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? context.colors.accentPurple
                    : context.colors.mutedSecondaryVibe,
                fontSize: 12.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [const Color(0xFF9B1C35), context.colors.accentRed],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.accentRed.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: SizedBox(
            height: 54.h,
            child: Center(
              child: Text(
                'Create Session',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Invite code bottom sheet ───────────────────────────────────────────────────

class _InviteCodeSheet extends StatelessWidget {
  final String code;
  const _InviteCodeSheet({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: context.colors.surfaceTint,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [const Color(0xFF2B1259), context.colors.accentRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.accentRed.withValues(alpha: 0.30),
                  blurRadius: 24,
                ),
              ],
            ),
            child:
                Icon(Icons.check_rounded, color: Colors.white, size: 28.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            'Session Created!',
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Share this code with your watch partner',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 22.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: context.colors.accentRed.withValues(alpha: 0.28),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.accentRed.withValues(alpha: 0.07),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 30.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 7.0,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _SheetAction(
                  icon: Icons.copy_rounded,
                  label: 'Copy Code',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    _showSnack(context, 'Code copied!');
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SheetAction(
                  icon: Icons.share_rounded,
                  label: 'Share Link',
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: 'watchary://join/$code'),
                    );
                    _showSnack(context, 'Link copied!');
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SheetAction(
                  icon: Icons.qr_code_rounded,
                  label: 'Show QR',
                  onTap: () => _showQrDialog(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.surfaceMuted,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: context.colors.surfaceRaised,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR Code',
                style: TextStyle(
                  color: context.colors.foreground,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 120.sp,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                code,
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: context.colors.accentRed,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: SizedBox(
            height: 54.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: context.colors.foreground, size: 18.sp),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: TextStyle(
                    color: context.colors.mutedSecondary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
