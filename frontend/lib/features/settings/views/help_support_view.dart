import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/settings/widgets/settings_top_bar.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  static const _faqs = [
    _FaqItem(
      question: 'How do I add a title to my collection?',
      answer:
          'Search for a movie, series, or anime and tap the bookmark icon on its detail page. It will appear in your Library.',
    ),
    _FaqItem(
      question: 'How do I create a ranking list?',
      answer:
          'Go to the Rankings tab and tap "New List". Add a title, choose your items, and drag to reorder them.',
    ),
    _FaqItem(
      question: 'Can I make my profile private?',
      answer:
          'Yes. Go to Settings → Privacy & Security and switch to "Private Profile". Your data will only be visible to you.',
    ),
    _FaqItem(
      question: 'How are achievement badges earned?',
      answer:
          'Badges are unlocked automatically as you reach milestones — watching titles, creating lists, rating content, and more.',
    ),
    _FaqItem(
      question: 'How do I export my collection?',
      answer:
          'Go to Settings → Data & Library → Export Data. Choose a format (CSV or JSON) and your data will download.',
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
                  WSizes.screenPadding.w,
                  16.h,
                  WSizes.screenPadding.w,
                  100.h,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.bug_report_outlined,
                          color: context.colors.accentRed,
                          label: 'Report Bug',
                          onTap: () {},
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.lightbulb_outline_rounded,
                          color: context.colors.chartYellow,
                          label: 'Feature Request',
                          onTap: () {},
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.star_outline_rounded,
                          color: context.colors.chartGreen,
                          label: 'Rate App',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28.h),

                  // Contact
                  _SectionLabel(label: 'GET IN TOUCH'),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          context.colors.surfaceRaised.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: context.colors.borderStrong),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Column(
                        children: [
                          _ContactRow(
                            icon: Icons.support_agent_rounded,
                            iconColor: context.colors.accentPurple,
                            title: 'Contact Support',
                            subtitle: 'Avg response time: 24 hours',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // FAQ
                  _SectionLabel(label: 'FREQUENTLY ASKED'),
                  SizedBox(height: 10.h),
                  _FaqSection(items: _faqs),
                  SizedBox(height: 28.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.mutedSecondaryDeep,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Quick action card ────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22.sp, color: color),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Contact row ──────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 19.sp, color: iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.colors.foreground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: context.colors.mutedSecondary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_outward_rounded,
                  size: 16.sp, color: context.colors.mutedSecondaryHeader),
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
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 14.h),
                      child: Row(
                        children: [
                          Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: context.colors.accentPurple
                                  .withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(9.r),
                            ),
                            child: Icon(
                              Icons.question_mark_rounded,
                              size: 14.sp,
                              color: context.colors.accentPurple,
                            ),
                          ),
                          SizedBox(width: 12.w),
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
                    padding: EdgeInsets.fromLTRB(54.w, 0, 14.w, 14.h),
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
                    margin: EdgeInsets.only(left: 14.w),
                    height: 0.5,
                    color: context.colors.borderStrong,
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
