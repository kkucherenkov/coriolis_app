/**
 * Unit tests for RollPushedDpHandler.
 *
 * Covers T-7.3.1.c acceptance criteria:
 *  - When gameSessionId is set: emits UpdateDpCommand with source ROLL_PUSH.
 *  - When gameSessionId is null: skips DP increment.
 *  - Uses internal=true to bypass GM-owner ACL.
 *  - Catches and logs command failures without re-throwing.
 *
 * T-7.4.1.c/f: publishes roll.pushed to Centrifugo before the DP increment;
 *  a publish failure does not prevent the DP increment.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { RollPushedEvent } from '../../../dice/events/roll-pushed.event';
import { UpdateDpCommand } from '../commands/update-dp.command';
import { RollPushedDpHandler } from './roll-pushed.handler';

import type { ICentrifugoClient } from '../../../realtime/centrifugo.client';

function makeCommandBus() {
  return { execute: vi.fn().mockResolvedValue(undefined) };
}

function makeCentrifugoClient(): ICentrifugoClient {
  return { publish: vi.fn().mockResolvedValue(undefined) };
}

describe('RollPushedDpHandler', () => {
  let commandBus: ReturnType<typeof makeCommandBus>;
  let centrifugo: ICentrifugoClient;
  let handler: RollPushedDpHandler;

  beforeEach(() => {
    commandBus = makeCommandBus();
    centrifugo = makeCentrifugoClient();
    handler = new RollPushedDpHandler(commandBus as never, centrifugo);
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

  it('publishes roll.pushed to the session channel', async () => {
    const event = new RollPushedEvent('roll-1', 'char-1', 'gs-1', 4);

    await handler.handle(event);

    expect(centrifugo.publish).toHaveBeenCalledOnce();
    const [channel, data] = (centrifugo.publish as ReturnType<typeof vi.fn>).mock.calls[0] as [
      string,
      Record<string, unknown>,
    ];
    expect(channel).toBe('session.gs-1');
    expect(data).toMatchObject({
      rollId: 'roll-1',
      characterId: 'char-1',
      gameSessionId: 'gs-1',
      hits: 4,
    });
    expect(typeof data['at']).toBe('string');
  });

  it('skips DP increment and publish when gameSessionId is null', async () => {
    const event = new RollPushedEvent('roll-2', 'char-1', null, 3);

    await handler.handle(event);

    expect(commandBus.execute).not.toHaveBeenCalled();
    expect(centrifugo.publish).not.toHaveBeenCalled();
  });

  it('does not throw when UpdateDpCommand rejects (non-fatal error path)', async () => {
    commandBus.execute.mockRejectedValue(new Error('unexpected DB failure'));
    const event = new RollPushedEvent('roll-3', 'char-1', 'gs-1', 2);

    // Must not reject — the roll is already committed
    await expect(handler.handle(event)).resolves.toBeUndefined();
  });

  it('still issues UpdateDpCommand even when publish throws', async () => {
    vi.mocked(centrifugo.publish).mockRejectedValue(new Error('centrifugo down'));
    const event = new RollPushedEvent('roll-4', 'char-1', 'gs-1', 2);

    await handler.handle(event);

    // DP increment must still be called despite publish failure
    expect(commandBus.execute).toHaveBeenCalledOnce();
  });

  it('uses internal=true regardless of delta value', async () => {
    const event = new RollPushedEvent('roll-4', 'char-1', 'gs-2', 1);

    await handler.handle(event);

    const [cmd] = commandBus.execute.mock.calls[0] as [UpdateDpCommand];
    expect(cmd.internal).toBe(true);
  });
});
