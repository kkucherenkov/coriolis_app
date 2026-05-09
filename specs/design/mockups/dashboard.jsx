// Dashboard — auth view ("the bridge")
const DashCard = ({ title, items, empty, emptyCta }) => (
  <div
    className="cor-card"
    style={{ padding: 24, display: 'flex', flexDirection: 'column', minHeight: 280 }}
  >
    <PanelTitle>{title}</PanelTitle>
    {items.length === 0 ? (
      <div
        style={{
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 12,
          padding: '24px 0',
        }}
      >
        <StarOrnament size={56} color="var(--brand-brass-deep)" opacity={0.7} />
        <div
          className="cor-display"
          style={{ fontSize: 16, color: 'var(--brand-brass-light)', textAlign: 'center' }}
        >
          {empty}
        </div>
        <button
          className="cor-btn cor-btn--secondary"
          style={{ marginTop: 4, fontSize: 12, padding: '8px 16px' }}
        >
          {emptyCta}
        </button>
      </div>
    ) : (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {items.map((it) => (
          <div
            key={it.name}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 14,
              padding: '10px 12px',
              background: 'var(--surface-void)',
              border: '1px solid rgba(166,124,40,0.4)',
              borderRadius: 4,
            }}
          >
            <IconMedallion letter={it.glyph} size={36} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div
                className="cor-display cor-track-04"
                style={{ fontSize: 16, color: 'var(--brand-brass-light)' }}
              >
                {it.name}
              </div>
              <div className="cor-body" style={{ fontSize: 12, color: 'var(--text-secondary)' }}>
                {it.sub}
              </div>
            </div>
            <span
              className="cor-body"
              style={{
                fontSize: 11,
                color: 'var(--brand-brass)',
                letterSpacing: '0.08em',
                textTransform: 'uppercase',
              }}
            >
              {it.meta}
            </span>
          </div>
        ))}
        <button
          className="cor-btn cor-btn--ghost"
          style={{ marginTop: 4, alignSelf: 'flex-start', padding: '4px 0', fontSize: 12 }}
        >
          See all →
        </button>
      </div>
    )}
  </div>
);

const Dashboard = () => (
  <div className="cor-surface-void" style={{ minHeight: '100%', padding: '32px 56px' }}>
    {/* Top bar */}
    <div
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 48,
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
        <StarOrnament size={32} color="var(--brand-brass)" />
        <div
          className="cor-display cor-track-10"
          style={{ fontSize: 16, color: 'var(--brand-brass-light)', textTransform: 'uppercase' }}
        >
          Coriolis · Companion
        </div>
      </div>
      <div style={{ display: 'flex', gap: 28, alignItems: 'center' }}>
        {['Bridge', 'Library', 'Settings'].map((t, i) => (
          <span
            key={t}
            className="cor-body"
            style={{
              fontSize: 13,
              letterSpacing: '0.16em',
              textTransform: 'uppercase',
              color: i === 0 ? 'var(--brand-brass-light)' : 'var(--text-secondary)',
              borderBottom: i === 0 ? '1px solid var(--brand-brass)' : 'none',
              paddingBottom: 4,
            }}
          >
            {t}
          </span>
        ))}
        <div
          style={{
            width: 36,
            height: 36,
            borderRadius: '50%',
            background: 'var(--surface-night)',
            border: '1px solid var(--brand-brass-deep)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <span className="cor-display" style={{ fontSize: 14, color: 'var(--brand-brass-light)' }}>
            I
          </span>
        </div>
      </div>
    </div>

    {/* Greeting */}
    <div style={{ marginBottom: 48 }}>
      <div
        className="cor-body cor-uppercase"
        style={{
          color: 'var(--brand-brass)',
          fontSize: 11,
          letterSpacing: '0.3em',
          marginBottom: 12,
        }}
      >
        Cycle 47 · 04:32 standard
      </div>
      <h1
        className="cor-display cor-track-04"
        style={{ fontSize: 44, color: 'var(--brand-brass-light)', margin: 0, fontWeight: 400 }}
      >
        Welcome back, Iskander.
      </h1>
      <Swash width={180} />
    </div>

    {/* Three cards */}
    <div
      style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 24, marginBottom: 32 }}
    >
      <DashCard
        title="Characters"
        items={[
          {
            name: 'Tariq al-Asari',
            sub: 'Pilot · Free League · Group: Crew of the Madara',
            meta: '2d ago',
            glyph: 'T',
          },
          {
            name: 'Yara Zenith',
            sub: 'Mystic · The Order · Group: The Long Watch',
            meta: '1w ago',
            glyph: 'F',
          },
          { name: 'Brother Kassim', sub: 'Preacher · Faceless cult', meta: '3w ago', glyph: 'M' },
        ]}
        empty="No characters yet"
        emptyCta="Create one"
      />
      <DashCard
        title="Ships"
        items={[
          { name: 'Madara', sub: 'Class III freighter · Crew 5/6', meta: 'active', glyph: 'C' },
          { name: 'Long Watch', sub: 'Scout cruiser · Crew 3/4', meta: 'docked', glyph: 'D' },
        ]}
        empty="No ships charted"
        emptyCta="Charter a ship"
      />
      <DashCard
        title="Sessions"
        items={[
          {
            name: 'The Mercy of Kua',
            sub: 'Session 12 · Crew of the Madara',
            meta: 'tonight',
            glyph: 'J',
          },
          {
            name: 'Whispers of Dabaran',
            sub: 'Session 04 · The Long Watch',
            meta: 'paused',
            glyph: 'G',
          },
        ]}
        empty="No sessions running"
        emptyCta="Start a session"
      />
    </div>

    {/* Footer signal */}
    <div
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginTop: 48,
        paddingTop: 24,
        borderTop: '1px solid var(--brand-brass-deep)',
      }}
    >
      <div
        className="cor-body"
        style={{ fontSize: 12, color: 'var(--text-secondary)', fontStyle: 'italic' }}
      >
        “The dice listen. The Icons whisper. Push if you must.”
      </div>
      <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
        <span
          style={{ width: 8, height: 8, borderRadius: '50%', background: 'var(--state-success)' }}
        />
        <span
          className="cor-body"
          style={{
            fontSize: 11,
            color: 'var(--text-secondary)',
            letterSpacing: '0.12em',
            textTransform: 'uppercase',
          }}
        >
          Synced
        </span>
      </div>
    </div>
  </div>
);

window.Dashboard = Dashboard;
