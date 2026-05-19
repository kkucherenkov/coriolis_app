/// Port (interface) for the Centrifugo presence subscription on a session
/// channel.
///
/// Listens to the `session.<gameSessionId>` Centrifugo channel for presence
/// events. Emits a [Set<String>] of membershipIds currently online — i.e. at
/// least one active Centrifugo client_id whose `connInfo.memberships` contains
/// an entry matching this session.
///
/// Implementation lives in
/// `features/sessions/data/chat_presence_service_impl.dart`.
abstract interface class ChatPresenceService {
  /// Live stream of online membershipIds.
  ///
  /// - Initial value is emitted when the initial `presence()` snapshot is
  ///   fetched after subscribing.
  /// - Each subsequent join / leave event updates the set and emits a new
  ///   snapshot.
  /// - Malformed `connInfo` bytes are silently skipped; the set is still
  ///   emitted.
  Stream<Set<String>> get onlineIds;

  /// Open the subscription and begin emitting presence updates.
  Future<void> start({
    required String gameSessionId,
    required String myMembershipId,
  });

  /// Stop the subscription and clean up internal state.
  Future<void> stop();

  /// Permanently disposes the stream. Call when the owner is destroyed.
  Future<void> dispose();
}
