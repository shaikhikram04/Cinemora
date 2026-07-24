import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/viewmodels/network_status_cubit.dart';

/// Ambient "you are offline" indicator. Wraps the whole router once from
/// [MaterialApp.router]'s builder, so every route gets it without knowing it
/// exists.
///
/// Deliberately an overlay rather than a SnackBar: repeated failures would
/// queue SnackBars up, and none of them would tell the user they are *still*
/// offline a minute later.
class OfflineBanner extends StatelessWidget {
  final Widget child;

  const OfflineBanner.offlineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkStatusCubit, NetworkStatus>(
      builder: (context, status) {
        final hidden = status == NetworkStatus.online;
        final restored = status == NetworkStatus.restored;
        final barHeight = _kBarHeight.h;
        final mq = MediaQuery.of(context);

        return Stack(
          children: [
            // The bar sits above the status bar inset, so screens must be told
            // their safe area starts lower — otherwise every header renders
            // underneath it. Feeding it through MediaQuery means the existing
            // SafeArea in each screen does the work, with nothing to change
            // per-screen.
            MediaQuery(
              data: mq.copyWith(
                padding: mq.padding.copyWith(
                  top: mq.padding.top + (hidden ? 0 : barHeight),
                ),
              ),
              child: child,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                // Never steal a tap meant for the screen underneath.
                ignoring: true,
                child: AnimatedSlide(
                  offset: hidden ? const Offset(0, -1) : Offset.zero,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: hidden ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Material(
                      type: MaterialType.transparency,
                      child: _Bar(
                        restored: restored,
                        height: barHeight,
                        topInset: mq.padding.top,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Content height of the bar, excluding the status bar inset it sits under.
const double _kBarHeight = 30;

class _Bar extends StatelessWidget {
  final bool restored;
  final double height;
  final double topInset;

  const _Bar({
    required this.restored,
    required this.height,
    required this.topInset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = restored ? colors.success : colors.surfaceRaised;
    final foreground = restored ? Colors.white : colors.foreground;

    return Container(
      width: double.infinity,
      height: topInset + height,
      color: background,
      padding: EdgeInsets.only(top: topInset),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            restored ? Icons.cloud_done_rounded : Icons.wifi_off_rounded,
            size: 14.sp,
            color: foreground,
          ),
          SizedBox(width: 8.w),
          Text(
            restored ? 'Back online' : 'No internet connection',
            style: TextStyle(
              color: foreground,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
