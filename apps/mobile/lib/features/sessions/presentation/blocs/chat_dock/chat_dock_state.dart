import 'package:equatable/equatable.dart';

/// State emitted by [ChatDockCubit].
class ChatDockState extends Equatable {
  const ChatDockState({
    this.isLoading = true,
    this.collapsed = false,
  });

  /// True while the initial `GET /me` hydration is in flight.
  final bool isLoading;

  /// Whether the chat panel dock is collapsed.
  final bool collapsed;

  ChatDockState copyWith({
    bool? isLoading,
    bool? collapsed,
  }) {
    return ChatDockState(
      isLoading: isLoading ?? this.isLoading,
      collapsed: collapsed ?? this.collapsed,
    );
  }

  @override
  List<Object?> get props => [isLoading, collapsed];
}
