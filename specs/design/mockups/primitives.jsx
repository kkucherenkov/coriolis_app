// Shared primitives for Coriolis mockups.
// Eight-pointed star (rub el hizb), arabesque corners, Icon medallion, dice, etc.

const StarOrnament = ({ size = 24, color = 'currentColor', opacity = 1 }) => (
  <svg width={size} height={size} viewBox="0 0 32 32" style={{ opacity, display: 'block' }}>
    {/* Two overlapping squares forming an eight-pointed star */}
    <g fill="none" stroke={color} strokeWidth="1.2">
      <rect x="6" y="6" width="20" height="20" />
      <rect x="6" y="6" width="20" height="20" transform="rotate(45 16 16)" />
      <circle cx="16" cy="16" r="2.2" fill={color} stroke="none" />
    </g>
  </svg>
);

const StarFilled = ({ size = 24, color = 'currentColor' }) => (
  <svg width={size} height={size} viewBox="0 0 32 32" style={{ display: 'block' }}>
    <g fill={color} fillOpacity="0.18" stroke={color} strokeWidth="1">
      <rect x="6" y="6" width="20" height="20" />
      <rect x="6" y="6" width="20" height="20" transform="rotate(45 16 16)" />
    </g>
    <circle cx="16" cy="16" r="2" fill={color} />
  </svg>
);

// Decorative arabesque corner — stroke only, never filled.
// orientation: 'tl' | 'tr' | 'bl' | 'br'
const ArabesqueCorner = ({ size = 56, color = 'var(--brand-brass-deep)', orientation = 'tl' }) => {
  const rot = { tl: 0, tr: 90, br: 180, bl: 270 }[orientation];
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" style={{ display: 'block', transform: `rotate(${rot}deg)` }}>
      <g fill="none" stroke={color} strokeWidth="1" strokeLinecap="round">
        <path d="M2 22 L2 2 L22 2" />
        <path d="M2 30 Q2 14 14 8 Q22 4 30 2" />
        <path d="M8 16 Q14 12 18 12 Q22 12 22 16 Q22 20 18 20 Q14 20 14 16" />
        <path d="M14 4 L18 8 M22 8 L26 4" />
        <circle cx="32" cy="2" r="1.4" />
        <circle cx="2" cy="32" r="1.4" />
      </g>
    </svg>
  );
};

// Calligraphic underline swash beneath section titles
const Swash = ({ width = 80, color = 'var(--brand-brass)' }) => (
  <svg width={width} height="10" viewBox="0 0 120 10" style={{ display: 'block', marginTop: 6 }}>
    <path
      d="M2 5 Q12 2 24 5 Q40 9 60 5 Q80 1 96 5 Q108 8 118 5"
      fill="none" stroke={color} strokeWidth="1.2" strokeLinecap="round"
    />
    <circle cx="60" cy="5" r="1.6" fill={color} />
  </svg>
);

// Icon medallion — Forum monogram letter inside a brass disc with concentric rings
const IconMedallion = ({ letter, size = 64, glow = false }) => (
  <div style={{ position: 'relative', width: size, height: size }}>
    {glow && (
      <div style={{
        position: 'absolute', inset: -6,
        borderRadius: '50%',
        boxShadow: '0 0 24px 4px rgba(43,163,160,0.55)',
        background: 'radial-gradient(circle, rgba(43,163,160,0.25), transparent 70%)',
      }} />
    )}
    <svg width={size} height={size} viewBox="0 0 64 64" style={{ position: 'relative' }}>
      <defs>
        <radialGradient id={`mg${letter}`} cx="50%" cy="40%" r="60%">
          <stop offset="0%" stopColor="#F4E4B8" />
          <stop offset="60%" stopColor="#D4A95C" />
          <stop offset="100%" stopColor="#A67C28" />
        </radialGradient>
      </defs>
      <circle cx="32" cy="32" r="30" fill={`url(#mg${letter})`} />
      <circle cx="32" cy="32" r="28" fill="none" stroke="#6B4E1A" strokeWidth="0.6" />
      <circle cx="32" cy="32" r="24" fill="none" stroke="#6B4E1A" strokeWidth="0.4" />
      {/* tiny tick marks like an astrolabe */}
      {Array.from({ length: 16 }).map((_, i) => {
        const a = (i / 16) * Math.PI * 2;
        const r1 = 28, r2 = 26;
        return (
          <line
            key={i}
            x1={32 + Math.cos(a) * r1}
            y1={32 + Math.sin(a) * r1}
            x2={32 + Math.cos(a) * r2}
            y2={32 + Math.sin(a) * r2}
            stroke="#6B4E1A" strokeWidth="0.5"
          />
        );
      })}
      <text
        x="32" y="40" textAnchor="middle"
        fontFamily="Forum, serif"
        fontSize={size * 0.5}
        fill="#0B0E2C"
        style={{ letterSpacing: '0.04em' }}
      >{letter}</text>
    </svg>
  </div>
);

// Single die face with N pips — brass disc, optional teal glow on 6
const Die = ({ value = 1, size = 44, hit = false, pushed = false }) => {
  const positions = {
    1: [[.5,.5]],
    2: [[.25,.25],[.75,.75]],
    3: [[.25,.25],[.5,.5],[.75,.75]],
    4: [[.25,.25],[.75,.25],[.25,.75],[.75,.75]],
    5: [[.25,.25],[.75,.25],[.5,.5],[.25,.75],[.75,.75]],
    6: [[.25,.25],[.75,.25],[.25,.5],[.75,.5],[.25,.75],[.75,.75]],
  };
  const isHit = hit || value === 6;
  return (
    <div style={{
      position: 'relative',
      width: size, height: size,
      borderRadius: 6,
      background: isHit
        ? 'linear-gradient(140deg, #F4E4B8 0%, #D4A95C 60%, #A67C28 100%)'
        : 'linear-gradient(140deg, #D4A95C 0%, #A67C28 60%, #6B4E1A 100%)',
      boxShadow: isHit
        ? '0 0 16px 2px rgba(43,163,160,0.7), inset 0 0 0 1px #F4E4B8'
        : 'inset 0 0 0 1px #6B4E1A',
      opacity: pushed ? 0.95 : 1,
    }}>
      {positions[value].map(([x, y], i) => (
        <div key={i} style={{
          position: 'absolute',
          left: `${x * 100}%`, top: `${y * 100}%`,
          width: size * 0.13, height: size * 0.13,
          borderRadius: '50%',
          background: '#0B0E2C',
          transform: 'translate(-50%, -50%)',
        }} />
      ))}
      {isHit && (
        <div style={{
          position: 'absolute', inset: 0, borderRadius: 6,
          boxShadow: 'inset 0 0 8px rgba(43,163,160,0.6)',
          pointerEvents: 'none',
        }} />
      )}
    </div>
  );
};

// Stat block: label + mono value + dots
const StatBlock = ({ label, value, max = 5, mono = true }) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
    <div className="cor-display cor-uppercase" style={{ fontSize: 12, color: 'var(--brand-brass-light)', letterSpacing: '0.10em' }}>{label}</div>
    <div style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
      {mono && (
        <span className="cor-mono" style={{ fontSize: 22, fontWeight: 700, color: 'var(--text-primary)' }}>{value}</span>
      )}
      <span className="cor-dots">
        {Array.from({ length: max }).map((_, i) => (
          <span key={i} className={`cor-dot ${i < value ? 'cor-dot--filled' : ''}`} />
        ))}
      </span>
    </div>
  </div>
);

// Skill row — dense, for the skills list
const SkillRow = ({ name, attr, rank }) => (
  <div style={{
    display: 'grid', gridTemplateColumns: '1fr auto auto auto',
    alignItems: 'center', gap: 12,
    padding: '8px 4px',
    borderBottom: '1px solid rgba(166,124,40,0.25)',
  }}>
    <div className="cor-body" style={{ fontSize: 14, color: 'var(--text-primary)' }}>{name}</div>
    <div className="cor-body cor-uppercase" style={{ fontSize: 10, color: 'var(--brand-brass)', letterSpacing: '0.10em' }}>{attr}</div>
    <span className="cor-dots">
      {Array.from({ length: 5 }).map((_, i) => (
        <span key={i} className={`cor-dot ${i < rank ? 'cor-dot--filled' : ''}`} />
      ))}
    </span>
    <span className="cor-mono" style={{ fontSize: 14, color: 'var(--text-primary)', minWidth: 14, textAlign: 'right' }}>{rank}</span>
  </div>
);

// Wordmark — Forum, with a brass swash flourish
const Wordmark = ({ size = 48 }) => (
  <div style={{ display: 'inline-flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
    <div className="cor-display cor-track-10" style={{
      fontSize: size,
      color: 'var(--brand-brass-light)',
      textTransform: 'uppercase',
      lineHeight: 1,
    }}>Coriolis</div>
    <Swash width={size * 2.4} />
    <div className="cor-body cor-uppercase" style={{
      fontSize: size * 0.18,
      color: 'var(--brand-brass)',
      letterSpacing: '0.4em',
      marginTop: 2,
    }}>Companion</div>
  </div>
);

// Portrait medallion — initials inside a brass ring
const Portrait = ({ initials = 'NA', size = 96 }) => (
  <div style={{
    width: size, height: size, borderRadius: '50%',
    border: '1px solid var(--brand-brass-deep)',
    boxShadow: 'inset 0 0 0 1px var(--brand-brass-shadow)',
    background: 'linear-gradient(160deg, #252B5C 0%, #15193F 60%, #0B0E2C 100%)',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    position: 'relative',
  }}>
    {/* concentric brass tick ring */}
    <svg viewBox="0 0 100 100" width={size} height={size} style={{ position: 'absolute', inset: 0 }}>
      <circle cx="50" cy="50" r="46" fill="none" stroke="var(--brand-brass-deep)" strokeWidth="0.4" />
      {Array.from({ length: 24 }).map((_, i) => {
        const a = (i / 24) * Math.PI * 2;
        return (
          <line key={i}
            x1={50 + Math.cos(a) * 46} y1={50 + Math.sin(a) * 46}
            x2={50 + Math.cos(a) * 43} y2={50 + Math.sin(a) * 43}
            stroke="var(--brand-brass-deep)" strokeWidth="0.4" />
        );
      })}
    </svg>
    <span className="cor-display cor-track-04" style={{ fontSize: size * 0.36, color: 'var(--brand-brass-light)' }}>{initials}</span>
  </div>
);

// Panel header: Forum title + swash
const PanelTitle = ({ children, size = 'md' }) => {
  const sizes = { sm: 16, md: 22, lg: 28 };
  return (
    <div style={{ marginBottom: 14 }}>
      <h3 className="cor-display cor-track-04" style={{
        fontSize: sizes[size], color: 'var(--brand-brass-light)',
        margin: 0, fontWeight: 400, lineHeight: 1.2,
      }}>{children}</h3>
      <Swash width={size === 'lg' ? 110 : 70} />
    </div>
  );
};

// The Nine Icons (with monogram letters and one-line domains)
const NINE_ICONS = [
  { name: 'The Lady of Tears', letter: 'L', domain: 'Patron of mourners and the dispossessed' },
  { name: 'The Traveler', letter: 'T', domain: 'Patron of explorers and pilots' },
  { name: 'The Messenger', letter: 'M', domain: 'Patron of envoys and signal-keepers' },
  { name: 'The Merchant', letter: 'C', domain: 'Patron of traders and brokers' },
  { name: 'The Dancer', letter: 'D', domain: 'Patron of artists and gunfighters' },
  { name: 'The Gambler', letter: 'G', domain: 'Patron of risk and the long shot' },
  { name: 'The Judge', letter: 'J', domain: 'Patron of law and the unyielding' },
  { name: 'The Faceless One', letter: 'F', domain: 'Patron of mystics and the hidden' },
  { name: 'The Deckhand', letter: 'H', domain: 'Patron of crewmen and the working hand' },
];

Object.assign(window, {
  StarOrnament, StarFilled, ArabesqueCorner, Swash,
  IconMedallion, Die, StatBlock, SkillRow, Wordmark,
  Portrait, PanelTitle, NINE_ICONS,
});
