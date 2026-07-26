import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/constants/support_contact.dart';
import 'package:cinemora/features/settings/widgets/settings_top_bar.dart';
import 'package:cinemora/features/settings/widgets/settings_ui.dart';

// Every answer here describes behaviour that exists. The previous set was
// written against a design mockup and told users about a private-profile
// setting, achievement badges and a working export — none of which the app
// has. If a feature isn't shipped, it doesn't get an FAQ entry.

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  static const _faqs = [
    _FaqItem(
      question: 'How do I add a title to my collection?',
      answer:
          'Search for a movie, series, or anime and tap the bookmark icon on '
          'its detail page. It will appear in your Library.',
    ),
    _FaqItem(
      question: 'How do I create a ranking list?',
      answer:
          'Go to the Rankings tab and tap "New List". Add a title, choose your '
          'items, and drag to reorder them.',
    ),
    _FaqItem(
      question: 'Why haven’t I been notified about a release?',
      answer:
          'Release alerts always appear in your in-app inbox. Push is separate: '
          'it needs both the switches in Settings → Notifications turned on and '
          'notification permission granted for Cinemora in your device '
          'settings. The release check also runs once a day, so a title that '
          'just came out may not reach your phone until the next evening.',
    ),
    _FaqItem(
      question: 'How is my Pick of the Week chosen?',
      answer:
          'It’s drawn from what’s in your library and how you’ve ranked things, '
          'the same signals behind the "Because You Ranked" and "Critically '
          'Acclaimed" rows. Until there’s enough history to go on, it falls '
          'back to what’s trending.',
    ),
    _FaqItem(
      question: 'I can’t decide what to watch.',
      answer:
          'Open your Library and tap Shuffle — it picks a title at random from '
          'your watchlist. It stays disabled until there’s something on the '
          'watchlist to pick from.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTopBar(title: 'Help & Support'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  (WSizes.screenPadding - kSettingsRowGutter).w,
                  20.h,
                  (WSizes.screenPadding - kSettingsRowGutter).w,
                  100.h,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: kSettingsRowGutter.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.bug_report_outlined,
                            color: context.colors.accentRed,
                            label: 'Report Bug',
                            onTap: () => _emailSupport(
                              context,
                              'Bug report',
                              'What happened, and what did you expect instead?',
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.lightbulb_outline_rounded,
                            color: context.colors.chartYellow,
                            label: 'Feature Request',
                            onTap: () => _emailSupport(
                              context,
                              'Feature request',
                              'What would you like Cinemora to do?',
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.star_outline_rounded,
                            color: context.colors.chartGreen,
                            label: 'Rate App',
                            onTap: () => _rateApp(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  SettingsGroup(
                    label: 'GET IN TOUCH',
                    children: [
                      SettingsRow(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email Support',
                        onTap: () => _emailSupport(
                          context,
                          'Cinemora support',
                          'How can we help?',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: kSettingsGroupSpacing.h),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: kSettingsRowGutter.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SettingsSectionLabel(label: 'FREQUENTLY ASKED'),
                        SizedBox(height: 10.h),
                        const _FaqSection(items: _faqs),
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

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Opens the user's mail composer with the build already described, so a bug
  /// report arrives with the version attached instead of "it doesn't work".
  Future<void> _emailSupport(
    BuildContext context,
    String subject,
    String prompt,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final info = await PackageInfo.fromPlatform();

    final body = '$prompt\n\n\n'
        '—————\n'
        'Cinemora ${info.version} (${info.buildNumber})\n'
        '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';

    final uri = Uri(
      scheme: 'mailto',
      path: SupportContact.email,
      // Built by hand rather than with queryParameters, which encodes spaces
      // as '+' and leaves some mail clients showing them literally.
      query: _encodeQuery({'subject': subject, 'body': body}),
    );

    _launch(messenger, uri, 'No email app is set up on this device.');
  }

  Future<void> _rateApp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final info = await PackageInfo.fromPlatform();

    final String? url = Platform.isAndroid
        ? SupportContact.playStoreUrl(info.packageName)
        : SupportContact.appStoreId.isEmpty
            ? null
            : SupportContact.appStoreUrl();

    if (url == null) {
      _showMessage(messenger, 'Cinemora isn’t on the App Store yet.');
      return;
    }

    _launch(messenger, Uri.parse(url), 'Couldn’t open the store listing.');
  }

  static String _encodeQuery(Map<String, String> params) => params.entries
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
      .join('&');

  static Future<void> _launch(
    ScaffoldMessengerState messenger,
    Uri uri,
    String onFailure,
  ) async {
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) _showMessage(messenger, onFailure);
    } catch (_) {
      // No handler registered for the scheme — same outcome as a failed launch.
      _showMessage(messenger, onFailure);
    }
  }

  static void _showMessage(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14.sp)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}

// ── Quick action card ────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.color,
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
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 6.w),
          decoration: BoxDecoration(
            // Same surface as every other card on the settings screens; only
            // the icon carries the action's colour.
            color: context.colors.surfaceRaised.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22.sp, color: color),
              SizedBox(height: 8.h),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.foreground,
                  fontSize: 11.sp,
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

// ── FAQ ──────────────────────────────────────────────────────────────────────

class _FaqSection extends StatefulWidget {
  final List<_FaqItem> items;

  const _FaqSection({required this.items});

  @override
  State<_FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<_FaqSection> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: List.generate(widget.items.length, (i) {
            final item = widget.items[i];
            final expanded = _expandedIndex == i;

            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(
                      () => _expandedIndex = expanded ? null : i,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.question,
                              style: TextStyle(
                                color: context.colors.foreground,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          AnimatedRotation(
                            turns: expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18.sp,
                              color: context.colors.mutedSecondaryHeader,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    // Aligned to the question above it, now that the question
                    // has no icon to indent past.
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                    child: Text(
                      item.answer,
                      style: TextStyle(
                        color: context.colors.mutedSecondarySoft,
                        fontSize: 12.sp,
                        height: 1.5,
                      ),
                    ),
                  ),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
                if (i < widget.items.length - 1)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 14.w),
                    height: 0.5,
                    color: context.colors.border,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
