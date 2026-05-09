// Landing page — public, dark-first, brass arabesque framing
const LandingPage = () => (
  <div
    className="cor-starfield"
    style={{
      minHeight: '100%',
      position: 'relative',
      padding: '64px 80px',
      display: 'flex',
      flexDirection: 'column',
    }}
  >
    {/* Arabesque corners */}
    <div style={{ position: 'absolute', top: 24, left: 24 }}>
      <ArabesqueCorner size={64} color="var(--brand-brass)" orientation="tl" />
    </div>
    <div style={{ position: 'absolute', top: 24, right: 24 }}>
      <ArabesqueCorner size={64} color="var(--brand-brass)" orientation="tr" />
    </div>
    <div style={{ position: 'absolute', bottom: 24, left: 24 }}>
      <ArabesqueCorner size={64} color="var(--brand-brass)" orientation="bl" />
    </div>
    <div style={{ position: 'absolute', bottom: 24, right: 24 }}>
      <ArabesqueCorner size={64} color="var(--brand-brass)" orientation="br" />
    </div>

    {/* Top nav */}
    <div
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 96,
      }}
    >
      <div
        className="cor-display cor-track-10"
        style={{ fontSize: 18, color: 'var(--brand-brass-light)', textTransform: 'uppercase' }}
      >
        Coriolis · Companion
      </div>
      <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
        <span className="cor-body" style={{ fontSize: 13, color: 'var(--text-secondary)' }}>
          EN · RU
        </span>
      </div>
    </div>

    {/* Hero */}
    <div style={{ textAlign: 'center', marginTop: 24, marginBottom: 96 }}>
      <Wordmark size={88} />
      <p
        className="cor-body"
        style={{
          marginTop: 36,
          fontSize: 20,
          color: 'var(--text-secondary)',
          fontStyle: 'italic',
          letterSpacing: '0.04em',
        }}
      >
        Your character sheet for the Third Horizon.
      </p>
      <div style={{ display: 'flex', gap: 14, justifyContent: 'center', marginTop: 36 }}>
        <button className="cor-btn">Sign in</button>
        <button className="cor-btn cor-btn--secondary">Create account</button>
      </div>
    </div>

    {/* Three feature blocks */}
    <div
      style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 24, marginTop: 'auto' }}
    >
      {[
        {
          title: 'Sheet',
          sub: 'Eight attributes, sixteen skills, talents, gear, conditions — built for play at the table.',
          letter: 'S',
        },
        {
          title: 'Share',
          sub: 'Public read-only sheets with parchment chrome. No account required to view.',
          letter: 'H',
        },
        {
          title: 'Run',
          sub: 'Initiative tracker, encounter notes, Darkness Points — the bridge for your GM.',
          letter: 'R',
        },
      ].map((b) => (
        <div key={b.title} className="cor-card" style={{ padding: 28, position: 'relative' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 14 }}>
            <IconMedallion letter={b.letter} size={40} />
            <h3
              className="cor-display cor-track-04"
              style={{
                fontSize: 24,
                color: 'var(--brand-brass-light)',
                margin: 0,
                fontWeight: 400,
              }}
            >
              {b.title}
            </h3>
          </div>
          <p
            className="cor-body"
            style={{ color: 'var(--text-secondary)', fontSize: 14, lineHeight: 1.55, margin: 0 }}
          >
            {b.sub}
          </p>
        </div>
      ))}
    </div>

    {/* Footer disclaimer */}
    <div
      style={{
        textAlign: 'center',
        marginTop: 64,
        color: 'var(--text-secondary)',
        fontSize: 11,
        letterSpacing: '0.06em',
        opacity: 0.7,
      }}
    >
      A fan project · Not affiliated with the publisher of the Coriolis tabletop RPG.
    </div>
  </div>
);

window.LandingPage = LandingPage;
