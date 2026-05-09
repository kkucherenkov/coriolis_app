/**
 * WHY hex literals appear here:
 * Satori processes a React.createElement element tree and needs concrete CSS
 * color values. It cannot read CSS custom properties or design token references
 * at render time. All hex values below are sourced from:
 *   specs/design/tokens/color.json
 *   specs/design/tokens/typography.json
 * The token name is noted next to each value.
 *
 * Token → hex mapping:
 *   color.surface.void        → #0B0E2C  (deepest indigo, background top)
 *   color.surface.night       → #15193F  (card background, gradient bottom)
 *   color.brand.brass-light   → #F4E4B8  (heading brass highlight)
 *   color.brand.brass         → #D4A95C  (primary brass, footer text)
 *   color.brand.brass-deep    → #A67C28  (aged brass, borders, divider)
 *   color.brand.brass-shadow  → #6B4E1A  (icon medallion background)
 *   color.text.secondary      → #D9CDB0  (concept text)
 *
 * Font families (font.family.display = Forum; font.family.body = Inter).
 * Satori does not support CSS fallback font stacks — only the primary family
 * name is used. Fallback rendering happens automatically when Satori can't
 * find a glyph in the provided font.
 *
 * WHY no JSX: the backend tsconfig does not enable JSX transform. Satori
 * accepts plain React.createElement objects — no JSX compiler step needed.
 *
 * Satori CSS constraints (as of v0.26):
 *   - No shorthand properties: use borderWidth+borderStyle+borderColor, not border
 *   - No boxSizing
 *   - background accepts solid colors and linear-gradient()
 *   - All flexbox properties are supported
 *   - letterSpacing is supported (Satori maps it to SVG letter-spacing)
 *   - lineHeight as number ratio is preferred
 *   - textTransform uppercase is supported
 */

import React from 'react';

import type { CharacterReadModel, IconId } from '../../../characters/domain/character.ports';

/** Maximum character name length before truncation with ellipsis. */
const MAX_NAME_LENGTH = 40;
/** Maximum concept length (Satori wraps at container width; cap for safety). */
const MAX_CONCEPT_LENGTH = 80;

/**
 * Human-readable glyph for each Nine Icon.
 * No SVG icon set exists yet — styled Unicode initials as a medallion,
 * matching the wizard-step-3 approach on mobile.
 */
const ICON_GLYPH: Record<IconId, string> = {
  'lady-of-tears': 'L',
  traveler: 'T',
  messenger: 'M',
  merchant: 'Mc',
  dancer: 'D',
  gambler: 'G',
  judge: 'J',
  'faceless-one': 'F',
  deckhand: 'Dk',
};

function truncate(text: string, maxLen: number): string {
  if (text.length <= maxLen) return text;
  return text.slice(0, maxLen - 1) + '…'; // …
}

const h = React.createElement;

// Reusable border style values — color.brand.brass-deep
const BRASS_BORDER_COLOR = '#A67C28';
const BRASS_BORDER_WIDTH = 2;

/** Corner accent — a 48×48 box with two visible borders (no shorthand). */
function cornerAccent(
  pos: { top?: number; bottom?: number; left?: number; right?: number },
  sides: { top?: boolean; bottom?: boolean; left?: boolean; right?: boolean },
): React.ReactElement {
  return h('div', {
    style: {
      position: 'absolute',
      width: 48,
      height: 48,
      display: 'flex',
      borderTopWidth: sides.top ? BRASS_BORDER_WIDTH : 0,
      borderTopStyle: 'solid',
      borderTopColor: BRASS_BORDER_COLOR,
      borderBottomWidth: sides.bottom ? BRASS_BORDER_WIDTH : 0,
      borderBottomStyle: 'solid',
      borderBottomColor: BRASS_BORDER_COLOR,
      borderLeftWidth: sides.left ? BRASS_BORDER_WIDTH : 0,
      borderLeftStyle: 'solid',
      borderLeftColor: BRASS_BORDER_COLOR,
      borderRightWidth: sides.right ? BRASS_BORDER_WIDTH : 0,
      borderRightStyle: 'solid',
      borderRightColor: BRASS_BORDER_COLOR,
      ...pos,
    },
  });
}

/**
 * Returns a Satori-compatible React element tree for the character OG card.
 * Dimensions: 1200 × 630 px.
 */
export function buildCharacterOgElement(
  character: Pick<CharacterReadModel, 'name' | 'concept' | 'iconId'>,
): React.ReactElement {
  const displayName = truncate(character.name, MAX_NAME_LENGTH);
  const displayConcept = character.concept ? truncate(character.concept, MAX_CONCEPT_LENGTH) : null;
  // ICON_GLYPH is typed as Record<IconId, string> — every valid IconId has a value.
  // The optional-chain fallback is unreachable at runtime but kept for exhaustiveness.
  const iconGlyph = character.iconId ? ICON_GLYPH[character.iconId] : '★'; // ★ BLACK STAR

  return h(
    'div',
    {
      style: {
        width: 1200,
        height: 630,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        // color.surface.void → color.surface.night gradient (top → bottom)
        background: 'linear-gradient(180deg, #0B0E2C 0%, #15193F 100%)',
        // Outer border — use explicit long-hand (Satori doesn't support 'border' shorthand)
        borderTopWidth: BRASS_BORDER_WIDTH,
        borderTopStyle: 'solid',
        borderTopColor: BRASS_BORDER_COLOR,
        borderBottomWidth: BRASS_BORDER_WIDTH,
        borderBottomStyle: 'solid',
        borderBottomColor: BRASS_BORDER_COLOR,
        borderLeftWidth: BRASS_BORDER_WIDTH,
        borderLeftStyle: 'solid',
        borderLeftColor: BRASS_BORDER_COLOR,
        borderRightWidth: BRASS_BORDER_WIDTH,
        borderRightStyle: 'solid',
        borderRightColor: BRASS_BORDER_COLOR,
        padding: '48px 80px',
        position: 'relative',
      },
    },
    // Corner ornaments
    cornerAccent({ top: 24, left: 24 }, { top: true, left: true }),
    cornerAccent({ top: 24, right: 24 }, { top: true, right: true }),
    cornerAccent({ bottom: 24, left: 24 }, { bottom: true, left: true }),
    cornerAccent({ bottom: 24, right: 24 }, { bottom: true, right: true }),

    // Center content column
    h(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        },
      },

      // Icon medallion — 96×96 circle
      h(
        'div',
        {
          style: {
            width: 96,
            height: 96,
            borderRadius: 48,
            backgroundColor: '#6B4E1A', // color.brand.brass-shadow
            borderTopWidth: 2,
            borderTopStyle: 'solid',
            borderTopColor: '#D4A95C', // color.brand.brass
            borderBottomWidth: 2,
            borderBottomStyle: 'solid',
            borderBottomColor: '#D4A95C',
            borderLeftWidth: 2,
            borderLeftStyle: 'solid',
            borderLeftColor: '#D4A95C',
            borderRightWidth: 2,
            borderRightStyle: 'solid',
            borderRightColor: '#D4A95C',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: 32,
          },
        },
        h(
          'span',
          {
            style: {
              fontFamily: 'Forum', // font.family.display — no fallback stack (Satori constraint)
              fontSize: 36,
              fontWeight: 400,
              color: '#F4E4B8', // color.brand.brass-light
              lineHeight: 1,
            },
          },
          iconGlyph,
        ),
      ),

      // Character name — Forum 56px, color.brand.brass-light
      h(
        'div',
        {
          style: {
            fontFamily: 'Forum', // font.family.display
            fontSize: 56,
            fontWeight: 400,
            color: '#F4E4B8', // color.brand.brass-light
            letterSpacing: '0.04em',
            lineHeight: 1.2,
            textAlign: 'center',
            marginBottom: 16,
            display: 'flex',
          },
        },
        displayName,
      ),

      // Concept — Inter 22px, color.text.secondary (conditional)
      displayConcept === null
        ? h('div', { style: { marginBottom: 48, display: 'flex' } })
        : h(
            'div',
            {
              style: {
                fontFamily: 'Inter', // font.family.body
                fontSize: 22,
                fontWeight: 400,
                color: '#D9CDB0', // color.text.secondary
                letterSpacing: '0.01em',
                lineHeight: 1.5,
                textAlign: 'center',
                maxWidth: 800,
                marginBottom: 48,
                display: 'flex',
              },
            },
            displayConcept,
          ),

      // Divider — color.brand.brass-deep hairline
      h('div', {
        style: {
          width: 120,
          height: 1,
          backgroundColor: '#A67C28', // color.brand.brass-deep
          marginBottom: 24,
          display: 'flex',
        },
      }),

      // Footer caption — Inter 16px, color.brand.brass, uppercase
      h(
        'div',
        {
          style: {
            fontFamily: 'Inter', // font.family.body
            fontSize: 16,
            fontWeight: 500,
            color: '#D4A95C', // color.brand.brass
            letterSpacing: '0.12em',
            textTransform: 'uppercase',
            display: 'flex',
          },
        },
        'CORIOLIS COMPANION',
      ),
    ),
  );
}
