import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/viewmodels/network_status_cubit.dart';

/// Runs [onReconnect] when the network comes back, so a screen sitting on a
/// failure state recovers on its own instead of waiting for the user to notice
/// and tap Retry.
///
/// Pass the same callback the Retry button uses. Guard inside the callback if
/// the screen should only re-fetch when it actually failed — this fires on
/// every reconnect, not only after an error.
class OnReconnect extends StatelessWidget {
  final VoidCallback onReconnect;
  final Widget child;

  const OnReconnect({
    super.key,
    required this.onReconnect,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkStatusCubit, NetworkStatus>(
      listenWhen: (prev, curr) => curr == NetworkStatus.restored,
      listener: (_, __) => onReconnect(),
      child: child,
    );
  }
}
