import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { CHARACTER_REPO } from '../domain/character.ports';
import { CharacterRepo } from '../infra/character.repo';

import { AddTalentHandler } from './commands/add-talent.handler';
import { DeleteTalentHandler } from './commands/delete-talent.handler';
import { UpdateTalentHandler } from './commands/update-talent.handler';
import { TALENT_REPO } from './domain/talent.ports';
import { TalentRepo } from './infra/talent.repo';
import { TalentsController } from './talents.controller';

@Module({
  imports: [CqrsModule],
  controllers: [TalentsController],
  providers: [
    AddTalentHandler,
    UpdateTalentHandler,
    DeleteTalentHandler,
    { provide: TALENT_REPO, useClass: TalentRepo },
    { provide: CHARACTER_REPO, useClass: CharacterRepo },
  ],
  exports: [AddTalentHandler, TALENT_REPO],
})
export class TalentsModule {}
