// GM Session — Overview tab
const GmSession = () => (
  <div className="cor-surface-void" style={{ minHeight: '100%' }}>
    {/* Header */}
    <div style={{ padding: '24px 40px', borderBottom: '1px solid var(--brand-brass-deep)' }}>
      <div
        className="cor-body cor-uppercase"
        style={{
          fontSize: 11,
          color: 'var(--brand-brass)',
          letterSpacing: '0.24em',
          marginBottom: 6,
        }}
      >
        GM Session · Live
      </div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <h1
          className="cor-display cor-track-04"
          style={{ fontSize: 36, color: 'var(--brand-brass-light)', margin: 0, fontWeight: 400 }}
        >
          The Mercy of Kua
        </h1>
        <div style={{ display: 'flex', gap: 18, alignItems: 'center' }}>
          <span className="cor-chip">Session 12</span>
          <span className="cor-chip cor-chip--mystic">
            <span
              style={{
                width: 6,
                height: 6,
                borderRadius: '50%',
                background: 'var(--state-mystic-teal)',
              }}
            />
            4 players online
          </span>
        </div>
      </div>
    </div>

    {/* Tab strip */}
    <div
      style={{
        display: 'flex',
        padding: '0 40px',
        borderBottom: '1px solid var(--brand-brass-deep)',
      }}
    >
      {['Overview', 'Encounters', 'Crew'].map((t, i) => (
        <span key={t} className={`cor-tab ${i === 0 ? 'cor-tab--active' : ''}`}>
          {t}
        </span>
      ))}
    </div>

    {/* Body — 3 columns */}
    <div
      style={{
        display: 'grid',
        gridTemplateColumns: '1fr 1.2fr 1fr',
        gap: 24,
        padding: '28px 40px',
      }}
    >
      {/* DP Counter */}
      <div className="cor-card" style={{ padding: 24, position: 'relative' }}>
        <PanelTitle size="sm">Darkness Points</PanelTitle>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '12px 0',
          }}
        >
          <div style={{ position: 'relative' }}>
            <div
              className="cor-mono"
              style={{ fontSize: 56, fontWeight: 700, color: '#C5A3D8', lineHeight: 1 }}
            >
              7
            </div>
            <div
              style={{
                position: 'absolute',
                top: -4,
                right: -16,
                width: 12,
                height: 12,
                borderRadius: '50%',
                background: 'var(--state-darkness)',
                boxShadow: '0 0 18px var(--state-darkness)',
              }}
            />
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            <button
              style={{
                padding: '6px 16px',
                background: 'rgba(91,42,120,0.2)',
                border: '1px solid #A88BC8',
                color: '#E1C8F0',
                borderRadius: 4,
                fontSize: 12,
                cursor: 'pointer',
                letterSpacing: '0.06em',
              }}
            >
              + Spend
            </button>
            <button
              style={{
                padding: '6px 16px',
                background: 'transparent',
                border: '1px solid var(--brand-brass-deep)',
                color: 'var(--brand-brass)',
                borderRadius: 4,
                fontSize: 12,
                cursor: 'pointer',
              }}
            >
              − Pool
            </button>
          </div>
        </div>
        <div
          className="cor-body"
          style={{
            fontSize: 11,
            color: 'var(--text-secondary)',
            fontStyle: 'italic',
            marginTop: 8,
          }}
        >
          Updated via Centrifugo · 2s ago by Tariq's push
        </div>
        <div style={{ marginTop: 16, paddingTop: 16, borderTop: '1px solid rgba(166,124,40,0.3)' }}>
          <div
            className="cor-body cor-uppercase"
            style={{
              fontSize: 10,
              color: 'var(--brand-brass)',
              letterSpacing: '0.14em',
              marginBottom: 8,
            }}
          >
            Recent
          </div>
          {[
            ['+1', 'Tariq pushed Pilot · Evade', '2s ago'],
            ['+1', 'Yara pushed Mystic · Premonition', '5m ago'],
            ['−2', 'GM spent on Hierophant ambush', '12m ago'],
          ].map(([d, n, t], i) => (
            <div
              key={i}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                fontSize: 12,
                padding: '6px 0',
                borderBottom: '1px solid rgba(166,124,40,0.15)',
              }}
            >
              <span
                className="cor-mono"
                style={{
                  color: d.startsWith('+') ? '#C5A3D8' : 'var(--state-success)',
                  minWidth: 24,
                }}
              >
                {d}
              </span>
              <span className="cor-body" style={{ flex: 1, color: 'var(--text-primary)' }}>
                {n}
              </span>
              <span className="cor-body" style={{ color: 'var(--text-secondary)', fontSize: 10 }}>
                {t}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Notes */}
      <div className="cor-card" style={{ padding: 24 }}>
        <PanelTitle size="sm">Session Notes</PanelTitle>
        <div
          className="cor-body"
          style={{ fontSize: 13, color: 'var(--text-primary)', lineHeight: 1.6 }}
        >
          <p style={{ marginTop: 0 }}>
            The crew docked at Kua Orbital after the Madara's auxiliary thrusters failed. The
            Hierophant's cult has been sighted at the Temple of Whispers — Yara's premonition placed
            them three levels below.
          </p>
          <p>
            Brother Kassim recognises the cult's sigil from his preacher days. The Lady of Tears
            watches.
          </p>
          <div
            style={{
              padding: 14,
              background: 'rgba(43,163,160,0.08)',
              border: '1px solid rgba(43,163,160,0.4)',
              borderRadius: 4,
              margin: '14px 0',
            }}
          >
            <div
              className="cor-body cor-uppercase"
              style={{
                fontSize: 10,
                color: 'var(--state-mystic-teal)',
                letterSpacing: '0.16em',
                marginBottom: 6,
              }}
            >
              GM Reminder
            </div>
            <span style={{ fontSize: 12 }}>
              If players reach the inner sanctum, trigger the Faceless One vision sequence. Spend 2
              DP.
            </span>
          </div>
          <p style={{ marginBottom: 0 }}>
            Open thread: Tariq still owes the Algol consortium for his ship. The collector arrives
            next session.
          </p>
        </div>
      </div>

      {/* Crew (read-only sheets) */}
      <div className="cor-card" style={{ padding: 24 }}>
        <PanelTitle size="sm">Crew Status</PanelTitle>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {[
            { i: 'TA', n: 'Tariq al-Asari', hp: 11, m: 12, mp: 8, mm: 10, conds: 2, online: true },
            { i: 'YZ', n: 'Yara Zenith', hp: 9, m: 10, mp: 6, mm: 12, conds: 0, online: true },
            { i: 'BK', n: 'Brother Kassim', hp: 7, m: 11, mp: 4, mm: 8, conds: 1, online: true },
            { i: 'NV', n: 'Nox Vael', hp: 10, m: 10, mp: 0, mm: 6, conds: 0, online: false },
          ].map((c) => (
            <div
              key={c.i}
              style={{
                display: 'grid',
                gridTemplateColumns: '32px 1fr auto',
                gap: 10,
                alignItems: 'center',
                padding: '8px 10px',
                background: 'var(--surface-void)',
                border: '1px solid rgba(166,124,40,0.3)',
                borderRadius: 4,
              }}
            >
              <Portrait initials={c.i} size={32} />
              <div style={{ minWidth: 0 }}>
                <div
                  className="cor-display cor-track-04"
                  style={{
                    fontSize: 13,
                    color: 'var(--brand-brass-light)',
                    display: 'flex',
                    alignItems: 'center',
                    gap: 6,
                  }}
                >
                  {c.n}
                  <span
                    style={{
                      width: 6,
                      height: 6,
                      borderRadius: '50%',
                      background: c.online ? 'var(--state-success)' : 'var(--text-secondary)',
                      opacity: c.online ? 1 : 0.5,
                    }}
                  />
                </div>
                <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginTop: 2 }}>
                  <span
                    className="cor-mono"
                    style={{
                      fontSize: 10,
                      color:
                        c.hp / c.m < 0.4 ? 'var(--state-crimson-bright)' : 'var(--text-secondary)',
                    }}
                  >
                    HP {c.hp}/{c.m}
                  </span>
                  <span
                    className="cor-mono"
                    style={{ fontSize: 10, color: 'var(--state-mystic-teal)' }}
                  >
                    MP {c.mp}/{c.mm}
                  </span>
                  {c.conds > 0 && (
                    <span
                      className="cor-chip cor-chip--cond"
                      style={{ fontSize: 9, padding: '1px 6px' }}
                    >
                      {c.conds}
                    </span>
                  )}
                </div>
              </div>
              <button
                style={{
                  padding: '4px 10px',
                  background: 'transparent',
                  border: '1px solid var(--brand-brass-deep)',
                  color: 'var(--brand-brass)',
                  borderRadius: 4,
                  fontSize: 11,
                  cursor: 'pointer',
                }}
              >
                Open
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  </div>
);

window.GmSession = GmSession;
