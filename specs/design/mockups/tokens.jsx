// Tokens reference card — colors, type scale, spacing, motifs
const TokensCard = () => {
  const colors = [
    {
      group: 'Surfaces',
      items: [
        { name: '--surface-void', hex: '#0B0E2C' },
        { name: '--surface-night', hex: '#15193F' },
        { name: '--surface-dawn', hex: '#252B5C' },
        { name: '--surface-parchment', hex: '#F2E8D0' },
      ],
    },
    {
      group: 'Brand · Brass',
      items: [
        { name: '--brand-brass-light', hex: '#F4E4B8' },
        { name: '--brand-brass', hex: '#D4A95C' },
        { name: '--brand-brass-deep', hex: '#A67C28' },
        { name: '--brand-brass-shadow', hex: '#6B4E1A' },
      ],
    },
    {
      group: 'Semantic',
      items: [
        { name: '--state-crimson', hex: '#A8324A' },
        { name: '--state-crimson-bright', hex: '#E54E6B' },
        { name: '--state-mystic-teal', hex: '#2BA3A0' },
        { name: '--state-success', hex: '#5A8A3A' },
        { name: '--state-darkness', hex: '#5B2A78' },
      ],
    },
  ];

  const typeRows = [
    {
      tok: '--type-display-xl',
      spec: 'Forum 400 · 48/56 · 0.06em',
      sample: 'Coriolis',
      font: 'Forum',
      size: 48,
      ls: '0.06em',
    },
    {
      tok: '--type-display-lg',
      spec: 'Forum 400 · 36/44 · 0.04em',
      sample: 'Tariq al-Asari',
      font: 'Forum',
      size: 36,
      ls: '0.04em',
    },
    {
      tok: '--type-display-md',
      spec: 'Forum 400 · 28/36 · 0.04em',
      sample: 'Skills',
      font: 'Forum',
      size: 28,
      ls: '0.04em',
    },
    {
      tok: '--type-display-sm',
      spec: 'Forum 400 · 20/28 · 0.08em UPPER',
      sample: 'STRENGTH',
      font: 'Forum',
      size: 20,
      ls: '0.10em',
      upper: true,
    },
    {
      tok: '--type-body-lg',
      spec: 'Inter 400 · 18/28',
      sample: 'The Third Horizon waits.',
      font: 'Inter',
      size: 18,
    },
    {
      tok: '--type-body-md',
      spec: 'Inter 400 · 16/24',
      sample: 'Push the roll for one Darkness Point.',
      font: 'Inter',
      size: 16,
    },
    {
      tok: '--type-body-sm',
      spec: 'Inter 500 · 14/20',
      sample: 'Equipped · 0.4 enc',
      font: 'Inter',
      size: 14,
      weight: 500,
    },
    {
      tok: '--type-mono-stat-xl',
      spec: 'JetBrains Mono 700 · 32',
      sample: '12 / 14',
      font: 'JetBrains Mono',
      size: 32,
      weight: 700,
    },
    {
      tok: '--type-mono-stat-md',
      spec: 'JetBrains Mono 500 · 20',
      sample: 'Rank 4',
      font: 'JetBrains Mono',
      size: 20,
      weight: 500,
    },
  ];

  const spacing = [
    ['1', 4],
    ['2', 8],
    ['3', 12],
    ['4', 16],
    ['5', 20],
    ['6', 24],
    ['7', 32],
    ['8', 40],
    ['9', 48],
    ['10', 56],
    ['11', 64],
    ['12', 80],
  ];

  return (
    <div
      className="cor-surface-void"
      style={{ minHeight: '100%', padding: 56, color: 'var(--text-primary)' }}
    >
      {/* Header */}
      <div
        style={{
          display: 'flex',
          alignItems: 'flex-end',
          justifyContent: 'space-between',
          marginBottom: 48,
        }}
      >
        <div>
          <div
            className="cor-body cor-uppercase"
            style={{
              color: 'var(--brand-brass)',
              fontSize: 12,
              letterSpacing: '0.3em',
              marginBottom: 14,
            }}
          >
            specs/design/tokens · v2.0
          </div>
          <h1
            className="cor-display cor-track-06"
            style={{
              fontSize: 64,
              color: 'var(--brand-brass-light)',
              margin: 0,
              fontWeight: 400,
              lineHeight: 1,
            }}
          >
            The Brass Codex
          </h1>
          <Swash width={220} />
          <p
            className="cor-body"
            style={{ color: 'var(--text-secondary)', fontSize: 16, marginTop: 18, maxWidth: 640 }}
          >
            Tokens authored in{' '}
            <span className="cor-mono" style={{ color: 'var(--brand-brass-light)' }}>
              specs/design/tokens/*.json
            </span>
            , emitted to web and Flutter by{' '}
            <span className="cor-mono" style={{ color: 'var(--brand-brass-light)' }}>
              pnpm design:build
            </span>
            . Stylelint blocks hex literals — every value below is a token reference.
          </p>
        </div>
        <div style={{ display: 'flex', gap: 24 }}>
          <StarOrnament size={56} color="var(--brand-brass)" />
          <StarOrnament size={56} color="var(--brand-brass-deep)" />
          <StarOrnament size={56} color="var(--brand-brass)" opacity={0.5} />
        </div>
      </div>

      {/* COLORS */}
      <PanelTitle size="lg">Color Tokens</PanelTitle>
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(3, 1fr)',
          gap: 32,
          marginBottom: 56,
        }}
      >
        {colors.map((group) => (
          <div key={group.group} className="cor-card" style={{ padding: 24 }}>
            <div
              className="cor-body cor-uppercase"
              style={{
                color: 'var(--brand-brass)',
                fontSize: 11,
                letterSpacing: '0.18em',
                marginBottom: 16,
              }}
            >
              {group.group}
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {group.items.map((c) => (
                <div key={c.name} style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
                  <div
                    style={{
                      width: 44,
                      height: 44,
                      borderRadius: 4,
                      background: c.hex,
                      border: '1px solid var(--brand-brass-shadow)',
                      flexShrink: 0,
                    }}
                  />
                  <div style={{ minWidth: 0 }}>
                    <div
                      className="cor-mono"
                      style={{ fontSize: 12, color: 'var(--brand-brass-light)' }}
                    >
                      {c.name}
                    </div>
                    <div
                      className="cor-mono"
                      style={{ fontSize: 11, color: 'var(--text-secondary)' }}
                    >
                      {c.hex}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      {/* TYPE */}
      <PanelTitle size="lg">Type Scale</PanelTitle>
      <div className="cor-card" style={{ padding: 32, marginBottom: 56 }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
          {typeRows.map((row) => (
            <div
              key={row.tok}
              style={{
                display: 'grid',
                gridTemplateColumns: '220px 220px 1fr',
                alignItems: 'baseline',
                gap: 24,
                paddingBottom: 18,
                borderBottom: '1px solid rgba(166,124,40,0.25)',
              }}
            >
              <div className="cor-mono" style={{ color: 'var(--brand-brass-light)', fontSize: 12 }}>
                {row.tok}
              </div>
              <div className="cor-body" style={{ color: 'var(--text-secondary)', fontSize: 12 }}>
                {row.spec}
              </div>
              <div
                style={{
                  fontFamily: row.font,
                  fontSize: row.size,
                  fontWeight: row.weight || 400,
                  letterSpacing: row.ls || 'normal',
                  textTransform: row.upper ? 'uppercase' : 'none',
                  color: 'var(--text-primary)',
                  lineHeight: 1.1,
                }}
              >
                {row.sample}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* SPACING + RADIUS */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: 32, marginBottom: 56 }}>
        <div>
          <PanelTitle>Spacing · 4px base</PanelTitle>
          <div className="cor-card" style={{ padding: 24 }}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {spacing.map(([n, v]) => (
                <div
                  key={n}
                  style={{
                    display: 'grid',
                    gridTemplateColumns: '70px 50px 1fr',
                    alignItems: 'center',
                    gap: 12,
                  }}
                >
                  <span
                    className="cor-mono"
                    style={{ color: 'var(--brand-brass-light)', fontSize: 12 }}
                  >
                    --space-{n}
                  </span>
                  <span
                    className="cor-mono"
                    style={{ color: 'var(--text-secondary)', fontSize: 12 }}
                  >
                    {v}px
                  </span>
                  <span
                    style={{
                      height: 8,
                      width: v,
                      background: 'var(--brand-brass)',
                      borderRadius: 1,
                    }}
                  />
                </div>
              ))}
            </div>
          </div>
        </div>
        <div>
          <PanelTitle>Radius</PanelTitle>
          <div
            className="cor-card"
            style={{ padding: 24, display: 'flex', flexDirection: 'column', gap: 14 }}
          >
            {[
              ['--radius-sm', '2px', 2],
              ['--radius-md', '4px · default', 4],
              ['--radius-lg', '8px · modals', 8],
              ['--radius-pill', '9999px · chips only', 9999],
            ].map(([n, label, r]) => (
              <div key={n} style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
                <div
                  style={{
                    width: 56,
                    height: 32,
                    background: 'var(--brand-brass)',
                    borderRadius: r,
                  }}
                />
                <div>
                  <div
                    className="cor-mono"
                    style={{ color: 'var(--brand-brass-light)', fontSize: 12 }}
                  >
                    {n}
                  </div>
                  <div
                    className="cor-body"
                    style={{ color: 'var(--text-secondary)', fontSize: 12 }}
                  >
                    {label}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* MOTIFS */}
      <PanelTitle size="lg">Decorative Motifs</PanelTitle>
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(4, 1fr)',
          gap: 24,
          marginBottom: 56,
        }}
      >
        <div
          className="cor-card"
          style={{
            padding: 32,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 16,
          }}
        >
          <StarOrnament size={64} color="var(--brand-brass)" />
          <div
            className="cor-body cor-uppercase"
            style={{ color: 'var(--brand-brass)', fontSize: 11, letterSpacing: '0.18em' }}
          >
            Eight-pointed star
          </div>
          <div
            className="cor-body"
            style={{ color: 'var(--text-secondary)', fontSize: 12, textAlign: 'center' }}
          >
            Borders, banners, watermarks
          </div>
        </div>
        <div
          className="cor-card"
          style={{
            padding: 32,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 16,
            position: 'relative',
          }}
        >
          <div style={{ position: 'relative', width: 80, height: 80 }}>
            <div style={{ position: 'absolute', top: 0, left: 0 }}>
              <ArabesqueCorner size={36} color="var(--brand-brass)" orientation="tl" />
            </div>
            <div style={{ position: 'absolute', top: 0, right: 0 }}>
              <ArabesqueCorner size={36} color="var(--brand-brass)" orientation="tr" />
            </div>
            <div style={{ position: 'absolute', bottom: 0, left: 0 }}>
              <ArabesqueCorner size={36} color="var(--brand-brass)" orientation="bl" />
            </div>
            <div style={{ position: 'absolute', bottom: 0, right: 0 }}>
              <ArabesqueCorner size={36} color="var(--brand-brass)" orientation="br" />
            </div>
          </div>
          <div
            className="cor-body cor-uppercase"
            style={{ color: 'var(--brand-brass)', fontSize: 11, letterSpacing: '0.18em' }}
          >
            Arabesque corners
          </div>
          <div
            className="cor-body"
            style={{ color: 'var(--text-secondary)', fontSize: 12, textAlign: 'center' }}
          >
            Major panels & modals
          </div>
        </div>
        <div
          className="cor-card"
          style={{
            padding: 32,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 16,
          }}
        >
          <svg width="80" height="80" viewBox="0 0 80 80">
            <circle
              cx="40"
              cy="40"
              r="36"
              fill="none"
              stroke="var(--brand-brass)"
              strokeWidth="0.6"
            />
            <circle
              cx="40"
              cy="40"
              r="30"
              fill="none"
              stroke="var(--brand-brass-deep)"
              strokeWidth="0.6"
            />
            <circle
              cx="40"
              cy="40"
              r="22"
              fill="none"
              stroke="var(--brand-brass)"
              strokeWidth="0.6"
            />
            {Array.from({ length: 24 }).map((_, i) => {
              const a = (i / 24) * Math.PI * 2;
              return (
                <line
                  key={i}
                  x1={40 + Math.cos(a) * 36}
                  y1={40 + Math.sin(a) * 36}
                  x2={40 + Math.cos(a) * 30}
                  y2={40 + Math.sin(a) * 30}
                  stroke="var(--brand-brass-deep)"
                  strokeWidth="0.5"
                />
              );
            })}
          </svg>
          <div
            className="cor-body cor-uppercase"
            style={{ color: 'var(--brand-brass)', fontSize: 11, letterSpacing: '0.18em' }}
          >
            Astrolabe rings
          </div>
          <div
            className="cor-body"
            style={{ color: 'var(--text-secondary)', fontSize: 12, textAlign: 'center' }}
          >
            Dice, attribute circles
          </div>
        </div>
        <div
          className="cor-card"
          style={{
            padding: 32,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 16,
            justifyContent: 'center',
          }}
        >
          <Swash width={120} />
          <div
            className="cor-body cor-uppercase"
            style={{ color: 'var(--brand-brass)', fontSize: 11, letterSpacing: '0.18em' }}
          >
            Calligraphic underline
          </div>
          <div
            className="cor-body"
            style={{ color: 'var(--text-secondary)', fontSize: 12, textAlign: 'center' }}
          >
            Replaces section divider
          </div>
        </div>
      </div>

      {/* MOTION */}
      <PanelTitle size="lg">Motion Tokens</PanelTitle>
      <div
        className="cor-card"
        style={{ padding: 32, display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 24 }}
      >
        {[
          ['--motion-duration-fast', '100ms', 'Hover, micro-feedback'],
          ['--motion-duration', '200ms', 'Standard transitions'],
          ['--motion-duration-slow', '400ms', 'Dice settle, panel reveals'],
          ['--motion-duration-ceremony', '600ms', 'Push glow, prayer rituals'],
        ].map(([n, v, use]) => (
          <div key={n}>
            <div
              className="cor-mono"
              style={{ color: 'var(--brand-brass-light)', fontSize: 12, marginBottom: 4 }}
            >
              {n}
            </div>
            <div
              className="cor-mono"
              style={{
                color: 'var(--text-primary)',
                fontSize: 20,
                fontWeight: 700,
                marginBottom: 8,
              }}
            >
              {v}
            </div>
            <div className="cor-body" style={{ color: 'var(--text-secondary)', fontSize: 12 }}>
              {use}
            </div>
          </div>
        ))}
      </div>

      {/* Footer note */}
      <div
        style={{
          marginTop: 64,
          padding: '32px 0',
          borderTop: '1px solid var(--brand-brass-deep)',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <div
          className="cor-body"
          style={{ color: 'var(--text-secondary)', fontSize: 12, fontStyle: 'italic' }}
        >
          “Stylelint forbids hex literals in <span className="cor-mono">apps/web</span> and{' '}
          <span className="cor-mono">packages/ui</span>. Renaming a token is an ADR.”
        </div>
        <div
          className="cor-body cor-uppercase"
          style={{ color: 'var(--brand-brass)', fontSize: 11, letterSpacing: '0.3em' }}
        >
          v2.0 · Dark-first
        </div>
      </div>
    </div>
  );
};

window.TokensCard = TokensCard;
