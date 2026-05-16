import 'package:app_api_client/app_api_client.dart' show ChatMessage;

/// Centrifugo event fired when a message is posted, edited, or deleted.
sealed class ChatRealtimeEvent {
  const ChatRealtimeEvent();
}

final class ChatRealtimePosted extends ChatRealtimeEvent {
  const ChatRealtimePosted(this.message);
  final ChatMessage message;
}

final class ChatRealtimeEdited extends ChatRealtimeEvent {
  const ChatRealtimeEdited(this.message);
  final ChatMessage message;
}

final class ChatRealtimeDeleted extends ChatRealtimeEvent {
  const ChatRealtimeDeleted({
    required this.messageId,
    required this.deletedAt,
  });
  final String messageId;
  final DateTime deletedAt;
}

/// Port (interface) for the Centrifugo chat subscription.
///
/// Implementation lives in `data/chat_realtime_service_impl.dart`.
abstract interface class ChatRealtimeService {
  /// Stream of events from `session.<id>.chat` and
  /// `session.<id>.member.<myMembershipId>` channels.
  Stream<ChatRealtimeEvent> get events;

  /// Open subscriptions for the given session + membership combo.
  Future<void> start({
    required String gameSessionId,
    required String myMembershipId,
  });

  /// Stop subscriptions and release resources.
  Future<void> stop();

  /// Dispose streams; call when the host widget is permanently destroyed.
  Future<void> dispose();
}
