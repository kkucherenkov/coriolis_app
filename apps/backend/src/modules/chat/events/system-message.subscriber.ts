/**
 * WHY this file exists:
 * Translates membership-lifecycle and dice-push domain events into broadcast
 * system messages in the session chat. Each subscriber is a single-purpose
 * @EventsHandler so they can be tested in isolation without the full module.
 *
 * Denormalisation strategy:
 *  - MemberJoined/Left/Kicked: MembershipEvent carries only membershipId.
 *    We do a single MEMBERSHIP_REPO.findById lookup to resolve displayName.
 *    MEMBERSHIP_REPO is already available in ChatModule via MembershipsModule.
 *  - RollPushed: the event carries characterId + hits. CHARACTER_REPO.findActiveById
 *    resolves characterName. pushedCount / dpDelta are not on the event;
 *    systemParams carries { characterName, hits } instead — see report.
 *
 * All system messages are broadcast (targetMembershipId is always null).
 */
import { Inject } from '@nestjs/common';
import { CommandBus, EventsHandler, IEventHandler } from '@nestjs/cqrs';

import { CHARACTER_REPO, type ICharacterRepo } from '../../characters/domain/character.ports';
import { MemberJoinedEvent } from '../../memberships/events/member-joined.event';
import { MemberKickedEvent } from '../../memberships/events/member-kicked.event';
import { MemberLeftEvent } from '../../memberships/events/member-left.event';
import { MEMBERSHIP_REPO, type IMembershipRepo } from '../../memberships/domain/membership.ports';
import { RollPushedEvent } from '../../dice/events/roll-pushed.event';
import { PostSystemMessageCommand } from '../commands/post-system-message.command';

// ---------------------------------------------------------------------------
// MemberJoinedSystemMessageSubscriber
// ---------------------------------------------------------------------------

@EventsHandler(MemberJoinedEvent)
export class MemberJoinedSystemMessageSubscriber implements IEventHandler<MemberJoinedEvent> {
  constructor(
    private readonly bus: CommandBus,
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
  ) {}

  async handle(event: MemberJoinedEvent): Promise<void> {
    const membership = await this.membershipRepo.findById(event.membershipId);
    const displayName = membership?.displayName ?? event.userId;

    await this.bus.execute(
      new PostSystemMessageCommand(event.gameSessionId, 'chat.system.member_joined', {
        displayName,
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// MemberLeftSystemMessageSubscriber
// ---------------------------------------------------------------------------

@EventsHandler(MemberLeftEvent)
export class MemberLeftSystemMessageSubscriber implements IEventHandler<MemberLeftEvent> {
  constructor(
    private readonly bus: CommandBus,
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
  ) {}

  async handle(event: MemberLeftEvent): Promise<void> {
    const membership = await this.membershipRepo.findById(event.membershipId);
    const displayName = membership?.displayName ?? event.userId;

    await this.bus.execute(
      new PostSystemMessageCommand(event.gameSessionId, 'chat.system.member_left', { displayName }),
    );
  }
}

// ---------------------------------------------------------------------------
// MemberKickedSystemMessageSubscriber
// ---------------------------------------------------------------------------

@EventsHandler(MemberKickedEvent)
export class MemberKickedSystemMessageSubscriber implements IEventHandler<MemberKickedEvent> {
  constructor(
    private readonly bus: CommandBus,
    @Inject(MEMBERSHIP_REPO) private readonly membershipRepo: IMembershipRepo,
  ) {}

  async handle(event: MemberKickedEvent): Promise<void> {
    const membership = await this.membershipRepo.findById(event.membershipId);
    const displayName = membership?.displayName ?? event.userId;

    await this.bus.execute(
      new PostSystemMessageCommand(event.gameSessionId, 'chat.system.member_kicked', {
        displayName,
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// RollPushedSystemMessageSubscriber
// ---------------------------------------------------------------------------

@EventsHandler(RollPushedEvent)
export class RollPushedSystemMessageSubscriber implements IEventHandler<RollPushedEvent> {
  constructor(
    private readonly bus: CommandBus,
    @Inject(CHARACTER_REPO) private readonly characterRepo: ICharacterRepo,
  ) {}

  async handle(event: RollPushedEvent): Promise<void> {
    // Only emit a system message when the roll is linked to a game session.
    if (!event.gameSessionId) return;

    const character = await this.characterRepo.findActiveById(event.characterId);
    const characterName = character?.name ?? event.characterId;

    await this.bus.execute(
      new PostSystemMessageCommand(
        event.gameSessionId,
        'chat.system.roll_pushed',
        // pushedCount and dpDelta are not carried by RollPushedEvent; we use
        // `hits` (final hit count after push) as the available numeric param.
        { characterName, hits: event.hits },
      ),
    );
  }
}
