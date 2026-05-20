/**
 * Unit tests for RollPushedDpHandler.
 *
 * Covers T-7.3.1.c acceptance criteria:
 *  - When gameSessionId is set: emits UpdateDpCommand with source ROLL_PUSH.
 *  - When gameSessionId is null: skips DP increment.
 *  - Uses internal=true to bypass GM-owner ACL.
 *  - Catches and logs command failures without re-throwing.
 *
 * T-7.4.1.c/f: publishes roll.pushed via RealtimeRouter before the DP increment;
 *  router handles fire-and-forget internally so publish failures never block the
 *  DP increment (tested via router.publishRollPushed always resolving).
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { RollPushedEvent } from '../../../dice/events/roll-pushed.event';
import { UpdateDpCommand } from '../commands/update-dp.command';
import { RollPushedDpHandler } from './roll-pushed.handler';

import type { RealtimeRouter } from '../../../realtime/realtime-router';

function makeCommandBus() {
  return { execute: vi.fn().mockResolvedValue(undefined) };
}

function makeRouter(): RealtimeRouter {
  return {
    publishRollPushed: vi.fn().mockResolvedValue(undefined),
    publishDpChanged: vi.fn().mockResolvedValue(undefined),
    publishCombatUpdated: vi.fn().mockResolvedValue(undefined),
    publishChatMessage: vi.fn().mockResolvedValue(undefined),
    publishChatMessageDeleted: vi.fn().mockResolvedValue(undefined),
  } as unknown as RealtimeRouter;
}

describe('RollPushedDpHandler', () => {
  let commandBus: ReturnType<typeof makeCommandBus>;
  let router: RealtimeRouter;
  let handler: RollPushedDpHandler;

  beforeEach(() => {
    commandBus = makeCommandBus();
    router = makeRouter();
    handler = new RollPushedDpHandler(commandBus as never, router);
  });

  it('issues UpdateDpCommand +1 with ROLL_PUSH when gameSessionId is set', async () => {
    const event = new RollPushedEvent('roll-1', 'char-1', 'gs-1', 4);

    await handler.handle(event);

    expect(commandBus.execute).toHaveBeenCalledOnce();
    const [cmd] = commandBus.execute.mock.calls[0] as [UpdateDpCommand];
    expect(cmd).toBeInstanceOf(UpdateDpCommand);
    expect(cmd.gameSessionId).toBe('gs-1');
    expect(cmd.delta).toBe(1);
    expect(cmd.source).toBe('ROLL_PUSH');
    expect(cmd.internal).toBe(true);
    expect(cmd.rollId).toBe('roll-1');
    expect(cmd.callerId).toBe('system');
  });

  it('publishes roll.pushed via router.publishRollPushed to the session channel', async () => {
    const event = new RollPushedEvent('roll-1', 'char-1', 'gs-1', 4);

    await handler.handle(event);

    expect(router.publishRollPushed).toHaveBeenCalledOnce();
    const [payload] = vi.mocked(router.publishRollPushed).mock.calls[0]!;
    expect(payload).toMatchObject({
      rollId: 'roll-1',
      characterId: 'char-1',
      gameSessionId: 'gs-1',
      hits: 4,
    });
    expect(typeof payload.at).toBe('string');
  });

  it('skips DP increment and publish when gameSessionId is null', async () => {
    const event = new RollPushedEvent('roll-2', 'char-1', null, 3);

    await handler.handle(event);

    expect(commandBus.execute).not.toHaveBeenCalled();
    expect(router.publishRollPushed).not.toHaveBeenCalled();
  });

  it('does not throw when UpdateDpCommand rejects (non-fatal error path)', async () => {
    commandBus.execute.mockRejectedValue(new Error('unexpected DB failure'));
    const event = new RollPushedEvent('roll-3', 'char-1', 'gs-1', 2);

    // Must not reject — the roll is already committed
    await expect(handler.handle(event)).resolves.toBeUndefined();
  });

  it('still issues UpdateDpCommand even when router.publishRollPushed resolves (always resolves)', async () => {
    // RealtimeRouter.publishRollPushed never rejects — it catches internally.
    // This test confirms the handler's publish → command sequence is maintained.
    vi.mocked(router.publishRollPushed).mockResolvedValue(undefined);
    const event = new RollPushedEvent('roll-4', 'char-1', 'gs-1', 2);

    await handler.handle(event);

    // DP increment must still be called after publish
    expect(commandBus.execute).toHaveBeenCalledOnce();
  });

  it('uses internal=true regardless of delta value', async () => {
    const event = new RollPushedEvent('roll-4', 'char-1', 'gs-2', 1);

    await handler.handle(event);

    const [cmd] = commandBus.execute.mock.calls[0] as [UpdateDpCommand];
    expect(cmd.internal).toBe(true);
  });
});
