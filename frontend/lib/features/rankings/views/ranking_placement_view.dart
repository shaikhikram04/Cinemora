import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';
import 'package:cinemora/features/rankings/viewmodels/ranking_placement_cubit.dart';
import 'package:cinemora/features/rankings/viewmodels/ranking_placement_state.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_cubit.dart';
import 'package:cinemora/features/rankings/views/rankings_view.dart';

// ─── Public entry point ───────────────────────────────────────────────────────

class RankingPlacementView extends StatelessWidget {
  final RankingList list;
  final RankingEntry newEntry;

  const RankingPlacementView({
    super.key,
    required this.list,
    required this.newEntry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RankingPlacementCubit(
        entries: list.entries,
        newEntry: newEntry,
      ),
      child: _PlacementContent(list: list),
    );
  }
}

// ─── Root scaffold ────────────────────────────────────────────────────────────

class _PlacementContent extends StatelessWidget {
  final RankingList list;
  const _PlacementContent({required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: BlocBuilder<RankingPlacementCubit, RankingPlacementState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
              child: state.status == RankingPlacementStatus.placed
                  ? _PlacedView(
                      key: const ValueKey('placed'), state: state, list: list)
                  : _ComparingView(
                      key: const ValueKey('comparing'),
                      state: state,
                      list: list),
            );
          },
        ),
      ),
    );
  }
}

// ─── Comparing view ───────────────────────────────────────────────────────────

class _ComparingView extends StatelessWidget {
  final RankingPlacementState state;
  final RankingList list;

  const _ComparingView({super.key, required this.state, required this.list});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RankingPlacementCubit>();
    final progress = state.maxSteps > 0
        ? (state.stepsTaken / state.maxSteps).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        _Header(list: list),
        SizedBox(height: 14.h),
        _ProgressBar(
          step: state.stepsTaken + 1,
          maxSteps: state.maxSteps,
          progress: progress,
          accent: list.accent,
        ),
        SizedBox(height: 20.h),
        Text(
          'Which deserves a higher rank?',
          style: TextStyle(
            color: context.colors.foreground,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _BattleCard(
                    entry: state.newEntry,
                    isNew: true,
                    accent: list.accent,
                    onTap: cubit.chooseNew,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: list.accent.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: list.accent.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: list.accent,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            inherit: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _BattleCard(
                    entry: state.currentComparison,
                    isNew: false,
                    accent: list.accent,
                    onTap: cubit.chooseExisting,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: cubit.chooseTie,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              WSizes.screenPadding.w,
              0,
              WSizes.screenPadding.w,
              24.h,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: context.colors.surfaceChip,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: context.colors.borderStrong),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows_rounded,
                    color: context.colors.mutedSecondary,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Too close to call',
                    style: TextStyle(
                      color: context.colors.mutedSecondary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Placed / confirmation view ───────────────────────────────────────────────

class _PlacedView extends StatelessWidget {
  final RankingPlacementState state;
  final RankingList list;

  const _PlacedView({super.key, required this.state, required this.list});

  @override
  Widget build(BuildContext context) {
    final rank = state.finalPosition ?? 1;

    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () {
              context.read<RankingsCubit>().updateListEntries(
                    list.id,
                    state.entries,
                  );
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 12.h, 16.w, 0),
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: context.colors.surfaceChip,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.borderStrong),
                ),
                child: Icon(
                  Icons.close,
                  size: 15.sp,
                  color: context.colors.mutedSecondary,
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        // List emoji circle
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: list.accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
                color: list.accent.withValues(alpha: 0.22), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: list.accent.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 2)
            ],
          ),
          child: Center(
            child: Text(
              list.emoji,
              style: TextStyle(fontSize: 32.sp, inherit: false),
            ),
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          'Ranked!',
          style: TextStyle(
            color: context.colors.foreground,
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 6.h),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 14.sp,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(
                text: state.newEntry.title,
                style: TextStyle(
                  color: context.colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: ' is now'),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        TweenAnimationBuilder<double>(
          key: ValueKey(rank),
          tween: Tween(begin: 0.4, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Text(
            '#$rank',
            style: TextStyle(
              color: list.accent,
              fontWeight: FontWeight.w900,
              fontSize: 48.sp,
              letterSpacing: -1.5,
              inherit: false,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 14.sp,
              fontFamily: 'Inter',
            ),
            children: [
              const TextSpan(text: 'in '),
              TextSpan(
                text: '${list.emoji} ${list.title}',
                style: TextStyle(
                  color: context.colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 28.h),
        _RankingPreview(state: state, list: list),
        const Spacer(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            WSizes.screenPadding.w,
            0,
            WSizes.screenPadding.w,
            24.h,
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  final cubit = context.read<RankingsCubit>();
                  cubit.updateListEntries(list.id, state.entries);
                  final updatedList =
                      cubit.state.lists.firstWhere((l) => l.id == list.id);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: RankingDetailView(list: updatedList),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        list.accent,
                        list.accent.withValues(alpha: 0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Text(
                      'View Full Ranking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () {
                  context.read<RankingsCubit>().updateListEntries(
                        list.id,
                        state.entries,
                      );
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceChip,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: context.colors.borderStrong),
                  ),
                  child: Center(
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: context.colors.foreground,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Ranking preview (top entries around placed position) ─────────────────────

class _RankingPreview extends StatelessWidget {
  final RankingPlacementState state;
  final RankingList list;

  const _RankingPreview({required this.state, required this.list});

  @override
  Widget build(BuildContext context) {
    final entries = state.entries;
    final highlightIndex = (state.finalPosition ?? 1) - 1;
    final start = (highlightIndex - 1)
        .clamp(0, (entries.length - 3).clamp(0, entries.length));
    final end = (start + 3).clamp(0, entries.length);
    final visible = entries.sublist(start, end);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceChip.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.borderStrong),
        ),
        child: Column(
          children: List.generate(visible.length, (i) {
            final entry = visible[i];
            final rank = start + i + 1;
            final isHighlighted = rank == state.finalPosition;
            final isFirst = i == 0;
            final isLast = i == visible.length - 1;

            return Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? list.accent.withValues(alpha: 0.09)
                        : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: isFirst ? Radius.circular(16.r) : Radius.zero,
                      topRight: isFirst ? Radius.circular(16.r) : Radius.zero,
                      bottomLeft: isLast ? Radius.circular(16.r) : Radius.zero,
                      bottomRight: isLast ? Radius.circular(16.r) : Radius.zero,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 34.w,
                        child: Text(
                          rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
                          style: TextStyle(
                            fontSize: rank <= 3 ? 18.sp : 13.sp,
                            fontWeight: FontWeight.w800,
                            color: isHighlighted
                                ? list.accent
                                : context.colors.mutedSecondaryDeep,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          entry.image,
                          width: 36.w,
                          height: 50.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 36.w,
                            height: 50.h,
                            color: context.colors.surfaceMuted,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          entry.title,
                          style: TextStyle(
                            color: isHighlighted
                                ? context.colors.foreground
                                : context.colors.mutedSecondary,
                            fontSize: 13.sp,
                            fontWeight: isHighlighted
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isHighlighted) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: list.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: list.accent,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    color: context.colors.borderStrong,
                    indent: 12.w,
                    endIndent: 12.w,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─── Battle card ──────────────────────────────────────────────────────────────

class _BattleCard extends StatefulWidget {
  final RankingEntry entry;
  final bool isNew;
  final Color accent;
  final VoidCallback onTap;

  const _BattleCard({
    required this.entry,
    required this.isNew,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_BattleCard> createState() => _BattleCardState();
}

class _BattleCardState extends State<_BattleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: context.colors.surfaceChip,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: _pressed
                  ? widget.accent
                  : widget.isNew
                      ? widget.accent.withValues(alpha: 0.45)
                      : context.colors.borderStrong,
              width: _pressed ? 2.0 : 1.2,
            ),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: widget.accent.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge row
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 8.h),
                child: widget.isNew
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: widget.accent,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          widget.entry.type.toUpperCase(),
                          style: TextStyle(
                            color: context.colors.mutedSecondary,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
              ),
              // Poster
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.network(
                    widget.entry.image,
                    height: 176.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 176.h,
                      color: context.colors.surfaceMuted,
                      child: Icon(
                        Icons.movie_outlined,
                        color: context.colors.mutedForeground,
                        size: 32.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Title + meta
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.title,
                      style: TextStyle(
                        color: context.colors.foreground,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${widget.entry.year}  ·  ★ ${widget.entry.rating}',
                      style: TextStyle(
                        color: context.colors.mutedSecondary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final RankingList list;
  const _Header({required this.list});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        WSizes.screenPadding.w,
        12.h,
        WSizes.screenPadding.w,
        0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: context.colors.surfaceChip,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: context.colors.borderStrong),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 18.sp,
                color: context.colors.foreground,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${list.emoji}  ${list.title}',
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  list.entries.isEmpty
                      ? 'Your first entry in this list'
                      : 'Comparing against ${list.entries.length} ${list.entries.length == 1 ? 'title' : 'titles'}',
                  style: TextStyle(
                    color: context.colors.mutedSecondary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int step;
  final int maxSteps;
  final double progress;
  final Color accent;

  const _ProgressBar({
    required this.step,
    required this.maxSteps,
    required this.progress,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $step',
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '~$maxSteps steps',
                style: TextStyle(
                  color: context.colors.mutedSecondaryDeep,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.colors.surfaceChip,
              valueColor: AlwaysStoppedAnimation(accent),
              minHeight: 4.h,
            ),
          ),
        ],
      ),
    );
  }
}
