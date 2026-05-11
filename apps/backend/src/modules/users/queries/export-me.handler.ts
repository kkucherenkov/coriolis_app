/**
 * WHY this file exists:
 * Read-side handler for the JSON export. Receives an ExportMeQuery,
 * delegates to IExportRepo, returns the bundle untouched. No mutation,
 * no business logic — the repo composes the cross-resource query and
 * shapes the envelope. The handler is the seam where CQRS gives us a
 * single test target.
 */
import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { EXPORT_REPO } from '../domain/user.ports';

import { ExportMeQuery } from './export-me.query';

import type { IExportRepo, MeExportBundle } from '../domain/user.ports';

@QueryHandler(ExportMeQuery)
export class ExportMeHandler implements IQueryHandler<ExportMeQuery, MeExportBundle> {
  constructor(@Inject(EXPORT_REPO) private readonly repo: IExportRepo) {}

  async execute(query: ExportMeQuery): Promise<MeExportBundle> {
    return this.repo.loadBundleFor(query.userId);
  }
}
