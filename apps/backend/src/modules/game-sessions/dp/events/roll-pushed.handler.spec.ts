/**
 * Unit tests for RollPushedDpHandler.
 *
 * Covers T-7.3.1.c acceptance criteria:
 *  - When gameSessionId is set: emits UpdateDpCommand with source ROLL_PUSH.
 *  - When gameSessionId is null: skips DP increment.
 *  - Uses internal=true to bypass GM-owner ACL.
 *  - Catches and logs command failures without re-throwing.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { RollPushedEvent } from '../../../dice/events/roll-pushed.event';
import { UpdateDpCommand } from '../commands/update-dp.command';
import { RollPushedDpHandler } from './roll-pushed.handler';

function makeCommandBus() {
  return { execute: vi.fn().mockResolvedValue(undefined) };
}

describe('RollPushedDpHandler', () => {
  let commandBus: ReturnType<typeof makeCommandBus>;
  let handler: RollPushedDpHandler;

  beforeEach(() => {
    commandBus = makeCommandBus();
    // Inject the mock; cast because the handler only uses .execute()
    handler = new RollPushedDpHandler(commandBus as never);
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

  it('skips DP increment when gameSessionId is null', async () => {
    const event = new RollPushedEvent('roll-2', 'char-1', null, 3);

    await handler.handle(event);

    expect(commandBus.execute).not.toHaveBeenCalled();
  });

  it('does not throw when UpdateDpCommand rejects (non-fatal error path)', async () => {
    commandBus.execute.mockRejectedValue(new Error('unexpected DB failure'));
    const event = new RollPushedEvent('roll-3', 'char-1', 'gs-1', 2);

    // Must not reject — the roll is already committed
    await expect(handler.handle(event)).resolves.toBeUndefined();
  });

  it('uses internal=true regardless of delta value', async () => {
    const event = new RollPushedEvent('roll-4', 'char-1', 'gs-2', 1);

    await handler.handle(event);

    const [cmd] = commandBus.execute.mock.calls[0] as [UpdateDpCommand];
    expect(cmd.internal).toBe(true);
  });
});
