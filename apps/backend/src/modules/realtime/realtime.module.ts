import { Module } from '@nestjs/common';

import { CENTRIFUGO_CLIENT, CentrifugoClient } from './centrifugo.client';
import { SESSION_ACCESS_REPO } from './domain/session-ownership.port';
import { SessionAccessRepo } from './infra/session-access.repo';
import { RealtimeController } from './realtime.controller';
import { RealtimeRouter } from './realtime-router';
import { RealtimeService } from './realtime.service';

@Module({
  controllers: [RealtimeController],
  providers: [
    RealtimeService,
    RealtimeRouter,
    { provide: CENTRIFUGO_CLIENT, useClass: CentrifugoClient },
    { provide: SESSION_ACCESS_REPO, useClass: SessionAccessRepo },
  ],
  exports: [CENTRIFUGO_CLIENT, RealtimeRouter],
})
export class RealtimeModule {}
