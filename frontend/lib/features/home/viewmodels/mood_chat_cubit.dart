import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/exceptions/app_exception.dart';
import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/home/viewmodels/mood_chat_state.dart';

class MoodChatCubit extends Cubit<MoodChatState> {
  final HomeRepository _repository;

  MoodChatCubit(this._repository) : super(const MoodChatState());

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !state.canSend) return;

    // Optimistically show the user's message, then a pending assistant bubble.
    final withUser = [
      ...state.messages,
      MoodMessage(role: MoodMessageRole.user, text: trimmed),
    ];
    emit(state.copyWith(messages: withUser, sending: true));

    try {
      final reply = await _repository.sendMoodMessage(
        sessionId: state.sessionId,
        message: trimmed,
      );
      emit(state.copyWith(
        messages: [
          ...withUser,
          MoodMessage(
            role: MoodMessageRole.assistant,
            text: reply.reply,
            recommendations: reply.recommendations,
          ),
        ],
        sessionId: reply.sessionId,
        sending: false,
        turnsRemaining: reply.turnsRemaining,
      ));
    } catch (e) {
      final ex = ApiClient.parseError(e);
      // Rate-limit / not-configured come back as BackendException with a
      // user-facing message that should end the conversation.
      if (ex is BackendException && ex.code == 'MOOD_CHAT_ERROR') {
        emit(state.copyWith(
          sending: false,
          blockedMessage: ex.userMessage,
        ));
      } else {
        emit(state.copyWith(
          messages: [
            ...withUser,
            const MoodMessage(
              role: MoodMessageRole.assistant,
              text: "Sorry — I couldn't reach the recommender. Try again.",
            ),
          ],
          sending: false,
        ));
      }
    }
  }
}
