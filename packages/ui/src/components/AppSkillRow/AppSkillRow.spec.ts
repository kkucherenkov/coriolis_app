import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppSkillRow from './AppSkillRow.vue';

describe('AppSkillRow', () => {
  // ── Required content ──────────────────────────────────────────────────────

  it('renders the root with the BEM class', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 3 },
    });
    expect(wrapper.classes()).toContain('app-skill-row');
  });

  it('renders the skill name', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 3 },
    });
    expect(wrapper.find('.app-skill-row__name').text()).toBe('Pilot');
  });

  it('renders the attribute eyebrow', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 3 },
    });
    expect(wrapper.find('.app-skill-row__attr').text()).toBe('Agility');
  });

  it('renders the monospace rank', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 3 },
    });
    expect(wrapper.find('.app-skill-row__rank').text()).toBe('3');
  });

  it('renders the dot meter via AppDots', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 3 },
    });
    expect(wrapper.find('.app-dots').exists()).toBe(true);
  });

  // ── Slot override ─────────────────────────────────────────────────────────

  it('renders the default `name` fallback when no slot is provided', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 3 },
    });
    expect(wrapper.find('.app-skill-row__name').text()).toBe('Pilot');
  });

  it('replaces the name with the `name` slot when provided (key-chip case)', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 4, tone: 'mystic' },
      slots: { name: '<span data-testid="custom-name">Pilot <em>key</em></span>' },
    });
    const slotEl = wrapper.find('[data-testid="custom-name"]');
    expect(slotEl.exists()).toBe(true);
    expect(slotEl.html()).toContain('<em>key</em>');
  });

  // ── Rank clamping ─────────────────────────────────────────────────────────

  it('clamps a negative rank to 0', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: -2 },
    });
    expect(wrapper.find('.app-skill-row__rank').text()).toBe('0');
  });

  it('clamps a rank above rankMax to rankMax', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 9 },
    });
    expect(wrapper.find('.app-skill-row__rank').text()).toBe('5');
  });

  it('respects a custom rankMax (e.g. attribute meter)', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'HP', attr: 'Vitality', rank: 7, rankMax: 10 },
    });
    expect(wrapper.find('.app-skill-row__rank').text()).toBe('7');
    expect(wrapper.find('.app-dots').attributes('aria-valuemax')).toBe('10');
  });

  // ── Tone modifiers ────────────────────────────────────────────────────────

  it('defaults to the brass tone modifier', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 3 },
    });
    expect(wrapper.classes()).toContain('app-skill-row--brass');
  });

  it('applies the mystic tone modifier when tone="mystic"', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Mystic Powers', attr: 'Empathy', rank: 2, tone: 'mystic' },
    });
    expect(wrapper.classes()).toContain('app-skill-row--mystic');
  });

  it('forwards the tone to the underlying AppDots', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Mystic Powers', attr: 'Empathy', rank: 2, tone: 'mystic' },
    });
    expect(wrapper.find('.app-dots').classes()).toContain('app-dots--mystic');
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it('exposes the row as a group with a combined accessible name', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 3 },
    });
    const root = wrapper.find('[data-testid="app-skill-row"]');
    expect(root.attributes('role')).toBe('group');
    expect(root.attributes('aria-label')).toBe('Pilot, Agility, 3 of 5');
  });

  it('reflects the clamped rank into the accessible name', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 99, rankMax: 5 },
    });
    expect(wrapper.find('[data-testid="app-skill-row"]').attributes('aria-label')).toBe(
      'Pilot, Agility, 5 of 5',
    );
  });

  it('hides the duplicate visual attr + rank from assistive tech', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Pilot', attr: 'Agility', rank: 3 },
    });
    expect(wrapper.find('.app-skill-row__attr').attributes('aria-hidden')).toBe('true');
    expect(wrapper.find('.app-skill-row__rank').attributes('aria-hidden')).toBe('true');
  });

  // ── Localization ──────────────────────────────────────────────────────────

  it('renders Cyrillic name + attr without truncation', () => {
    const wrapper = mount(AppSkillRow, {
      props: { name: 'Пилотирование', attr: 'Ловкость', rank: 3 },
    });
    expect(wrapper.find('.app-skill-row__name').text()).toBe('Пилотирование');
    expect(wrapper.find('.app-skill-row__attr').text()).toBe('Ловкость');
  });
});
