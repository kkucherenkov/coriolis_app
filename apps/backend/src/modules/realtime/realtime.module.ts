import { Module } from '@nestjs/common';

import { CENTRIFUGO_CLIENT, CentrifugoClient } from './centrifugo.client';
import { SESSION_OWNERSHIP_REPO } from './domain/session-ownership.port';
import { SessionOwnershipRepo } from './infra/session-ownership.repo';
import { RealtimeController } from './realtime.controller';
import { RealtimeService } from './realtime.service';

@Module({
  controllers: [RealtimeController],
  providers: [
    RealtimeService,
    { provide: CENTRIFUGO_CLIENT, useClass: CentrifugoClient },
    { provide: SESSION_OWNERSHIP_REPO, useClass: SessionOwnershipRepo },
  ],
  exports: [CENTRIFUGO_CLIENT],
})
export class RealtimeModule {}
