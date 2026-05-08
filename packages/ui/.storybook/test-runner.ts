import type { TestRunnerConfig } from '@storybook/test-runner';
import { getStoryContext, waitForPageReady } from '@storybook/test-runner';
import { checkA11y, injectAxe } from 'axe-playwright';
import { toMatchImageSnapshot } from 'jest-image-snapshot';

/**
 * Storybook test-runner config.
 *
 * Per story (after the play function, if any):
 *  1. wait for the preview iframe to settle,
 *  2. inject axe-core and assert no a11y violations
 *     (rules pulled from each story's `parameters.a11y.config`),
 *  3. when STORYBOOK_VISUAL=1, screenshot the preview and diff
 *     against `test/__snapshots__/<story-id>.png`.
 *
 * Visual baselines are platform-specific (font rendering differs across
 * macOS / Linux), so they live behind an env flag until we seed them
 * from a Linux runner. CI runs a11y unconditionally; visual is opt-in.
 */
const VISUAL = process.env.STORYBOOK_VISUAL === '1';

const config: TestRunnerConfig = {
  setup() {
    expect.extend({ toMatchImageSnapshot });
  },

  async preVisit(page) {
    await injectAxe(page);
  },

  async postVisit(page, context) {
    await waitForPageReady(page);

    const storyContext = await getStoryContext(page, context);
    const a11yParams = storyContext.parameters?.a11y as
      | { disable?: boolean; config?: unknown; options?: unknown }
      | undefined;

    if (!a11yParams?.disable) {
      await checkA11y(page, '#storybook-root', {
        detailedReport: true,
        detailedReportOptions: { html: true },
        axeOptions: a11yParams?.config as never,
      });
    }

    if (VISUAL) {
      const root = await page.$('#storybook-root');
      if (!root) return;

      const image = await root.screenshot({
        animations: 'disabled',
        caret: 'hide',
      });

      // @ts-expect-error — extended via setup()
      expect(image).toMatchImageSnapshot({
        customSnapshotsDir: `${process.cwd()}/test/__snapshots__`,
        customSnapshotIdentifier: context.id,
        failureThreshold: 0.01,
        failureThresholdType: 'percent',
      });
    }
  },
};

export default config;
