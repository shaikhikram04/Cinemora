import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_cubit.dart';
import 'package:cinemora/features/rankings/views/rankings_view.dart';

/// 2-column grid preview of the user's curated ranking lists.
class ProfileRankingGrid extends StatelessWidget {
  final List<RankingList> lists;

  const ProfileRankingGrid({super.key, required this.lists});

  @override
  Widget build(BuildContext context) {
    if (lists.isEmpty) {
      return Container(
        height: 80.h,
        alignment: Alignment.center,
        child: Text(
          'Create ranking lists to see them here.',
          style:
              TextStyle(color: context.colors.mutedSecondary, fontSize: 13.sp),
        ),
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < lists.length; i += 2) {
      if (i > 0) rows.add(SizedBox(height: 12.h));
      rows.add(Row(
        children: [
          Expanded(child: _RankingCard(list: lists[i])),
          SizedBox(width: 12.w),
          if (i + 1 < lists.length)
            Expanded(child: _RankingCard(list: lists[i + 1]))
          else
            const Expanded(child: SizedBox()),
        ],
      ));
    }

    return Column(children: rows);
  }
}

class _RankingCard extends StatelessWidget {
  final RankingList list;

  const _RankingCard({required this.list});

  void _openList(BuildContext context) {
    final rankingsCubit = context.read<RankingsCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: rankingsCubit,
          child: RankingDetailView(list: list),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = list.images.isNotEmpty;
    return GestureDetector(
      onTap: () => _openList(context),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceRaised.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: context.colors.borderStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 108.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                color: list.accent.withValues(alpha: 0.2),
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(list.images.first),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  if (!hasImage)
                    Center(
                      child: Text(
                        list.emoji,
                        style: TextStyle(fontSize: 32.sp),
                      ),
                    ),
                  Positioned(
                    right: 10.w,
                    top: 10.h,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: context.colors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.list_rounded,
                              size: 12.sp,
                              color: context.colors.primaryForeground),
                          SizedBox(width: 4.w),
                          Text(
                            list.count.toString(),
                            style: TextStyle(
                              color: context.colors.primaryForeground,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.foreground,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    list.subtitle.isNotEmpty
                        ? list.subtitle
                        : '${list.count} titles',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.mutedSecondary,
                      fontSize: 11.sp,
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
}
