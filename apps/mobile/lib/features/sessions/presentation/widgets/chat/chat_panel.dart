import 'package:app_api_client/app_api_client.dart' show ChatMessageKind;
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_bloc.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_event.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/features/sessions/presentation/widgets/chat/chat_composer.dart';
import 'package:coriolis_companion/features/sessions/presentation/widgets/chat/chat_message.dart';
import 'package:coriolis_companion/features/sessions/presentation/widgets/chat/chat_tab_strip.dart';
import 'package:coriolis_companion/features/sessions/presentation/widgets/chat/whisper_picker_sheet.dart';

/// Primary chat surface widget.
///
/// Wraps a [BlocBuilder<ChatBloc, ChatState>] and composes:
/// - [ChatTabStrip] (tab navigation)
/// - scrollable message list (auto-scroll + 80px threshold)
/// - [ChatComposer] (input bar)
///
/// The [ChatBloc] must be provided by an ancestor [BlocProvider].
class ChatPanel extends StatefulWidget {
  const ChatPanel({
    super.key,
    /// All non-blocked session members available for whispering.
    required this.availableMembers,
    required this.myMembershipId,
  });

  final List<WhisperPickerMember> availableMembers;
  final String myMembershipId;

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _scrollController = ScrollController();
  final _composerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _composerController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bloc = context.read<ChatBloc>();
    final pos = _scrollController.position;
    final atBottom = pos.pixels >= pos.maxScrollExtent - 80;
    if (atBottom) {
      bloc.add(const ChatScrolledToBottom());
    } else {
      bloc.add(const ChatScrolledAway());
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: AppDuration.dDefault,
      curve: AppEasing.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatError) {
          return Center(
            child: Text(
              state.message,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.stateCrimsonBright,
              ),
            ),
          );
        }

        if (state is! ChatReady) {
          return const SizedBox.shrink();
        }

        // Keep composer in sync if bloc cleared it after send.
        if (_composerController.text != state.composerValue) {
          _composerController.text = state.composerValue;
          _composerController.selection = TextSelection.fromPosition(
            TextPosition(offset: state.composerValue.length),
          );
        }

        final conv = state.activeConversation;
        final messages = conv?.messages ?? const [];

        // Auto-scroll when new messages arrive and already at bottom.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.atBottom && _scrollController.hasClients) {
            _scrollToBottom();
          }
        });

        // Filter available members for whisper picker (exclude blocked).
        final pickable = widget.availableMembers
            .where((m) => !state.blockedByMe.contains(m.membershipId))
            .where((m) => m.membershipId != widget.myMembershipId)
            .toList();

        // Active conversation placeholder text.
        final isWhisper = state.activeKey != 'broadcast';
        final partnerName = conv?.summary.partnerDisplayName;
        final placeholder = isWhisper && partnerName != null
            ? 'Whisper to $partnerName…'
            : 'Message everyone…';

        return Column(
          children: [
            ChatTabStrip(
              conversations: state.conversationsList,
              activeKey: state.activeKey,
              openWhisperKeys: state.openWhisperKeys,
              onlineMembershipIds: state.onlineMembershipIds,
              onSelect: (key) =>
                  context.read<ChatBloc>().add(ChatConversationSelected(key)),
              onAddWhisper: () => showWhisperPickerSheet(
                context: context,
                members: pickable,
                onPick: (m) => context
                    .read<ChatBloc>()
                    .add(ChatWhisperOpened(m.membershipId)),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    key: const Key('message_list'),
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s2,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isDeleted = msg.deletedAt != null;
                      final isSystem =
                          msg.kind == ChatMessageKind.system;
                      final isAuthor =
                          msg.authorMembershipId == widget.myMembershipId;
                      final isWhisperMsg =
                          msg.targetMembershipId != null;

                      ChatMessageVariant variant;
                      if (isSystem) {
                        variant = ChatMessageVariant.system;
                      } else if (isWhisperMsg) {
                        variant = ChatMessageVariant.whisper;
                      } else if (isAuthor) {
                        variant = ChatMessageVariant.broadcastAuthor;
                      } else {
                        variant = ChatMessageVariant.broadcastOther;
                      }

                      return ChatMessageWidget(
                        key: Key('msg_${msg.id}'),
                        messageId: msg.id,
                        variant: variant,
                        body: msg.body ?? '',
                        authorName: msg.authorDisplayName,
                        isEdited: msg.editedAt != null,
                        isDeleted: isDeleted,
                        ownByMe: isAuthor,
                        canEdit: isAuthor && !isDeleted && !isSystem,
                        canDelete: isAuthor && !isDeleted && !isSystem,
                        canBlock: !isAuthor && !isSystem,
                        onDelete: () => context.read<ChatBloc>().add(
                              ChatMessageDeleteRequested(msg.id),
                            ),
                        onEdit: () => context.read<ChatBloc>().add(
                              ChatEditStarted(
                                messageId: msg.id,
                                body: msg.body ?? '',
                              ),
                            ),
                        onBlock: () => context.read<ChatBloc>().add(
                              ChatMemberBlockRequested(
                                msg.authorMembershipId ?? '',
                              ),
                            ),
                      );
                    },
                  ),
                  if (!state.atBottom && state.totalUnreadCount > 0)
                    Positioned(
                      bottom: AppSpacing.s3,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _scrollToBottom,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s4,
                              vertical: AppSpacing.s2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandBrassDeep,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              '${state.totalUnreadCount} new messages ↓',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textOnBrass,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ChatComposer(
              controller: _composerController,
              value: state.composerValue,
              placeholder: placeholder,
              isEditing: state.editingMessageId != null,
              editingPreview: state.editingPreview,
              editingLabel: t.chat.composer.editing,
              cancelEditLabel: t.chat.composer.editing_cancel,
              sendTooltip: t.chat.composer.send,
              saveTooltip: t.chat.composer.save,
              onCancelEdit: () =>
                  context.read<ChatBloc>().add(const ChatEditCancelled()),
              onChanged: (v) =>
                  context.read<ChatBloc>().add(ChatComposerChanged(v)),
              onSubmit: () {
                final text = state.composerValue.trim();
                if (text.isEmpty) return;
                final editingId = state.editingMessageId;
                if (editingId != null) {
                  context.read<ChatBloc>().add(ChatMessageEditRequested(
                        messageId: editingId,
                        body: text,
                      ));
                  return;
                }
                context.read<ChatBloc>().add(ChatMessageSendRequested(
                      body: text,
                      targetMembershipId: state.activeKey == 'broadcast'
                          ? null
                          : state.activeKey,
                    ));
              },
            ),
          ],
        );
      },
    );
  }
}
