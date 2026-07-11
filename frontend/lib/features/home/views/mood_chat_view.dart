import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/home/models/similar_item.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/viewmodels/mood_chat_cubit.dart';
import 'package:cinemora/features/home/viewmodels/mood_chat_state.dart';

// Optional starter mood (e.g. tapped from the Home mood card) sent as the
// opening message so the conversation begins immediately.
class MoodChatArgs {
  final String? starter;
  const MoodChatArgs({this.starter});
}

class MoodChatView extends StatelessWidget {
  final MoodChatArgs? args;
  const MoodChatView({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = MoodChatCubit(ctx.read<HomeRepository>());
        final starter = args?.starter?.trim();
        if (starter != null && starter.isNotEmpty) cubit.send(starter);
        return cubit;
      },
      child: const _MoodChatContent(),
    );
  }
}

class _MoodChatContent extends StatefulWidget {
  const _MoodChatContent();

  @override
  State<_MoodChatContent> createState() => _MoodChatContentState();
}

class _MoodChatContentState extends State<_MoodChatContent> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<MoodChatCubit>().send(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  context.colors.accentPurple,
                  context.colors.accentPink,
                ]),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 16.sp, color: Colors.white),
            ),
            SizedBox(width: 10.w),
            Text(
              'Mood Picker',
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<MoodChatCubit, MoodChatState>(
        listener: (_, __) => _scrollToBottom(),
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: state.messages.isEmpty && state.blockedMessage == null
                    ? const _EmptyState()
                    : ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                        children: [
                          for (final m in state.messages) _Bubble(message: m),
                          if (state.sending) const _TypingBubble(),
                          if (state.blockedMessage != null)
                            _Notice(text: state.blockedMessage!),
                        ],
                      ),
              ),
              _Composer(
                controller: _controller,
                enabled: state.canSend,
                onSend: _submit,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 44.sp, color: context.colors.accentPurple),
            SizedBox(height: 14.h),
            Text(
              "What's your vibe tonight?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tell me how you feel or what you’re in the mood for, and I’ll find something to watch.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.mutedSecondaryDeep,
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final MoodMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MoodMessageRole.user;
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (message.text.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            constraints: BoxConstraints(maxWidth: 280.w),
            decoration: BoxDecoration(
              color: isUser
                  ? context.colors.accentRed
                  : context.colors.surfaceMuted,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
                bottomRight: Radius.circular(isUser ? 4.r : 16.r),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : context.colors.foreground,
                fontSize: 14.sp,
                height: 1.35,
              ),
            ),
          ),
        if (message.recommendations.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: SizedBox(
              height: 210.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: message.recommendations.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (_, i) =>
                    _RecCard(item: message.recommendations[i]),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecCard extends StatelessWidget {
  final SimilarItem item;
  const _RecCard({required this.item});

  void _open(BuildContext context) {
    final type = CinemaType.fromJson(item.cinemaType);
    if (type == CinemaType.movie) {
      context.push(
        AppRoutes.movieDetails,
        extra: MovieRouteArgs(
          title: item.title,
          image: item.posterUrl,
          rating: item.ratingDisplay,
          id: item.sourceId,
        ),
      );
    } else {
      context.push(
        AppRoutes.seriesDetails,
        extra: SeriesRouteArgs(
          title: item.title,
          image: item.posterUrl,
          rating: item.ratingDisplay,
          id: item.sourceId,
          source: type == CinemaType.anime ? 'jikan' : 'tmdb',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: SizedBox(
        width: 120.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: SizedBox(
                width: 120.w,
                height: 160.h,
                child: item.posterUrl.isEmpty
                    ? Container(color: context.colors.surfaceMuted)
                    : Image.network(
                        item.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: context.colors.surfaceMuted),
                      ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Icon(Icons.star_rounded,
                    size: 12.sp, color: context.colors.tertiary),
                SizedBox(width: 2.w),
                Text(
                  item.ratingDisplay,
                  style: TextStyle(
                    color: context.colors.mutedSecondary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: context.colors.surfaceMuted,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SizedBox(
          width: 34.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              3,
              (_) => Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: context.colors.mutedForeground,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.colors.surfaceBorderAlt),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18.sp, color: context.colors.mutedForeground),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.colors.mutedSecondaryDeep,
                fontSize: 13.sp,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
        decoration: BoxDecoration(
          color: context.colors.background,
          border: Border(
            top: BorderSide(color: context.colors.surfaceBorderAlt),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: TextStyle(
                  color: context.colors.foreground,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  hintText: enabled ? 'Describe your mood…' : 'Chat ended',
                  hintStyle: TextStyle(
                    color: context.colors.mutedForeground,
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceMuted,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: enabled ? onSend : null,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: enabled
                      ? context.colors.accentRed
                      : context.colors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color:
                      enabled ? Colors.white : context.colors.mutedForeground,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
