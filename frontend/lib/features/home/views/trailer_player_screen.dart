import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:cinemora/core/constants/sizes.dart';

class TrailerPlayerScreen extends StatefulWidget {
  final String trailerKey;
  final String title;

  const TrailerPlayerScreen({
    super.key,
    required this.trailerKey,
    required this.title,
  });

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  late final YoutubePlayerController _controller;
  bool _isFullScreen = false;

  // No YouTube error code is recoverable inside the embed: 101/150 mean the
  // uploader disabled off-site playback, 100 means the video is gone, 1/2/5
  // mean the id or embed is bad, and 105 is YouTube's catch-all. The trailer is
  // usually still watchable in YouTube proper, so we hand it off there instead
  // of leaving the user on a dead black player.
  bool _handledError = false;
  bool _launchFailed = false;
  int? _errorCode;

  Uri get _youtubeUri =>
      Uri.parse('https://www.youtube.com/watch?v=${widget.trailerKey}');

  @override
  void initState() {
    super.initState();
    // Unlock landscape so the user can rotate the phone to watch in widescreen.
    // Restored to portrait-only in dispose().
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller = YoutubePlayerController(
      initialVideoId: widget.trailerKey,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    final value = _controller.value;
    if (value.isFullScreen != _isFullScreen) {
      setState(() => _isFullScreen = value.isFullScreen);
    }
    if (value.hasError && !_handledError) {
      _handledError = true;
      _handlePlaybackError(value.errorCode);
    }
  }

  Future<void> _handlePlaybackError(int errorCode) async {
    _errorCode = errorCode;
    if (_isFullScreen) _controller.toggleFullScreenMode();
    final opened = await _openInYouTube();
    if (!mounted) return;
    if (opened) {
      // Trailer is playing in YouTube now; this dead player has nothing to show.
      Navigator.of(context).pop();
    } else {
      setState(() => _launchFailed = true);
    }
  }

  Future<bool> _openInYouTube() async {
    if (!await canLaunchUrl(_youtubeUri)) return false;
    return launchUrl(_youtubeUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _retryInYouTube() async {
    final opened = await _openInYouTube();
    if (opened && mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Intercept back button while the player's overlay fullscreen is active.
    // First press exits fullscreen; second press pops the route normally.
    return PopScope(
      canPop: !_isFullScreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _controller.toggleFullScreenMode();
      },
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: const ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
        ),
        builder: (context, player) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // The player stays mounted under the fallback so the controller keeps
          // a live webview; the fallback just covers it opaquely.
          body: Stack(
            fit: StackFit.expand,
            children: [
              Center(child: player),
              if (_launchFailed) _buildLaunchFailedFallback(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaunchFailedFallback() {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenPaddingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: AppSizes.icon32,
              ),
              const SizedBox(height: AppSizes.space12),
              Text(
                "This trailer can't be played here"
                '${_errorCode == null ? '' : ' (error $_errorCode)'}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.fontSize16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              const Text(
                'Watch it on YouTube instead.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: AppSizes.fontSize14,
                ),
              ),
              const SizedBox(height: AppSizes.space24),
              FilledButton.icon(
                onPressed: _retryInYouTube,
                icon: const Icon(Icons.open_in_new_rounded,
                    size: AppSizes.icon18),
                label: const Text('Open in YouTube'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
