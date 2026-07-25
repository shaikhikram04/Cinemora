import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';

// Shared building blocks for the settings surface.
//
// The hierarchy here comes from type and space, not from containers. Rows sit
// directly on the background, grouped by a quiet label and separated by inset
// hairlines — no per-group card, no per-row icon chip. The only real container
// on the screen is the destructive zone, so a box actually means "stop".

/// Horizontal inset of a row's content from the edge of the list. Rows carry
/// this themselves so their tap highlight can bleed past the text margin; the
/// list subtracts it from the screen padding so titles still land on the grid.
const double kSettingsRowGutter = 8.0;

/// Width reserved for the leading icon, and the gap after it. Together they
/// define where titles start — and therefore where hairlines are inset to.
const double _kIconSlot = 22.0;
const double _kIconGap = 14.0;

/// Space between one group's last row and the next group's label.
const double kSettingsGroupSpacing = 26.0;

/// Quiet all-caps label that names a group. Carries no padding of its own so
/// it can sit on the row grid here or against a card edge elsewhere — the
/// caller decides the inset.
class SettingsSectionLabel extends StatelessWidget {
  final String label;

  const SettingsSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: context.colors.mutedSecondaryDeep,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
    );
  }
}

/// A group of rows: label on top, hairlines between children, no container.
class SettingsGroup extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const SettingsGroup({super.key, required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: kSettingsRowGutter.w, bottom: 4.h),
          child: SettingsSectionLabel(label: label),
        ),
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const SettingsHairline(),
        ],
      ],
    );
  }
}

/// Hairline inset past the icon slot so it starts where the title starts.
class SettingsHairline extends StatelessWidget {
  const SettingsHairline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: (kSettingsRowGutter + _kIconSlot + _kIconGap).w),
      height: 0.5,
      color: context.colors.border,
    );
  }
}

/// A single tappable settings row.
///
/// [value] is for showing the setting's current state ("Dark", "3 lists") — it
/// is not a place to restate the title. Rows with nothing to report stay on one
/// line, which is what keeps the list calm.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        highlightColor: context.colors.surfaceRaised.withValues(alpha: 0.5),
        splashColor: context.colors.surfaceRaised.withValues(alpha: 0.3),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: kSettingsRowGutter.w,
            vertical: 15.h,
          ),
          child: Row(
            children: [
              SizedBox(
                width: _kIconSlot.w,
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: context.colors.mutedSecondary,
                ),
              ),
              SizedBox(width: _kIconGap.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (value != null) ...[
                Text(
                  value!,
                  style: TextStyle(
                    color: context.colors.mutedSecondary,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 6.w),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: context.colors.mutedSecondaryHeader,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The one boxed element on the surface. Reserved for destructive actions so
/// the container itself carries the warning.
class SettingsDangerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SettingsDangerButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        highlightColor: context.colors.accentRed.withValues(alpha: 0.10),
        splashColor: context.colors.accentRed.withValues(alpha: 0.06),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: context.colors.accentRed.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.sp, color: context.colors.accentRed),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: context.colors.accentRed,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
