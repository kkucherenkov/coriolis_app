// Character Creation Wizard — all 6 steps as separate artboards
// Steps: 1 Origin · 2 Concept · 3 Group · 4 Attributes · 5 Icon · 6 Skills · 7 Talents · 8 Gear

const WizardShell = ({ stepIdx, children, footerLeft, footerCenter, footerRight }) => {
  const steps = ['Origin', 'Concept', 'Group', 'Attributes', 'Icon', 'Skills', 'Talents', 'Gear'];
  return (
    <div
      className="cor-surface-void"
      style={{ minHeight: '100%', padding: '32px 56px', display: 'flex', flexDirection: 'column' }}
    >
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: 24,
        }}
      >
        <div
          className="cor-display cor-track-10"
          style={{ fontSize: 14, color: 'var(--brand-brass)', textTransform: 'uppercase' }}
        >
          New Character
        </div>
        <div
          className="cor-body cor-uppercase"
          style={{ fontSize: 12, color: 'var(--text-secondary)', letterSpacing: '0.12em' }}
        >
          Step {stepIdx + 1} of 8
        </div>
      </div>
      <div style={{ height: 2, background: 'var(--surface-night)', position: 'relative' }}>
        <div
          style={{
            width: `${((stepIdx + 1) / 8) * 100}%`,
            height: '100%',
            background: 'var(--brand-brass)',
          }}
        />
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', margin: '12px 0 36px' }}>
        {steps.map((s, i) => (
          <span
            key={s}
            className="cor-body cor-uppercase"
            style={{
              fontSize: 10,
              letterSpacing: '0.18em',
              color: i <= stepIdx ? 'var(--brand-brass-light)' : 'var(--text-secondary)',
              opacity: i <= stepIdx ? 1 : 0.5,
            }}
          >
            {s}
          </span>
        ))}
      </div>
      <div style={{ flex: 1 }}>{children}</div>
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginTop: 36,
          paddingTop: 20,
          borderTop: '1px solid var(--brand-brass-deep)',
        }}
      >
        <div>{footerLeft}</div>
        <div
          className="cor-body"
          style={{ fontSize: 12, color: 'var(--text-secondary)', fontStyle: 'italic' }}
        >
          {footerCenter}
        </div>
        <div>{footerRight}</div>
      </div>
    </div>
  );
};

const WizardTitle = ({ title, blurb }) => (
  <div style={{ textAlign: 'center', marginBottom: 36 }}>
    <h1
      className="cor-display cor-track-06"
      style={{ fontSize: 40, color: 'var(--brand-brass-light)', margin: 0, fontWeight: 400 }}
    >
      {title}
    </h1>
    <div style={{ display: 'flex', justifyContent: 'center', marginTop: 4 }}>
      <Swash width={180} />
    </div>
    {blurb && (
      <p
        className="cor-body"
        style={{
          marginTop: 16,
          color: 'var(--text-secondary)',
          fontSize: 15,
          fontStyle: 'italic',
          maxWidth: 580,
          marginLeft: 'auto',
          marginRight: 'auto',
        }}
      >
        {blurb}
      </p>
    )}
  </div>
);

// STEP 1 — ORIGIN
// Origin determines: max attribute points, max skill points, starting reputation,
// the reroll-once attribute, plus a unique talent. Coriolis core p.32–37.
const Wizard1Origin = () => {
  const origins = [
    {
      letter: 'S',
      name: 'Stationary',
      sub: 'Born on a station or planet of the Third Horizon. Shaped by the corporations and the Consortium.',
      attrPts: 14,
      skillPts: 8,
      rep: 4,
      perks: ['Reroll: WITS', 'Talent · Everyday hero'],
      sel: false,
    },
    {
      letter: 'Z',
      name: 'Zenithian',
      sub: 'A child of the new arrivals — descended from the colonists who came through the second portal on the Zenith.',
      attrPts: 15,
      skillPts: 8,
      rep: 5,
      perks: ['Reroll: EMPATHY', 'Talent · Cabal of friends'],
      sel: true,
    },
    {
      letter: 'F',
      name: 'Firstcome',
      sub: 'Bloodline of the first wave. Old families, older grudges, ancestral debts to the Icons.',
      attrPts: 14,
      skillPts: 10,
      rep: 6,
      perks: ['Reroll: STRENGTH', 'Talent · Bloodline'],
      sel: false,
    },
    {
      letter: 'N',
      name: 'Nomad',
      sub: 'Of the Nomad Federation — the wanderers between the stars, keepers of the dark between worlds.',
      attrPts: 15,
      skillPts: 10,
      rep: 3,
      perks: ['Reroll: AGILITY', 'Talent · Nine lives'],
      sel: false,
    },
  ];
  return (
    <WizardShell
      stepIdx={0}
      footerCenter="Zenithian — newcomers; quick to friendship, quick to suspicion."
      footerLeft={<button className="cor-btn cor-btn--ghost">Cancel</button>}
      footerRight={<button className="cor-btn">Continue →</button>}
    >
      <WizardTitle
        title="Choose your origin"
        blurb="Where in the Horizon do you come from? Your origin sets the points you spend on attributes and skills, and the reputation that opens or closes doors."
      />
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(2, 1fr)',
          gap: 16,
          maxWidth: 1000,
          margin: '0 auto',
        }}
      >
        {origins.map((o) => (
          <div
            key={o.name}
            className={`cor-card ${o.sel ? 'cor-card--featured' : ''}`}
            style={{
              padding: 22,
              display: 'flex',
              gap: 18,
              alignItems: 'flex-start',
              cursor: 'pointer',
              position: 'relative',
            }}
          >
            <IconMedallion letter={o.letter} size={64} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div
                className="cor-display cor-track-04"
                style={{ fontSize: 20, color: 'var(--brand-brass-light)' }}
              >
                {o.name}
              </div>
              <div
                className="cor-body"
                style={{
                  fontSize: 12,
                  color: 'var(--text-secondary)',
                  lineHeight: 1.5,
                  marginTop: 4,
                }}
              >
                {o.sub}
              </div>

              <div
                style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(3, 1fr)',
                  gap: 8,
                  marginTop: 14,
                  padding: '10px 0',
                  borderTop: '1px solid rgba(166,124,40,0.3)',
                  borderBottom: '1px solid rgba(166,124,40,0.3)',
                }}
              >
                <div>
                  <div
                    className="cor-body cor-uppercase"
                    style={{ fontSize: 9, color: 'var(--brand-brass)', letterSpacing: '0.16em' }}
                  >
                    Attr. pts
                  </div>
                  <div
                    className="cor-mono"
                    style={{ fontSize: 18, color: 'var(--text-primary)', fontWeight: 700 }}
                  >
                    {o.attrPts}
                  </div>
                </div>
                <div>
                  <div
                    className="cor-body cor-uppercase"
                    style={{ fontSize: 9, color: 'var(--brand-brass)', letterSpacing: '0.16em' }}
                  >
                    Skill pts
                  </div>
                  <div
                    className="cor-mono"
                    style={{ fontSize: 18, color: 'var(--text-primary)', fontWeight: 700 }}
                  >
                    {o.skillPts}
                  </div>
                </div>
                <div>
                  <div
                    className="cor-body cor-uppercase"
                    style={{ fontSize: 9, color: 'var(--brand-brass)', letterSpacing: '0.16em' }}
                  >
                    Reputation
                  </div>
                  <div
                    className="cor-mono"
                    style={{ fontSize: 18, color: 'var(--text-primary)', fontWeight: 700 }}
                  >
                    {o.rep}
                  </div>
                </div>
              </div>

              <div style={{ display: 'flex', gap: 6, marginTop: 10, flexWrap: 'wrap' }}>
                {o.perks.map((p) => (
                  <span key={p} className="cor-chip" style={{ fontSize: 10, padding: '2px 8px' }}>
                    {p}
                  </span>
                ))}
              </div>
            </div>
            {o.sel && (
              <span
                className="cor-chip cor-chip--mystic"
                style={{
                  position: 'absolute',
                  top: 14,
                  right: 14,
                  fontSize: 9,
                  padding: '2px 8px',
                }}
              >
                <span
                  style={{
                    width: 5,
                    height: 5,
                    borderRadius: '50%',
                    background: 'var(--state-mystic-teal)',
                  }}
                />
                Chosen
              </span>
            )}
          </div>
        ))}
      </div>
    </WizardShell>
  );
};

// STEP 2 — CONCEPT
const Wizard2Concept = () => {
  const concepts = [
    { letter: 'P', name: 'Pilot', sub: 'Veteran fringe pilot · navigator', sel: true },
    { letter: 'M', name: 'Mystic', sub: 'Ascetic seeker of the Faceless' },
    { letter: 'S', name: 'Soldier', sub: 'Mercenary or Free League regular' },
    { letter: 'T', name: 'Trader', sub: 'Broker, smuggler, or factor' },
    { letter: 'D', name: 'Data Djinn', sub: 'Hacker · cyber-dervish' },
    { letter: 'O', name: 'Operative', sub: 'Spy or assassin in the long shadow' },
    { letter: 'C', name: 'Colonist', sub: 'Settler of new worlds' },
    { letter: 'A', name: 'Artist', sub: 'Performer · gunslinger · dancer' },
    { letter: 'F', name: 'Preacher', sub: 'Voice of the Icons' },
  ];
  return (
    <WizardShell
      stepIdx={1}
      footerCenter="Pilot — your archetype shapes attributes, key skill, and starting talents."
      footerLeft={<button className="cor-btn cor-btn--ghost">← Back</button>}
      footerRight={<button className="cor-btn">Continue →</button>}
    >
      <WizardTitle
        title="Choose your concept"
        blurb="The role you played before the Madara picked you up. It will not define you. It will follow you."
      />
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(3, 1fr)',
          gap: 14,
          maxWidth: 880,
          margin: '0 auto',
        }}
      >
        {concepts.map((c) => (
          <div
            key={c.name}
            className={`cor-card ${c.sel ? 'cor-card--featured' : ''}`}
            style={{
              padding: 20,
              display: 'flex',
              alignItems: 'center',
              gap: 14,
              cursor: 'pointer',
            }}
          >
            <IconMedallion letter={c.letter} size={48} />
            <div style={{ minWidth: 0 }}>
              <div
                className="cor-display cor-track-04"
                style={{ fontSize: 17, color: 'var(--brand-brass-light)' }}
              >
                {c.name}
              </div>
              <div
                className="cor-body"
                style={{ fontSize: 11, color: 'var(--text-secondary)', lineHeight: 1.4 }}
              >
                {c.sub}
              </div>
            </div>
          </div>
        ))}
      </div>
    </WizardShell>
  );
};

// STEP 3 — GROUP
const Wizard3Group = () => {
  const groups = [
    {
      letter: 'F',
      name: 'Free Traders',
      sub: 'A crew of one ship, debt to a patron, dreams of their own. The default Coriolis crew concept.',
      sel: true,
      talents: ['Captain’s contract', 'A shared ship'],
    },
    {
      letter: 'M',
      name: 'Mercenaries',
      sub: 'Hired guns. Loyal to the contract.',
      talents: ['Combat training', 'Gear stipend'],
    },
    {
      letter: 'A',
      name: 'Agents',
      sub: 'Spies, troubleshooters, fixers in the long shadow.',
      talents: ['Cover identities', 'Clearance'],
    },
    {
      letter: 'P',
      name: 'Pilgrims',
      sub: 'Followers of an Icon, walking holy roads.',
      talents: ['Faith', 'Sanctuary network'],
    },
    {
      letter: 'C',
      name: 'Colonists',
      sub: 'Settlers carving a future from a hostile world.',
      talents: ['Stake', 'Land grant'],
    },
    {
      letter: 'E',
      name: 'Explorers',
      sub: 'Surveyors of jump-points and dead worlds.',
      talents: ['Astrolabe', 'Patron'],
    },
  ];
  return (
    <WizardShell
      stepIdx={2}
      footerCenter="Free Traders — the most common crew concept in the Third Horizon."
      footerLeft={<button className="cor-btn cor-btn--ghost">← Back</button>}
      footerRight={<button className="cor-btn">Continue →</button>}
    >
      <WizardTitle
        title="Choose your crew"
        blurb="The company you keep. Group concept defines starting talents and what binds you all to the same ship."
      />
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(2, 1fr)',
          gap: 14,
          maxWidth: 920,
          margin: '0 auto',
        }}
      >
        {groups.map((g) => (
          <div
            key={g.name}
            className={`cor-card ${g.sel ? 'cor-card--featured' : ''}`}
            style={{
              padding: 20,
              display: 'flex',
              gap: 16,
              alignItems: 'flex-start',
              cursor: 'pointer',
              position: 'relative',
            }}
          >
            <IconMedallion letter={g.letter} size={56} />
            <div style={{ flex: 1 }}>
              <div
                className="cor-display cor-track-04"
                style={{ fontSize: 18, color: 'var(--brand-brass-light)' }}
              >
                {g.name}
              </div>
              <div
                className="cor-body"
                style={{
                  fontSize: 12,
                  color: 'var(--text-secondary)',
                  lineHeight: 1.5,
                  marginTop: 4,
                }}
              >
                {g.sub}
              </div>
              <div style={{ display: 'flex', gap: 6, marginTop: 10, flexWrap: 'wrap' }}>
                {g.talents.map((tl) => (
                  <span key={tl} className="cor-chip" style={{ fontSize: 10, padding: '2px 8px' }}>
                    {tl}
                  </span>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>
    </WizardShell>
  );
};

// STEP 4 — ATTRIBUTES
const Wizard4Attributes = () => {
  const attrs = [
    { name: 'Strength', val: 3, key: 'STR' },
    { name: 'Agility', val: 5, key: 'AGI', primary: true },
    { name: 'Wits', val: 4, key: 'WIT' },
    { name: 'Empathy', val: 3, key: 'EMP' },
  ];
  const remaining = 14 - attrs.reduce((s, a) => s + a.val, 0);
  return (
    <WizardShell
      stepIdx={3}
      footerCenter="Pilot’s primary is Agility — invest 5 there for rank-cap headroom."
      footerLeft={<button className="cor-btn cor-btn--ghost">← Back</button>}
      footerRight={<button className="cor-btn">Continue →</button>}
    >
      <WizardTitle
        title="Distribute your attributes"
        blurb="14 points. Minimum 2, maximum 5 in each. Your concept’s primary attribute may go to 5; others cap at 4."
      />
      <div style={{ maxWidth: 720, margin: '0 auto' }}>
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '10px 16px',
            background: 'var(--surface-night)',
            border: '1px solid var(--brand-brass-deep)',
            borderRadius: 4,
            marginBottom: 24,
          }}
        >
          <span
            className="cor-body cor-uppercase"
            style={{ fontSize: 11, color: 'var(--brand-brass)', letterSpacing: '0.18em' }}
          >
            Points remaining
          </span>
          <span
            className="cor-mono"
            style={{
              fontSize: 24,
              fontWeight: 700,
              color: remaining === 0 ? 'var(--state-success)' : 'var(--brand-brass-light)',
            }}
          >
            {remaining}
          </span>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {attrs.map((a) => (
            <div
              key={a.name}
              className="cor-card"
              style={{
                padding: 20,
                display: 'grid',
                gridTemplateColumns: '180px 1fr 80px 130px',
                alignItems: 'center',
                gap: 18,
                ...(a.primary ? { borderColor: 'var(--brand-brass)' } : {}),
              }}
            >
              <div>
                <div
                  className="cor-display cor-track-04"
                  style={{ fontSize: 18, color: 'var(--brand-brass-light)' }}
                >
                  {a.name}
                </div>
                <div
                  className="cor-body cor-uppercase"
                  style={{
                    fontSize: 10,
                    color: a.primary ? 'var(--state-mystic-teal)' : 'var(--brand-brass)',
                    letterSpacing: '0.16em',
                    marginTop: 2,
                  }}
                >
                  {a.key}
                  {a.primary ? ' · primary' : ''}
                </div>
              </div>
              <div style={{ display: 'flex', gap: 8 }}>
                {Array.from({ length: 5 }).map((_, i) => (
                  <span
                    key={i}
                    className={`cor-dot ${i < a.val ? 'cor-dot--filled' : ''}`}
                    style={{ width: 18, height: 18 }}
                  />
                ))}
              </div>
              <span
                className="cor-mono"
                style={{
                  fontSize: 28,
                  fontWeight: 700,
                  color: 'var(--text-primary)',
                  textAlign: 'center',
                }}
              >
                {a.val}
              </span>
              <div style={{ display: 'flex', gap: 6, justifyContent: 'flex-end' }}>
                <button
                  style={{
                    width: 36,
                    height: 36,
                    border: '1px solid var(--brand-brass-deep)',
                    background: 'transparent',
                    color: 'var(--brand-brass)',
                    borderRadius: 4,
                    cursor: 'pointer',
                    fontSize: 16,
                  }}
                >
                  −
                </button>
                <button
                  style={{
                    width: 36,
                    height: 36,
                    border: '1px solid var(--brand-brass-deep)',
                    background: 'transparent',
                    color: 'var(--brand-brass)',
                    borderRadius: 4,
                    cursor: 'pointer',
                    fontSize: 16,
                  }}
                >
                  +
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </WizardShell>
  );
};

// STEP 5 — ICON (the existing ornate step, now wrapped in shared shell)
const Wizard5Icon = () => (
  <WizardShell
    stepIdx={4}
    footerCenter="The Traveler — patron of explorers and pilots."
    footerLeft={<button className="cor-btn cor-btn--ghost">← Back</button>}
    footerRight={<button className="cor-btn">Continue →</button>}
  >
    <WizardTitle
      title="Choose your Icon"
      blurb="The Icons watch from beyond the dark water. One walks beside you. Choose, and they will hear your prayers."
    />
    <div
      style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(3, 1fr)',
        gap: 14,
        maxWidth: 880,
        margin: '0 auto',
      }}
    >
      {NINE_ICONS.map((icon, i) => {
        const sel = i === 1;
        return (
          <div
            key={icon.name}
            className={`cor-card ${sel ? 'cor-card--featured' : ''}`}
            style={{
              padding: 20,
              position: 'relative',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 10,
              cursor: 'pointer',
              ...(sel
                ? {
                    boxShadow:
                      '0 0 24px rgba(43,163,160,0.35), inset 0 0 0 1px var(--brand-brass-shadow)',
                  }
                : {}),
            }}
          >
            <IconMedallion letter={icon.letter} size={60} glow={sel} />
            <div
              className="cor-display cor-track-04"
              style={{ fontSize: 15, color: 'var(--brand-brass-light)', textAlign: 'center' }}
            >
              {icon.name}
            </div>
            <div
              className="cor-body"
              style={{
                fontSize: 11,
                color: 'var(--text-secondary)',
                textAlign: 'center',
                lineHeight: 1.4,
              }}
            >
              {icon.domain}
            </div>
            {sel && (
              <div
                className="cor-chip cor-chip--mystic"
                style={{ marginTop: 2, fontSize: 10, padding: '2px 8px' }}
              >
                <span
                  style={{
                    width: 6,
                    height: 6,
                    borderRadius: '50%',
                    background: 'var(--state-mystic-teal)',
                  }}
                />
                Chosen
              </div>
            )}
          </div>
        );
      })}
    </div>
  </WizardShell>
);

// STEP 6 — SKILLS
const Wizard6Skills = () => {
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
    { name: 'Pilot', attr: 'AGI', rank: 3, primary: true },
    { name: 'Data Djinn', attr: 'WIT', rank: 1 },
    { name: 'Medicurgy', attr: 'WIT', rank: 0 },
    { name: 'Mystic Powers', attr: 'EMP', rank: 0 },
    { name: 'Science!', attr: 'WIT', rank: 0 },
    { name: 'Technology', attr: 'WIT', rank: 1 },
    { name: 'Command', attr: 'EMP', rank: 0 },
    { name: 'Culture', attr: 'EMP', rank: 0 },
  ];
  const SkillPickRow = ({ s, max = 5 }) => (
    <div
      style={{
        display: 'grid',
        gridTemplateColumns: '1fr 40px 1fr 24px',
        alignItems: 'center',
        gap: 10,
        padding: '7px 4px',
        borderBottom: '1px solid rgba(166,124,40,0.2)',
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span className="cor-body" style={{ fontSize: 13, color: 'var(--text-primary)' }}>
          {s.name}
        </span>
        {s.primary && (
          <span className="cor-chip cor-chip--mystic" style={{ fontSize: 9, padding: '1px 6px' }}>
            key
          </span>
        )}
      </div>
      <span
        className="cor-body cor-uppercase"
        style={{ fontSize: 10, color: 'var(--brand-brass)', letterSpacing: '0.12em' }}
      >
        {s.attr}
      </span>
      <span className="cor-dots" style={{ justifyContent: 'flex-start' }}>
        {Array.from({ length: max }).map((_, i) => (
          <span
            key={i}
            className={`cor-dot ${i < s.rank ? 'cor-dot--filled' : ''}`}
            style={{ width: 11, height: 11, cursor: 'pointer' }}
          />
        ))}
      </span>
      <span
        className="cor-mono"
        style={{ fontSize: 13, color: 'var(--text-primary)', textAlign: 'right' }}
      >
        {s.rank}
      </span>
    </div>
  );
  return (
    <WizardShell
      stepIdx={5}
      footerCenter="8 points among general skills (max 3) · 2 points in your key skill (max 3)."
      footerLeft={<button className="cor-btn cor-btn--ghost">← Back</button>}
      footerRight={<button className="cor-btn">Continue →</button>}
    >
      <WizardTitle
        title="Train your skills"
        blurb="General skills you may use untrained; advanced skills require at least one rank. The Pilot’s key skill is, predictably, Pilot."
      />
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(2, 1fr)',
          gap: 18,
          maxWidth: 1080,
          margin: '0 auto',
        }}
      >
        <div className="cor-card" style={{ padding: 20 }}>
          <PanelTitle size="sm">General Skills</PanelTitle>
          <div
            className="cor-body cor-uppercase"
            style={{
              fontSize: 10,
              color: 'var(--brand-brass)',
              letterSpacing: '0.16em',
              marginBottom: 6,
            }}
          >
            Points left · 0
          </div>
          {general.map((s) => (
            <SkillPickRow key={s.name} s={s} />
          ))}
        </div>
        <div className="cor-card" style={{ padding: 20 }}>
          <PanelTitle size="sm">Advanced Skills</PanelTitle>
          <div
            className="cor-body cor-uppercase"
            style={{
              fontSize: 10,
              color: 'var(--brand-brass)',
              letterSpacing: '0.16em',
              marginBottom: 6,
            }}
          >
            Points left · 0 · Key: Pilot
          </div>
          {advanced.map((s) => (
            <SkillPickRow key={s.name} s={s} max={3} />
          ))}
        </div>
      </div>
    </WizardShell>
  );
};

// STEP 7 — TALENTS
// One preselected from chosen Icon, crew talents from Group concept (locked),
// plus one free pick from the general talents pool.
const Wizard7Talents = () => {
  const iconTalent = {
    name: 'Voice of the Traveler',
    src: 'Icon · The Traveler',
    desc: 'Once per session, reroll any Pilot or Survival skill check. The dice remember the road home.',
  };
  const crewTalents = [
    {
      name: 'Captain’s contract',
      src: 'Group · Free Traders',
      desc: 'The crew shares one binding contract — +1 to Manipulation when invoking it.',
    },
    {
      name: 'A shared ship',
      src: 'Group · Free Traders',
      desc: 'Every PC owns a stake in the ship. Repairs and upgrades are shared.',
    },
  ];
  const offered = [
    { name: 'Combat veteran', desc: 'Once per turn, ignore the first point of damage you take.' },
    {
      name: 'Defender of the faith',
      desc: '+2 to Mystic Powers checks made to defend a fellow believer.',
      sel: true,
    },
    { name: 'Everyday hero', desc: 'When you push a roll, gain 1 success on a 5 as well as a 6.' },
    { name: 'Executioner', desc: '+1 damage when you attack a target who is already prone.' },
    { name: 'Faceless', desc: 'NPCs forget you in a crowd. Spend 1 DP to disappear from a scene.' },
    { name: 'Gunfighter', desc: 'Draw a sidearm as a free action; +1 initiative in firefights.' },
    { name: 'Hard to kill', desc: 'Recover 1 extra HP when treated with Medicurgy.' },
    {
      name: 'Investigator',
      desc: 'Take 10 minutes and a Culture roll to learn the recent history of any place.',
    },
    {
      name: 'Jury-rigger',
      desc: 'Repair broken tech outside a workshop with a Technology roll at +1.',
    },
    { name: 'Killer instinct', desc: '+1 to all Melee Combat damage rolls.' },
    { name: 'Linguist', desc: 'You speak every Horizon language well enough to bargain.' },
    { name: 'Nine lives', desc: 'When reduced to 0 HP, spend 1 DP to remain on 1 HP instead.' },
  ];
  const SLOTS = 4; // Icon + 2 crew + 1 free pick
  const filled = 1 + crewTalents.length + (offered.find((t) => t.sel) ? 1 : 0);

  const TalentChip = ({ t, locked, picked, free }) => (
    <div
      className={`cor-card ${picked ? 'cor-card--featured' : ''}`}
      style={{
        padding: 14,
        position: 'relative',
        borderColor: locked
          ? 'var(--brand-brass-deep)'
          : picked
            ? 'var(--brand-brass)'
            : 'var(--brand-brass-deep)',
        cursor: locked ? 'default' : 'pointer',
        opacity: locked ? 1 : picked ? 1 : 0.92,
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          gap: 8,
          marginBottom: 4,
        }}
      >
        <div
          className="cor-display cor-track-04"
          style={{ fontSize: 15, color: 'var(--brand-brass-light)' }}
        >
          {t.name}
        </div>
        {locked && (
          <span className="cor-chip" style={{ fontSize: 9, padding: '1px 6px' }}>
            locked
          </span>
        )}
        {picked && !locked && (
          <span className="cor-chip cor-chip--mystic" style={{ fontSize: 9, padding: '1px 6px' }}>
            <span
              style={{
                width: 5,
                height: 5,
                borderRadius: '50%',
                background: 'var(--state-mystic-teal)',
              }}
            />
            picked
          </span>
        )}
      </div>
      {t.src && (
        <div
          className="cor-body cor-uppercase"
          style={{
            fontSize: 9,
            color: 'var(--brand-brass)',
            letterSpacing: '0.16em',
            marginBottom: 6,
          }}
        >
          {t.src}
        </div>
      )}
      <div
        className="cor-body"
        style={{ fontSize: 12, color: 'var(--text-secondary)', lineHeight: 1.5 }}
      >
        {t.desc}
      </div>
    </div>
  );

  return (
    <WizardShell
      stepIdx={6}
      footerCenter="Three talents come from your story — Icon and crew. The fourth is yours alone."
      footerLeft={<button className="cor-btn cor-btn--ghost">← Back</button>}
      footerRight={<button className="cor-btn">Continue →</button>}
    >
      <WizardTitle
        title="Choose your talents"
        blurb="Talents are habits forged in the dark between worlds. Three come pre-set; pick one more from the open list."
      />

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1.1fr 1fr',
          gap: 24,
          maxWidth: 1100,
          margin: '0 auto',
        }}
      >
        {/* LEFT — granted talents */}
        <div>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              marginBottom: 10,
            }}
          >
            <div
              className="cor-display cor-track-08 cor-uppercase"
              style={{ fontSize: 13, color: 'var(--brand-brass-light)', letterSpacing: '0.18em' }}
            >
              Granted
            </div>
            <div
              className="cor-body cor-uppercase"
              style={{ fontSize: 9, color: 'var(--text-secondary)', letterSpacing: '0.18em' }}
            >
              From Icon · Group
            </div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <TalentChip t={iconTalent} locked />
            {crewTalents.map((t) => (
              <TalentChip key={t.name} t={t} locked />
            ))}
          </div>

          <div
            style={{
              marginTop: 18,
              padding: '12px 14px',
              background: 'var(--surface-night)',
              border: '1px solid var(--brand-brass-deep)',
              borderRadius: 4,
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
            }}
          >
            <span
              className="cor-body cor-uppercase"
              style={{ fontSize: 10, color: 'var(--brand-brass)', letterSpacing: '0.16em' }}
            >
              Talents chosen
            </span>
            <span
              className="cor-mono"
              style={{
                fontSize: 18,
                fontWeight: 700,
                color: filled === SLOTS ? 'var(--state-success)' : 'var(--brand-brass-light)',
              }}
            >
              {filled} / {SLOTS}
            </span>
          </div>
        </div>

        {/* RIGHT — pickable list */}
        <div>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              marginBottom: 10,
            }}
          >
            <div
              className="cor-display cor-track-08 cor-uppercase"
              style={{ fontSize: 13, color: 'var(--brand-brass-light)', letterSpacing: '0.18em' }}
            >
              Pick one
            </div>
            <div
              className="cor-body cor-uppercase"
              style={{ fontSize: 9, color: 'var(--text-secondary)', letterSpacing: '0.18em' }}
            >
              General talents
            </div>
          </div>
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(2, 1fr)',
              gap: 8,
              maxHeight: 540,
              overflowY: 'auto',
              paddingRight: 4,
            }}
          >
            {offered.map((t) => (
              <TalentChip key={t.name} t={t} picked={t.sel} free />
            ))}
          </div>
        </div>
      </div>
    </WizardShell>
  );
};

// STEP 8 — GEAR
const Wizard8Gear = () => {
  const picked = [
    { n: 'Vulcan Carbine', cat: 'Weapon', meta: 'Bonus 2 · 0.8 enc' },
    { n: 'Heavy EVA suit', cat: 'Armor', meta: 'Armor 6 · 1.0 enc' },
    { n: 'Comms unit', cat: 'Tech', meta: 'Bonus 1 · 0.2 enc' },
    { n: 'Astrolabe charm', cat: 'Personal', meta: 'Trinket of The Traveler' },
  ];
  const offered = [
    { n: 'Field knife', cat: 'Weapon', cost: '50 b' },
    { n: 'Light EVA suit', cat: 'Armor', cost: '500 b' },
    { n: 'Med-spray', cat: 'Tech', cost: '200 b' },
    { n: 'Stim injector ×3', cat: 'Tech', cost: '300 b' },
    { n: 'Gravsled', cat: 'Vehicle', cost: '1200 b' },
    { n: 'Religious tract', cat: 'Personal', cost: '20 b' },
  ];
  return (
    <WizardShell
      stepIdx={7}
      footerCenter="Starting birr · 600. Equipped items count toward your encumbrance."
      footerLeft={<button className="cor-btn cor-btn--ghost">← Back</button>}
      footerRight={<button className="cor-btn">Finish · Forge character</button>}
    >
      <WizardTitle
        title="Outfit your pilot"
        blurb="Concept and group concept give you a starting kit. Add to it from the bazaar; stretch your birr where it matters most."
      />
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: 20,
          maxWidth: 1080,
          margin: '0 auto',
        }}
      >
        <div className="cor-card cor-card--featured" style={{ padding: 20 }}>
          <PanelTitle size="sm">Your kit</PanelTitle>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {picked.map((g) => (
              <div
                key={g.n}
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  padding: '10px 12px',
                  background: 'var(--surface-void)',
                  border: '1px solid rgba(166,124,40,0.4)',
                  borderRadius: 4,
                }}
              >
                <div>
                  <div className="cor-body" style={{ fontSize: 13, color: 'var(--text-primary)' }}>
                    {g.n}
                  </div>
                  <div
                    className="cor-body cor-uppercase"
                    style={{ fontSize: 10, color: 'var(--brand-brass)', letterSpacing: '0.14em' }}
                  >
                    {g.cat}
                  </div>
                </div>
                <div className="cor-mono" style={{ fontSize: 11, color: 'var(--text-secondary)' }}>
                  {g.meta}
                </div>
              </div>
            ))}
          </div>
          <div
            style={{
              marginTop: 14,
              paddingTop: 12,
              borderTop: '1px solid rgba(166,124,40,0.3)',
              display: 'flex',
              justifyContent: 'space-between',
            }}
          >
            <span
              className="cor-body cor-uppercase"
              style={{ fontSize: 10, color: 'var(--brand-brass)', letterSpacing: '0.14em' }}
            >
              Encumbrance
            </span>
            <span className="cor-mono" style={{ fontSize: 14, color: 'var(--text-primary)' }}>
              2.0 / 8.0
            </span>
          </div>
        </div>
        <div className="cor-card" style={{ padding: 20 }}>
          <PanelTitle size="sm">Bazaar</PanelTitle>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 10 }}>
            <span
              className="cor-body cor-uppercase"
              style={{ fontSize: 10, color: 'var(--brand-brass)', letterSpacing: '0.14em' }}
            >
              Birr remaining
            </span>
            <span className="cor-mono" style={{ fontSize: 14, color: 'var(--brand-brass-light)' }}>
              320 / 600
            </span>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {offered.map((g) => (
              <div
                key={g.n}
                style={{
                  display: 'grid',
                  gridTemplateColumns: '1fr 80px auto',
                  alignItems: 'center',
                  gap: 10,
                  padding: '8px 10px',
                  borderBottom: '1px solid rgba(166,124,40,0.2)',
                }}
              >
                <div>
                  <div className="cor-body" style={{ fontSize: 12, color: 'var(--text-primary)' }}>
                    {g.n}
                  </div>
                  <div
                    className="cor-body cor-uppercase"
                    style={{ fontSize: 9, color: 'var(--text-secondary)', letterSpacing: '0.14em' }}
                  >
                    {g.cat}
                  </div>
                </div>
                <span className="cor-mono" style={{ fontSize: 11, color: 'var(--brand-brass)' }}>
                  {g.cost}
                </span>
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
                  Add
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </WizardShell>
  );
};

Object.assign(window, {
  Wizard1Origin,
  Wizard2Concept,
  Wizard3Group,
  Wizard4Attributes,
  Wizard5Icon,
  Wizard6Skills,
  Wizard7Talents,
  Wizard8Gear,
  // Back-compat aliases
  Wizard1Concept: Wizard2Concept,
  Wizard2Group: Wizard3Group,
  Wizard3Attributes: Wizard4Attributes,
  Wizard4Icon: Wizard5Icon,
  Wizard5Skills: Wizard6Skills,
  Wizard6Gear: Wizard8Gear,
  Wizard7Gear: Wizard8Gear,
});
window.WizardIcon = Wizard5Icon;
