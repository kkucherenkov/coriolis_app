// Ship Sheet — Madara
const ShipSheet = () => (
  <div className="cor-surface-void" style={{ minHeight: '100%' }}>
    {/* Hero */}
    <div
      style={{
        position: 'relative',
        padding: '40px 56px 28px',
        borderBottom: '1px solid var(--brand-brass-deep)',
        background: 'linear-gradient(180deg, #15193F 0%, #0B0E2C 100%)',
      }}
    >
      <div style={{ position: 'absolute', top: 12, left: 12 }}>
        <ArabesqueCorner size={48} color="var(--brand-brass)" orientation="tl" />
      </div>
      <div style={{ position: 'absolute', top: 12, right: 12 }}>
        <ArabesqueCorner size={48} color="var(--brand-brass)" orientation="tr" />
      </div>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '160px 1fr auto',
          gap: 36,
          alignItems: 'center',
        }}
      >
        {/* Ship silhouette placeholder — astrolabe-ringed disc */}
        <div
          style={{
            width: 160,
            height: 100,
            position: 'relative',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <svg viewBox="0 0 160 100" width="160" height="100">
            <ellipse
              cx="80"
              cy="50"
              rx="70"
              ry="36"
              fill="none"
              stroke="var(--brand-brass-deep)"
              strokeWidth="0.6"
            />
            <ellipse
              cx="80"
              cy="50"
              rx="58"
              ry="28"
              fill="none"
              stroke="var(--brand-brass-deep)"
              strokeWidth="0.6"
            />
            {/* striped placeholder ship body */}
            <g transform="translate(36, 36)" stroke="var(--brand-brass)" strokeWidth="0.8">
              <rect x="0" y="0" width="88" height="28" fill="rgba(212,169,92,0.06)" />
              <line x1="0" y1="7" x2="88" y2="7" />
              <line x1="0" y1="14" x2="88" y2="14" />
              <line x1="0" y1="21" x2="88" y2="21" />
              <text
                x="44"
                y="18"
                fill="var(--brand-brass-light)"
                textAnchor="middle"
                fontFamily="JetBrains Mono"
                fontSize="9"
                stroke="none"
              >
                SHIP RENDER
              </text>
            </g>
          </svg>
        </div>
        <div>
          <div
            className="cor-body cor-uppercase"
            style={{
              fontSize: 11,
              color: 'var(--brand-brass)',
              letterSpacing: '0.3em',
              marginBottom: 6,
            }}
          >
            Class III · Freighter
          </div>
          <h1
            className="cor-display cor-track-04"
            style={{
              fontSize: 44,
              color: 'var(--brand-brass-light)',
              margin: 0,
              fontWeight: 400,
              lineHeight: 1.05,
            }}
          >
            Madara
          </h1>
          <Swash width={140} />
          <div
            className="cor-body"
            style={{ fontSize: 13, color: 'var(--text-secondary)', marginTop: 10 }}
          >
            Crew of the Madara · Captain: Tariq al-Asari
          </div>
        </div>
        <div style={{ display: 'flex', gap: 24 }}>
          <ShipStatHero label="Hull" v={6} m={8} />
          <ShipStatHero label="Energy" v={4} m={6} mystic />
        </div>
      </div>
    </div>

    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 24, padding: '32px 56px' }}>
      {/* LEFT — Ship Stats + Modules */}
      <div className="cor-card" style={{ padding: 24 }}>
        <PanelTitle size="md">Ship Statistics</PanelTitle>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 18 }}>
          {[
            ['Maneuverability', 2, 5],
            ['Signature', 4, 5],
            ['Armor', 3, 5],
            ['Hull', 6, 8],
            ['Energy', 4, 6],
            ['Cargo', 18, 24],
          ].map(([k, v, m]) => (
            <div key={k}>
              <div
                className="cor-body cor-uppercase"
                style={{
                  fontSize: 10,
                  color: 'var(--brand-brass)',
                  letterSpacing: '0.14em',
                  marginBottom: 4,
                }}
              >
                {k}
              </div>
              <div
                className="cor-mono"
                style={{ fontSize: 20, fontWeight: 700, color: 'var(--text-primary)' }}
              >
                {v}
                <span style={{ color: 'var(--text-secondary)', fontSize: 12 }}> / {m}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* RIGHT — Modules */}
      <div className="cor-card" style={{ padding: 24 }}>
        <PanelTitle size="md">Modules & Features</PanelTitle>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {[
            { n: 'Graviton Projector', s: 'Heavy weapon · Bay 1' },
            { n: 'EMP cannon', s: 'Bay 2' },
            { n: 'Smuggler hold', s: 'Concealed · 4 enc' },
            { n: 'Workshop', s: 'Bonus +2 to Technology' },
            { n: 'Auxiliary thrusters', s: 'Damaged · −1 Maneuverability' },
          ].map((m) => (
            <div
              key={m.n}
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '10px 12px',
                background: 'var(--surface-void)',
                border: '1px solid rgba(166,124,40,0.35)',
                borderRadius: 4,
              }}
            >
              <span className="cor-body" style={{ fontSize: 13, color: 'var(--text-primary)' }}>
                {m.n}
              </span>
              <span
                className="cor-body"
                style={{
                  fontSize: 11,
                  color: 'var(--text-secondary)',
                  fontStyle: m.s.includes('Damaged') ? 'italic' : 'normal',
                }}
              >
                {m.s}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Crew row spanning */}
      <div className="cor-card" style={{ padding: 24, gridColumn: '1 / -1' }}>
        <PanelTitle size="md">Crew</PanelTitle>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 12 }}>
          {[
            { i: 'TA', n: 'Tariq al-Asari', r: 'Captain · Pilot', g: 'T' },
            { i: 'YZ', n: 'Yara Zenith', r: 'Mystic', g: 'F' },
            { i: 'BK', n: 'Brother Kassim', r: 'Preacher', g: 'M' },
            { i: 'NV', n: 'Nox Vael', r: 'Engineer', g: 'H' },
            { i: '?', n: 'Open berth', r: '— vacant —', g: null },
          ].map((c) => (
            <div
              key={c.i}
              style={{
                padding: 14,
                background: 'var(--surface-void)',
                border: '1px solid rgba(166,124,40,0.35)',
                borderRadius: 4,
                textAlign: 'center',
                opacity: c.g ? 1 : 0.4,
              }}
            >
              {c.g ? (
                <Portrait initials={c.i} size={56} />
              ) : (
                <div
                  style={{
                    width: 56,
                    height: 56,
                    borderRadius: '50%',
                    border: '1px dashed var(--brand-brass-deep)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    margin: '0 auto',
                    color: 'var(--brand-brass)',
                  }}
                >
                  +
                </div>
              )}
              <div
                className="cor-display cor-track-04"
                style={{ fontSize: 13, color: 'var(--brand-brass-light)', marginTop: 8 }}
              >
                {c.n}
              </div>
              <div className="cor-body" style={{ fontSize: 10, color: 'var(--text-secondary)' }}>
                {c.r}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  </div>
);

const ShipStatHero = ({ label, v, m, mystic }) => (
  <div style={{ textAlign: 'center', minWidth: 96 }}>
    <div
      className="cor-body cor-uppercase"
      style={{
        fontSize: 11,
        color: mystic ? 'var(--state-mystic-teal)' : 'var(--brand-brass)',
        letterSpacing: '0.18em',
        marginBottom: 4,
      }}
    >
      {label}
    </div>
    <div
      className="cor-mono"
      style={{ fontSize: 32, fontWeight: 700, color: 'var(--text-primary)', lineHeight: 1 }}
    >
      {v}
      <span style={{ color: 'var(--text-secondary)', fontSize: 18 }}> / {m}</span>
    </div>
  </div>
);

window.ShipSheet = ShipSheet;
