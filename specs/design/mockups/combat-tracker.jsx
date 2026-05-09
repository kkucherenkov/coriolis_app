// Combat Tracker
const CombatTracker = () => {
  const combatants = [
    {
      init: 12,
      name: 'Tariq al-Asari',
      sub: 'Player · Pilot',
      portrait: 'TA',
      hp: 11,
      maxHp: 12,
      mp: 8,
      maxMp: 10,
      conds: ['Sleepless'],
      active: true,
      type: 'pc',
    },
    {
      init: 10,
      name: 'Yara Zenith',
      sub: 'Player · Mystic',
      portrait: 'YZ',
      hp: 9,
      maxHp: 10,
      mp: 6,
      maxMp: 12,
      conds: [],
      active: false,
      type: 'pc',
    },
    {
      init: 9,
      name: 'Zenith Cultist α',
      sub: 'NPC · Mook',
      portrait: 'C',
      hp: 4,
      maxHp: 6,
      conds: ['Bleeding'],
      active: false,
      type: 'npc',
    },
    {
      init: 8,
      name: 'Zenith Cultist β',
      sub: 'NPC · Mook',
      portrait: 'C',
      hp: 6,
      maxHp: 6,
      conds: [],
      active: false,
      type: 'npc',
    },
    {
      init: 6,
      name: 'Brother Kassim',
      sub: 'Player · Preacher',
      portrait: 'BK',
      hp: 7,
      maxHp: 11,
      mp: 4,
      maxMp: 8,
      conds: ['Thirsty'],
      active: false,
      type: 'pc',
    },
    {
      init: 4,
      name: 'The Hierophant',
      sub: 'NPC · Boss',
      portrait: 'H',
      hp: 18,
      maxHp: 24,
      conds: [],
      active: false,
      type: 'boss',
    },
  ];

  return (
    <div className="cor-surface-void" style={{ minHeight: '100%' }}>
      {/* Header */}
      <div
        style={{
          padding: '24px 40px',
          borderBottom: '1px solid var(--brand-brass-deep)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <div>
          <div
            className="cor-body cor-uppercase"
            style={{
              fontSize: 11,
              color: 'var(--brand-brass)',
              letterSpacing: '0.24em',
              marginBottom: 6,
            }}
          >
            The Mercy of Kua · Session 12
          </div>
          <h1
            className="cor-display cor-track-04"
            style={{ fontSize: 32, color: 'var(--brand-brass-light)', margin: 0, fontWeight: 400 }}
          >
            Encounter · Temple of Whispers
          </h1>
        </div>
        <div style={{ display: 'flex', gap: 28, alignItems: 'center' }}>
          <div style={{ textAlign: 'center' }}>
            <div
              className="cor-body cor-uppercase"
              style={{ fontSize: 10, color: 'var(--brand-brass)', letterSpacing: '0.18em' }}
            >
              Round
            </div>
            <div
              className="cor-mono"
              style={{ fontSize: 32, fontWeight: 700, color: 'var(--text-primary)' }}
            >
              3
            </div>
          </div>
          <div style={{ width: 1, height: 56, background: 'var(--brand-brass-deep)' }} />
          <div style={{ textAlign: 'center', position: 'relative' }}>
            <div
              className="cor-body cor-uppercase"
              style={{
                fontSize: 10,
                color: '#A88BC8',
                letterSpacing: '0.18em',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: 6,
              }}
            >
              <span
                style={{
                  width: 8,
                  height: 8,
                  borderRadius: '50%',
                  background: 'var(--state-darkness)',
                  boxShadow: '0 0 12px var(--state-darkness)',
                }}
              />
              Darkness Points
            </div>
            <div className="cor-mono" style={{ fontSize: 32, fontWeight: 700, color: '#C5A3D8' }}>
              7
            </div>
          </div>
        </div>
      </div>

      {/* Rows */}
      <div style={{ padding: '20px 40px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {combatants.map((c, i) => (
          <div
            key={i}
            style={{
              position: 'relative',
              display: 'grid',
              gridTemplateColumns: '40px 56px 56px 1fr auto auto',
              alignItems: 'center',
              gap: 16,
              height: 64,
              padding: '0 16px',
              background: c.active ? 'rgba(212,169,92,0.07)' : 'var(--surface-night)',
              border: '1px solid ' + (c.active ? 'var(--brand-brass)' : 'rgba(166,124,40,0.3)'),
              borderLeft: c.active
                ? '4px solid var(--brand-brass)'
                : '1px solid rgba(166,124,40,0.3)',
              borderRadius: 4,
              boxShadow: c.active ? 'inset 0 0 24px rgba(212,169,92,0.08)' : 'none',
            }}
          >
            {/* Drag handle + active marker */}
            <div
              style={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                color: 'var(--brand-brass-deep)',
              }}
            >
              {c.active ? (
                <span
                  className="cor-display"
                  style={{ color: 'var(--brand-brass-light)', fontSize: 18 }}
                >
                  ▶
                </span>
              ) : (
                <span style={{ fontSize: 14, lineHeight: 1, letterSpacing: 1 }}>⋮⋮</span>
              )}
            </div>
            {/* Init */}
            <div style={{ textAlign: 'center' }}>
              <div
                className="cor-body cor-uppercase"
                style={{ fontSize: 9, color: 'var(--brand-brass)', letterSpacing: '0.16em' }}
              >
                Init
              </div>
              <div
                className="cor-mono"
                style={{ fontSize: 20, fontWeight: 700, color: 'var(--text-primary)' }}
              >
                {c.init}
              </div>
            </div>
            {/* Portrait */}
            <Portrait initials={c.portrait} size={48} />
            {/* Name + conditions */}
            <div>
              <div
                className="cor-display cor-track-04"
                style={{
                  fontSize: 18,
                  color:
                    c.type === 'boss' ? 'var(--state-crimson-bright)' : 'var(--brand-brass-light)',
                  lineHeight: 1.1,
                }}
              >
                {c.name}
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 4 }}>
                <span className="cor-body" style={{ fontSize: 11, color: 'var(--text-secondary)' }}>
                  {c.sub}
                </span>
                {c.conds.map((cd) => (
                  <span
                    key={cd}
                    className="cor-chip cor-chip--cond"
                    style={{ fontSize: 9, padding: '2px 7px' }}
                  >
                    {cd}
                  </span>
                ))}
              </div>
            </div>
            {/* HP / MP */}
            <div style={{ display: 'flex', gap: 20, alignItems: 'center' }}>
              <div style={{ textAlign: 'right' }}>
                <div
                  className="cor-body cor-uppercase"
                  style={{ fontSize: 9, color: 'var(--brand-brass)', letterSpacing: '0.16em' }}
                >
                  HP
                </div>
                <div
                  className="cor-mono"
                  style={{
                    fontSize: 18,
                    fontWeight: 700,
                    color:
                      c.hp / c.maxHp < 0.4 ? 'var(--state-crimson-bright)' : 'var(--text-primary)',
                  }}
                >
                  {c.hp}
                  <span style={{ color: 'var(--text-secondary)', fontSize: 12 }}>/{c.maxHp}</span>
                </div>
              </div>
              {c.mp !== undefined && (
                <div style={{ textAlign: 'right' }}>
                  <div
                    className="cor-body cor-uppercase"
                    style={{
                      fontSize: 9,
                      color: 'var(--state-mystic-teal)',
                      letterSpacing: '0.16em',
                    }}
                  >
                    MP
                  </div>
                  <div
                    className="cor-mono"
                    style={{ fontSize: 18, fontWeight: 700, color: 'var(--text-primary)' }}
                  >
                    {c.mp}
                    <span style={{ color: 'var(--text-secondary)', fontSize: 12 }}>/{c.maxMp}</span>
                  </div>
                </div>
              )}
            </div>
            {/* Actions */}
            <div style={{ display: 'flex', gap: 6 }}>
              <ActionBtn>−</ActionBtn>
              <ActionBtn>+</ActionBtn>
              <ActionBtn>⋯</ActionBtn>
            </div>
          </div>
        ))}
      </div>

      {/* Bottom toolbar */}
      <div
        style={{
          position: 'sticky',
          bottom: 0,
          padding: '20px 40px',
          background: 'var(--surface-night)',
          borderTop: '1px solid var(--brand-brass-deep)',
          display: 'flex',
          gap: 12,
          justifyContent: 'flex-end',
        }}
      >
        <button className="cor-btn cor-btn--ghost">End encounter</button>
        <button className="cor-btn cor-btn--secondary">End round</button>
        <button className="cor-btn">Next turn →</button>
      </div>
    </div>
  );
};

const ActionBtn = ({ children }) => (
  <button
    style={{
      width: 32,
      height: 32,
      border: '1px solid var(--brand-brass-deep)',
      background: 'transparent',
      color: 'var(--brand-brass)',
      borderRadius: 4,
      cursor: 'pointer',
      fontSize: 14,
      fontFamily: 'JetBrains Mono',
    }}
  >
    {children}
  </button>
);

window.CombatTracker = CombatTracker;
