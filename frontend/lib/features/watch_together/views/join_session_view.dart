import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/colors.dart';

class JoinSessionView extends StatefulWidget {
  const JoinSessionView({super.key});

  @override
  State<JoinSessionView> createState() => _JoinSessionViewState();
}

class _JoinSessionViewState extends State<JoinSessionView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _joinSession() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length < 8) {
      _showSnack('Please enter a valid 8-character code');
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _JoiningDialog(code: code),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: WColors.surfaceMuted,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  _BackButton(),
                  SizedBox(width: 12.w),
                  Text(
                    'Join Session',
                    style: TextStyle(
                      color: WColors.foreground,
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
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 28.h),
                    // Illustration
                    Center(
                      child: Container(
                        width: 96.w,
                        height: 96.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2B1259), WColors.accentRed],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: WColors.accentRed.withValues(alpha: 0.28),
                              blurRadius: 32,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: const Color(0xFFA94EF2).withValues(alpha: 0.20),
                              blurRadius: 24,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.link_rounded,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Enter Invite Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WColors.foreground,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Ask your partner to share their\nsession code with you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WColors.mutedSecondary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 36.h),
                    _CodeField(controller: _codeController),
                    SizedBox(height: 20.h),
                    _JoinButton(onTap: _joinSession),
                    SizedBox(height: 20.h),
                    // OR divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: WColors.borderStrong, thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: WColors.mutedSecondary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: WColors.borderStrong, thickness: 1)),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    _QrButton(onTap: () => _showSnack('QR scanner coming soon!')),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Back button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: WColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: WColors.borderStrong),
        ),
        child: Icon(Icons.arrow_back_rounded, color: WColors.foreground, size: 18.sp),
      ),
    );
  }
}

// ── Form widgets ──────────────────────────────────────────────────────────────

class _CodeField extends StatelessWidget {
  final TextEditingController controller;
  const _CodeField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: WColors.accentRed.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: WColors.accentRed.withValues(alpha: 0.06),
            blurRadius: 24,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.characters,
        textAlign: TextAlign.center,
        maxLength: 8,
        style: TextStyle(
          color: WColors.foreground,
          fontSize: 26.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 8.0,
        ),
        decoration: InputDecoration(
          hintText: 'ABCD1234',
          hintStyle: TextStyle(
            color: WColors.mutedSecondary.withValues(alpha: 0.4),
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 8.0,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          counterText: '',
        ),
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  final VoidCallback onTap;
  const _JoinButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF9B1C35), WColors.accentRed],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: WColors.accentRed.withValues(alpha: 0.35),
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
                'Join Session',
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

class _QrButton extends StatelessWidget {
  final VoidCallback onTap;
  const _QrButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Material(
        color: WColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: SizedBox(
            height: 54.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner_rounded,
                    color: WColors.foreground, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Scan QR Code',
                  style: TextStyle(
                    color: WColors.foreground,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
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

// ── Joining dialog ─────────────────────────────────────────────────────────────

class _JoiningDialog extends StatelessWidget {
  final String code;
  const _JoiningDialog({required this.code});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: WColors.surfaceRaised,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2B1259), WColors.accentRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: WColors.accentRed.withValues(alpha: 0.28),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Icon(Icons.people_rounded, color: Colors.white, size: 28.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Joining Session',
              style: TextStyle(
                color: WColors.foreground,
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              code,
              style: TextStyle(
                color: WColors.accentRed,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Connecting you with your partner...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: WColors.mutedSecondary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: WColors.mutedSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
