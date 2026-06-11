import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/common/widgets/containers/top_gradient_background_container.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/shadows.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/core/themes/custom_theme/text_theme.dart';
import 'package:watchary/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:watchary/features/authentication/viewmodels/app_auth_state.dart';

import '../../../common/widgets/headers/branding_hero.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppAuthCubit, AppAuthState>(
      listener: (context, state) {
        if (state is AppAuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade800,
            ),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: WColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: WColors.background,
          body: TopGradientBackgroundContainer(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: WSizes.md.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacer(),
                    BrandHero(
                      iconSize: 96,
                      fontSize: 30,
                    ),
                    SizedBox(height: WSizes.xl.h),
                    Text('WELCOME BACK', style: WTextTheme.label),
                    SizedBox(height: WSizes.sm.h),
                    Text('Pick up where\nyou left off.', style: WTextTheme.h1),
                    SizedBox(height: WSizes.md.h),
                    Text(
                      'Sign in to sync your watchlist, ratings and\nAI picks across devices.',
                      style: WTextTheme.body.copyWith(
                        fontSize: 14.sp,
                        color: WColors.mutedSecondary,
                      ),
                    ),
                    Spacer(),
                    SizedBox(height: WSizes.lg.h),
                    _SignInButtons(),
                    SizedBox(height: (WSizes.lg * 2).h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sign-in buttons ───────────────────────────────────────────────────────────

class _SignInButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AppAuthCubit, bool>(
      (c) => c.state is AppAuthLoading,
    );
    final cubit = context.read<AppAuthCubit>();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: isLoading ? null : WShadow.redGlow,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(58.h),
                backgroundColor: WColors.primary,
                foregroundColor: WColors.primaryForeground,
                textStyle: WTextTheme.button.copyWith(fontSize: 16.sp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                elevation: 0,
              ),
              onPressed: isLoading ? null : cubit.signInWithGoogle,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sign In with Google'),
                        SizedBox(width: WSizes.sm.w),
                        Icon(Icons.arrow_forward, size: 20.sp),
                      ],
                    ),
            ),
          ),
        ),
        SizedBox(height: WSizes.md.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(58.h),
              side: const BorderSide(color: Color.fromARGB(28, 255, 255, 255)),
              foregroundColor: WColors.foreground,
              textStyle: WTextTheme.button.copyWith(fontSize: 16.sp),
              backgroundColor:
                  const Color.fromARGB(255, 58, 58, 61).withAlpha(120),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
            onPressed: isLoading ? null : cubit.signInWithApple,
            child: const Text('Sign In with Apple'),
          ),
        ),
      ],
    );
  }
}
