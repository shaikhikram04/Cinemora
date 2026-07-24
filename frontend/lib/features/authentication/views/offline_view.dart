import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/common/widgets/states/w_error_state.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/viewmodels/network_status_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';

/// Shown only when there is a stored session we can neither verify nor fall
/// back on — a first launch with no network, essentially. Everyone else with a
/// session goes straight to Home on their cached identity.
class OfflineView extends StatelessWidget {
  const OfflineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      // Retries itself the moment the network comes back, so the user isn't
      // left tapping a button to find out.
      body: BlocListener<NetworkStatusCubit, NetworkStatus>(
        listenWhen: (prev, curr) => curr == NetworkStatus.restored,
        listener: (context, _) =>
            context.read<AppAuthCubit>().checkAuthStatus(),
        child: WErrorState.fullScreen(
          message: "You're offline. Connect to the internet to continue.",
          onRetry: () {
            context.read<NetworkStatusCubit>().checkNow();
            context.read<AppAuthCubit>().checkAuthStatus();
          },
        ),
      ),
    );
  }
}
