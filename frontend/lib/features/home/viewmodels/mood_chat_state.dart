import 'package:equatable/equatable.dart';
import 'package:cinemora/features/home/models/similar_item.dart';

enum MoodMessageRole { user, assistant }

class MoodMessage extends Equatable {
  final MoodMessageRole role;
  final String text;
  final List<SimilarItem> recommendations;

  const MoodMessage({
    required this.role,
    required this.text,
    this.recommendations = const [],
  });

  @override
  List<Object?> get props => [role, text, recommendations];
}

class MoodChatState extends Equatable {
  final List<MoodMessage> messages;
  final String? sessionId;
  final bool sending;
  // A rate-limit / not-configured message that ends the conversation.
  final String? blockedMessage;
  final int? turnsRemaining;

  const MoodChatState({
    this.messages = const [],
    this.sessionId,
    this.sending = false,
    this.blockedMessage,
    this.turnsRemaining,
  });

  bool get canSend => !sending && blockedMessage == null;

  MoodChatState copyWith({
    List<MoodMessage>? messages,
    String? sessionId,
    bool? sending,
    Object? blockedMessage = _unset,
    Object? turnsRemaining = _unset,
  }) =>
      MoodChatState(
        messages: messages ?? this.messages,
        sessionId: sessionId ?? this.sessionId,
        sending: sending ?? this.sending,
        blockedMessage: blockedMessage == _unset
            ? this.blockedMessage
            : blockedMessage as String?,
        turnsRemaining: turnsRemaining == _unset
            ? this.turnsRemaining
            : turnsRemaining as int?,
      );

  @override
  List<Object?> get props =>
      [messages, sessionId, sending, blockedMessage, turnsRemaining];
}

const _unset = Object();
