import { describe, it, expect, beforeEach } from 'vitest';

import { ViewTracker } from './view-tracker';

describe('ViewTracker', () => {
  let tracker: ViewTracker;

  beforeEach(() => {
    tracker = new ViewTracker();
  });

  it('starts with an empty pending buffer', () => {
    expect(tracker.pendingSize).toBe(0);
    expect(tracker.drain()).toEqual([]);
  });

  it('records a single view', () => {
    tracker.recordView('slug_aaa');
    expect(tracker.pendingSize).toBe(1);
  });

  it('accumulates multiple views for the same slug', () => {
    tracker.recordView('slug_aaa');
    tracker.recordView('slug_aaa');
    tracker.recordView('slug_aaa');

    const entries = tracker.drain();
    expect(entries).toHaveLength(1);
    expect(entries[0]).toEqual({ slug: 'slug_aaa', count: 3 });
  });

  it('tracks views for multiple slugs independently', () => {
    tracker.recordView('slug_aaa');
    tracker.recordView('slug_bbb');
    tracker.recordView('slug_aaa');

    const entries = tracker.drain();
    const aEntry = entries.find((e) => e.slug === 'slug_aaa');
    const bEntry = entries.find((e) => e.slug === 'slug_bbb');

    expect(aEntry?.count).toBe(2);
    expect(bEntry?.count).toBe(1);
  });

  it('clears the buffer after drain', () => {
    tracker.recordView('slug_aaa');
    tracker.drain();

    expect(tracker.pendingSize).toBe(0);
    expect(tracker.drain()).toEqual([]);
  });

  it('accumulates new views after a drain', () => {
    tracker.recordView('slug_aaa');
    tracker.drain();

    tracker.recordView('slug_aaa');
    tracker.recordView('slug_aaa');

    const entries = tracker.drain();
    expect(entries[0]?.count).toBe(2);
  });
});
