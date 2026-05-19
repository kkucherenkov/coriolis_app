import 'package:app_api_client/app_api_client.dart' show ChatMessage;
import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_realtime_service.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered on page init to load conversations + first batch of messages.
final class ChatHydrateRequested extends ChatEvent {
  const ChatHydrateRequested({
    required this.gameSessionId,
    required this.myMembershipId,
  });

  final String gameSessionId;
  final String myMembershipId;

  @override
  List<Object?> get props => [gameSessionId, myMembershipId];
}

/// A new message arrived via Centrifugo.
final class ChatRealtimePostedEvent extends ChatEvent {
  const ChatRealtimePostedEvent(this.message);
  final ChatMessage message;

  @override
  List<Object?> get props => [message.id];
}

/// An edited message arrived via Centrifugo.
final class ChatRealtimeEditedEvent extends ChatEvent {
  const ChatRealtimeEditedEvent(this.message);
  final ChatMessage message;

  @override
  List<Object?> get props => [message.id];
}

/// A soft-delete arrived via Centrifugo.
final class ChatRealtimeDeletedEvent extends ChatEvent {
  const ChatRealtimeDeletedEvent({
    required this.messageId,
    required this.deletedAt,
  });
  final String messageId;
  final DateTime deletedAt;

  @override
  List<Object?> get props => [messageId];
}

/// User pressed Send in the composer.
final class ChatMessageSendRequested extends ChatEvent {
  const ChatMessageSendRequested({
    required this.body,
    this.targetMembershipId,
  });

  final String body;
  final String? targetMembershipId;

  @override
  List<Object?> get props => [body, targetMembershipId];
}

/// User tapped "Edit" on a message — open the banner + prefill composer.
final class ChatEditStarted extends ChatEvent {
  const ChatEditStarted({
    required this.messageId,
    required this.body,
  });

  final String messageId;
  final String body;

  @override
  List<Object?> get props => [messageId, body];
}

/// User tapped "Cancel" in the editing banner.
final class ChatEditCancelled extends ChatEvent {
  const ChatEditCancelled();
}

/// User committed an inline edit.
final class ChatMessageEditRequested extends ChatEvent {
  const ChatMessageEditRequested({
    required this.messageId,
    required this.body,
  });

  final String messageId;
  final String body;

  @override
  List<Object?> get props => [messageId, body];
}

/// User tapped Delete in the action sheet.
final class ChatMessageDeleteRequested extends ChatEvent {
  const ChatMessageDeleteRequested(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

/// User tapped a conversation tab.
final class ChatConversationSelected extends ChatEvent {
  const ChatConversationSelected(this.conversationKey);
  final String conversationKey;

  @override
  List<Object?> get props => [conversationKey];
}

/// + button tapped → create new whisper thread.
final class ChatWhisperOpened extends ChatEvent {
  const ChatWhisperOpened(this.partnerMembershipId);
  final String partnerMembershipId;

  @override
  List<Object?> get props => [partnerMembershipId];
}

/// Close a whisper tab.
final class ChatWhisperClosed extends ChatEvent {
  const ChatWhisperClosed(this.conversationKey);
  final String conversationKey;

  @override
  List<Object?> get props => [conversationKey];
}

/// User confirmed "Block" in the action sheet.
final class ChatMemberBlockRequested extends ChatEvent {
  const ChatMemberBlockRequested(this.targetMembershipId);
  final String targetMembershipId;

  @override
  List<Object?> get props => [targetMembershipId];
}

/// User confirmed "Unblock".
final class ChatMemberUnblockRequested extends ChatEvent {
  const ChatMemberUnblockRequested(this.targetMembershipId);
  final String targetMembershipId;

  @override
  List<Object?> get props => [targetMembershipId];
}

/// Advance read cursor for the active conversation.
final class ChatMarkRead extends ChatEvent {
  const ChatMarkRead({required this.lastReadMessageId});
  final String lastReadMessageId;

  @override
  List<Object?> get props => [lastReadMessageId];
}

/// List scrolled to (or near) bottom — hide the new-messages pill.
final class ChatScrolledToBottom extends ChatEvent {
  const ChatScrolledToBottom();
}

/// List scrolled away from bottom — pill may appear.
final class ChatScrolledAway extends ChatEvent {
  const ChatScrolledAway();
}

/// Composer text changed.
final class ChatComposerChanged extends ChatEvent {
  const ChatComposerChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

/// Forwarded from [ChatRealtimeService.events] stream.
final class ChatRealtimeEventReceived extends ChatEvent {
  const ChatRealtimeEventReceived(this.event);
  final ChatRealtimeEvent event;

  @override
  List<Object?> get props => [event];
}

/// Presence snapshot updated from the `session.<gameSessionId>` channel.
///
/// Dispatched whenever [ChatPresenceService.onlineIds] emits a new set.
final class ChatPresenceUpdated extends ChatEvent {
  const ChatPresenceUpdated(this.ids);

  /// Current set of online membershipIds (immutable snapshot).
  final Set<String> ids;

  @override
  List<Object?> get props => [ids];
}
