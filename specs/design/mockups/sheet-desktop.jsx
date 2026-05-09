// Character Sheet — Desktop, three-column layout
const SheetDesktop = () => {
  const general = [
    { name: 'Dexterity', attr: 'AGI', rank: 4 },
    { name: 'Force', attr: 'STR', rank: 1 },
    { name: 'Infiltration', attr: 'AGI', rank: 3 },
    { name: 'Manipulation', attr: 'EMP', rank: 2 },
    { name: 'Melee Combat', attr: 'STR', rank: 1 },
    { name: 'Observation', attr: 'WIT', rank: 4 },
    { name: 'Ranged Combat', attr: 'AGI', rank: 3 },
    { name: 'Survival', attr: 'WIT', rank: 2 },
  ];
  const advanced = [
    { name: 'Pilot', attr: 'AGI', rank: 5, key: true },
    { name: 'Technology', attr: 'WIT', rank: 3 },
    { name: 'Data Djinn', attr: 'WIT', rank: 2 },
    { name: 'Command', attr: 'EMP', rank: 2 },
    { name: 'Science!', attr: 'WIT', rank: 1 },
    { name: 'Culture', attr: 'EMP', rank: 1 },
    { name: 'Medicurgy', attr: 'WIT', rank: 0 },
    { name: 'Mystic Powers', attr: 'EMP', rank: 0 },
  ];

  return (
    <div className="cor-surface-void" style={{ minHeight: '100%' }}>
      {/* Hero header — brass plate */}
      <div
        style={{
          position: 'relative',
          background: 'linear-gradient(180deg, #15193F 0%, #0B0E2C 100%)',
          borderBottom: '1px solid var(--brand-brass-deep)',
          padding: '40px 56px 32px',
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
            gridTemplateColumns: '120px 1fr auto',
            gap: 36,
            alignItems: 'center',
          }}
        >
          <Portrait initials="TA" size={120} />
          <div>
            <div
              className="cor-body cor-uppercase"
              style={{
                fontSize: 11,
                color: 'var(--brand-brass)',
                letterSpacing: '0.3em',
                marginBottom: 8,
              }}
            >
              Pilot · Free League
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
              Tariq al-Asari
            </h1>
            <Swash width={180} />
            <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 14 }}>
              <IconMedallion letter="T" size={28} />
              <span className="cor-body" style={{ fontSize: 13, color: 'var(--text-secondary)' }}>
                The Traveler · Crew of the Madara
              </span>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 32 }}>
            <CounterBlock label="HP" value={11} max={12} />
            <CounterBlock label="MP" value={8} max={10} mystic />
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div
        style={{
          display: 'flex',
          padding: '0 56px',
          borderBottom: '1px solid var(--brand-brass-deep)',
        }}
      >
        {['Stats', 'Gear', 'Talents', 'Notes', 'Share'].map((t, i) => (
          <span key={t} className={`cor-tab ${i === 0 ? 'cor-tab--active' : ''}`}>
            {t}
          </span>
        ))}
      </div>

      {/* Three columns */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '28% 44% 28%',
          gap: 24,
          padding: '32px 56px',
        }}
      >
        {/* LEFT — Identity / conditions */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
          <div className="cor-card" style={{ padding: 20 }}>
            <PanelTitle size="sm">Identity</PanelTitle>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {[
                ['Concept', 'Veteran fringe pilot'],
                ['Origin', 'Algol · Stationary'],
                ['Age', '34 · Adult'],
                ['Reputation', '4'],
              ].map(([k, v]) => (
                <div
                  key={k}
                  style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13 }}
                >
                  <span
                    className="cor-body cor-uppercase"
                    style={{ color: 'var(--brand-brass)', fontSize: 11, letterSpacing: '0.12em' }}
                  >
                    {k}
                  </span>
                  <span className="cor-body" style={{ color: 'var(--text-primary)' }}>
                    {v}
                  </span>
                </div>
              ))}
            </div>
          </div>

          <div className="cor-card" style={{ padding: 20 }}>
            <PanelTitle size="sm">Conditions</PanelTitle>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
              <span className="cor-chip cor-chip--cond">Sleepless</span>
              <span className="cor-chip cor-chip--cond">Thirsty</span>
              <span className="cor-chip" style={{ opacity: 0.4 }}>
                Hungry
              </span>
              <span className="cor-chip" style={{ opacity: 0.4 }}>
                Exhausted
              </span>
            </div>
            <div
              style={{
                marginTop: 16,
                padding: '10px 12px',
                background: 'rgba(168,50,74,0.12)',
                border: '1px solid rgba(229,78,107,0.4)',
                borderRadius: 4,
              }}
            >
              <div
                className="cor-body cor-uppercase"
                style={{
                  fontSize: 10,
                  color: 'var(--state-crimson-bright)',
                  letterSpacing: '0.16em',
                  marginBottom: 4,
                }}
              >
                Critical Injury
              </div>
              <div className="cor-body" style={{ fontSize: 12, color: 'var(--text-primary)' }}>
                Broken arm · −2 to Force, Melee Combat
              </div>
            </div>
          </div>

          <div className="cor-card cor-card--featured" style={{ padding: 20 }}>
            <PanelTitle size="sm">Push Status</PanelTitle>
            <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
              <div
                style={{
                  width: 48,
                  height: 48,
                  borderRadius: '50%',
                  background: 'rgba(43,163,160,0.18)',
                  border: '1px solid var(--state-mystic-teal)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <StarOrnament size={28} color="var(--state-mystic-teal)" />
              </div>
              <div>
                <div
                  className="cor-display cor-track-04"
                  style={{ fontSize: 18, color: 'var(--state-mystic-teal)' }}
                >
                  Prayer-eligible
                </div>
                <div className="cor-body" style={{ fontSize: 12, color: 'var(--text-secondary)' }}>
                  Last roll may be pushed for 1 DP.
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* CENTER — Attributes & skills */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
          <div className="cor-card" style={{ padding: 20 }}>
            <PanelTitle size="md">Attributes</PanelTitle>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16 }}>
              {[
                ['Strength', 3],
                ['Agility', 5],
                ['Wits', 4],
                ['Empathy', 3],
              ].map(([k, v]) => (
                <StatBlock key={k} label={k} value={v} />
              ))}
            </div>
          </div>

          <div className="cor-card" style={{ padding: 20 }}>
            <div
              style={{
                display: 'flex',
                alignItems: 'baseline',
                justifyContent: 'space-between',
                marginBottom: 14,
              }}
            >
              <PanelTitle size="md">Skills</PanelTitle>
              <div
                style={{
                  display: 'flex',
                  gap: 14,
                  alignItems: 'center',
                  fontSize: 10,
                  fontFamily: 'Inter',
                  letterSpacing: '0.14em',
                  textTransform: 'uppercase',
                }}
              >
                <span
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: 6,
                    color: 'var(--text-secondary)',
                  }}
                >
                  <span className="cor-dot cor-dot--filled" style={{ width: 8, height: 8 }} />
                  General
                </span>
                <span
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: 6,
                    color: 'var(--state-mystic-teal)',
                  }}
                >
                  <StarOrnament size={10} color="var(--state-mystic-teal)" />
                  Advanced
                </span>
              </div>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', columnGap: 24 }}>
              <div>
                <div
                  className="cor-display cor-track-04 cor-uppercase"
                  style={{
                    fontSize: 11,
                    color: 'var(--brand-brass)',
                    letterSpacing: '0.20em',
                    marginBottom: 4,
                    paddingBottom: 6,
                    borderBottom: '1px solid var(--brand-brass-deep)',
                  }}
                >
                  General
                </div>
                {general.map((s) => (
                  <SkillRow key={s.name} {...s} />
                ))}
              </div>
              <div style={{ position: 'relative' }}>
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 8,
                    fontSize: 11,
                    color: 'var(--state-mystic-teal)',
                    fontFamily: 'Forum, serif',
                    letterSpacing: '0.20em',
                    textTransform: 'uppercase',
                    marginBottom: 4,
                    paddingBottom: 6,
                    borderBottom: '1px solid var(--state-mystic-teal)',
                  }}
                >
                  <StarOrnament size={11} color="var(--state-mystic-teal)" />
                  Advanced
                  <span
                    style={{
                      marginLeft: 'auto',
                      fontSize: 9,
                      opacity: 0.7,
                      letterSpacing: '0.12em',
                    }}
                  >
                    requires training
                  </span>
                </div>
                {advanced.map((s) => (
                  <div key={s.name} style={{ position: 'relative' }}>
                    {/* teal accent rail on advanced rows */}
                    <span
                      style={{
                        position: 'absolute',
                        left: -8,
                        top: 8,
                        bottom: 8,
                        width: 2,
                        background:
                          s.rank > 0 ? 'var(--state-mystic-teal)' : 'rgba(43,163,160,0.25)',
                        borderRadius: 1,
                      }}
                    />
                    <SkillRow
                      name={
                        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
                          {s.name}
                          {s.key && (
                            <span
                              className="cor-chip cor-chip--mystic"
                              style={{ fontSize: 9, padding: '1px 6px' }}
                            >
                              key
                            </span>
                          )}
                        </span>
                      }
                      attr={s.attr}
                      rank={s.rank}
                    />
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* RIGHT — Equipped, talents, recent rolls */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
          <div className="cor-card" style={{ padding: 20 }}>
            <PanelTitle size="sm">Equipped</PanelTitle>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {[
                { n: 'Vulcan Carbine', m: 'Bonus 2 · 0.8 enc' },
                { n: 'Heavy EVA suit', m: 'Armor 6 · 1.0 enc' },
                { n: 'Comms unit', m: 'Bonus 1 · 0.2 enc' },
              ].map((g) => (
                <div
                  key={g.n}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    fontSize: 13,
                    paddingBottom: 8,
                    borderBottom: '1px solid rgba(166,124,40,0.2)',
                  }}
                >
                  <span className="cor-body" style={{ color: 'var(--text-primary)' }}>
                    {g.n}
                  </span>
                  <span
                    className="cor-mono"
                    style={{ color: 'var(--text-secondary)', fontSize: 11 }}
                  >
                    {g.m}
                  </span>
                </div>
              ))}
            </div>
          </div>

          <div className="cor-card" style={{ padding: 20 }}>
            <PanelTitle size="sm">Talents</PanelTitle>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {[
                ['Wing-Mate', 'Adv. Pilot'],
                ['Stunt Pilot', 'rank 2'],
                ['Faith', 'The Traveler'],
              ].map(([n, s]) => (
                <div
                  key={n}
                  style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13 }}
                >
                  <span className="cor-body" style={{ color: 'var(--text-primary)' }}>
                    {n}
                  </span>
                  <span
                    className="cor-body cor-uppercase"
                    style={{ color: 'var(--brand-brass)', fontSize: 10, letterSpacing: '0.12em' }}
                  >
                    {s}
                  </span>
                </div>
              ))}
            </div>
          </div>

          <div className="cor-card" style={{ padding: 20 }}>
            <PanelTitle size="sm">Recent Rolls</PanelTitle>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {[
                { lbl: 'Pilot · Evade', dice: [6, 3, 1, 5, 4, 6, 2], pushed: false },
                { lbl: 'Observation', dice: [2, 4, 6, 1, 3], pushed: true },
                { lbl: 'Ranged Combat', dice: [1, 2, 3, 4], pushed: false },
              ].map((r, i) => (
                <div
                  key={i}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 10,
                    paddingBottom: 8,
                    borderBottom: '1px solid rgba(166,124,40,0.2)',
                  }}
                >
                  <div style={{ flex: 1 }}>
                    <div
                      className="cor-body"
                      style={{ fontSize: 12, color: 'var(--text-primary)' }}
                    >
                      {r.lbl}
                    </div>
                    <div
                      className="cor-body"
                      style={{ fontSize: 10, color: 'var(--text-secondary)' }}
                    >
                      {r.dice.filter((d) => d === 6).length} success
                      {r.dice.filter((d) => d === 6).length === 1 ? '' : 'es'}{' '}
                      {r.pushed && '· pushed'}
                    </div>
                  </div>
                  <div style={{ display: 'flex', gap: 3 }}>
                    {r.dice.slice(0, 6).map((d, j) => (
                      <Die key={j} value={d} size={18} />
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const CounterBlock = ({ label, value, max, mystic }) => (
  <div style={{ textAlign: 'center', minWidth: 100 }}>
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
      {value}
      <span style={{ color: 'var(--text-secondary)', fontSize: 18 }}> / {max}</span>
    </div>
    <div style={{ display: 'flex', justifyContent: 'center', gap: 6, marginTop: 8 }}>
      <button
        style={{
          width: 24,
          height: 24,
          border: '1px solid var(--brand-brass-deep)',
          background: 'transparent',
          color: 'var(--brand-brass)',
          borderRadius: 4,
          cursor: 'pointer',
          fontSize: 14,
        }}
      >
        −
      </button>
      <button
        style={{
          width: 24,
          height: 24,
          border: '1px solid var(--brand-brass-deep)',
          background: 'transparent',
          color: 'var(--brand-brass)',
          borderRadius: 4,
          cursor: 'pointer',
          fontSize: 14,
        }}
      >
        +
      </button>
    </div>
  </div>
);

window.SheetDesktop = SheetDesktop;
