import type { TestRunnerConfig } from '@storybook/test-runner';
import { getStoryContext, waitForPageReady } from '@storybook/test-runner';
import { checkA11y, injectAxe } from 'axe-playwright';
import { toMatchImageSnapshot } from 'jest-image-snapshot';
import type { RunOptions } from 'axe-core';

/**
 * Storybook test-runner config.
 *
 * Per story (after the play function, if any):
 *  1. wait for the preview iframe to settle,
 *  2. inject axe-core and assert no a11y violations
 *     (rules pulled from each story's `parameters.a11y.options`),
 *  3. when STORYBOOK_VISUAL=1, screenshot the preview and diff
 *     against `test/__snapshots__/<story-id>.png`.
 *
 * Visual baselines are platform-specific (font rendering differs across
 * macOS / Linux), so they live behind an env flag until we seed them
 * from a Linux runner. CI runs a11y unconditionally; visual is opt-in.
 *
 * The WCAG ruleset is pinned in `.storybook/preview.ts` via
 * `parameters.a11y.options.runOnly` (wcag2a, wcag2aa, wcag21a, wcag21aa).
 * Per-story overrides use `parameters.a11y.disable: true` (with a WHY
 * comment) — never repo-wide rule disables.
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

    // `parameters.a11y` shape as defined by @storybook/addon-a11y:
    //   disable?: boolean   — skip axe for this story entirely
    //   options?: RunOptions — passed directly to axe.run()
    //   test?: 'off' | 'todo' | 'error'
    const a11yParams = storyContext.parameters?.a11y as
      | { disable?: boolean; options?: RunOptions; test?: string }
      | undefined;

    // Honour per-story opt-out (must include a WHY comment in the story).
    // Also skip if the story sets test: 'off' (equivalent to disable).
    const skip = a11yParams?.disable === true || a11yParams?.test === 'off';

    if (!skip) {
      await checkA11y(page, '#storybook-root', {
        detailedReport: true,
        detailedReportOptions: { html: true },
        // options from the story (or global preview defaults) — includes
        // runOnly (WCAG tags) and per-rule overrides set in preview.ts.
        axeOptions: a11yParams?.options,
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
