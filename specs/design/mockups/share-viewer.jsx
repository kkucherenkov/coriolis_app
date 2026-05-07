// Share-Link Viewer — public read-only sheet, parchment chrome
const ShareViewer = () => (
  <div style={{ minHeight: '100%', background: 'var(--surface-void)', position: 'relative' }}>
    {/* Watermark stars */}
    <div style={{ position: 'absolute', inset: 0, display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gridAutoRows: 200, opacity: 0.05, pointerEvents: 'none' }}>
      {Array.from({ length: 24 }).map((_, i) => (
        <div key={i} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <StarOrnament size={64} color="var(--brand-brass-light)" />
        </div>
      ))}
    </div>

    {/* Parchment banner */}
    <div style={{
      position: 'relative',
      background: 'var(--surface-parchment)',
      color: 'var(--text-ink)',
      padding: '14px 56px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      borderBottom: '2px solid var(--brand-brass-deep)',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
        <StarOrnament size={28} color="var(--brand-brass-shadow)" />
        <div>
          <div className="cor-display cor-track-04" style={{ fontSize: 18, lineHeight: 1.1 }}>Shared by Iskander Vahn</div>
          <div className="cor-body" style={{ fontSize: 12, fontStyle: 'italic', opacity: 0.7 }}>Last updated 2 hours ago · Read-only view</div>
        </div>
      </div>
      <div className="cor-body cor-uppercase" style={{ fontSize: 10, letterSpacing: '0.24em', opacity: 0.7 }}>
        coriolis.app/shared/character/tariq-asari
      </div>
    </div>

    {/* Sheet header (no edit affordances) */}
    <div style={{ position: 'relative', padding: '40px 56px 24px', borderBottom: '1px solid var(--brand-brass-deep)' }}>
      <div style={{ position: 'absolute', top: 12, left: 12 }}><ArabesqueCorner size={48} color="var(--brand-brass)" orientation="tl" /></div>
      <div style={{ position: 'absolute', top: 12, right: 12 }}><ArabesqueCorner size={48} color="var(--brand-brass)" orientation="tr" /></div>
      <div style={{ display: 'grid', gridTemplateColumns: '120px 1fr auto', gap: 36, alignItems: 'center' }}>
        <Portrait initials="TA" size={120} />
        <div>
          <div className="cor-body cor-uppercase" style={{ fontSize: 11, color: 'var(--brand-brass)', letterSpacing: '0.3em', marginBottom: 8 }}>Pilot · Free League</div>
          <h1 className="cor-display cor-track-04" style={{ fontSize: 44, color: 'var(--brand-brass-light)', margin: 0, fontWeight: 400 }}>Tariq al-Asari</h1>
          <Swash width={180} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 14 }}>
            <IconMedallion letter="T" size={28} />
            <span className="cor-body" style={{ fontSize: 13, color: 'var(--text-secondary)' }}>The Traveler · Crew of the Madara</span>
          </div>
        </div>
        <div style={{ display: 'flex', gap: 28 }}>
          <div style={{ textAlign: 'center' }}>
            <div className="cor-body cor-uppercase" style={{ fontSize: 11, color: 'var(--brand-brass)', letterSpacing: '0.18em' }}>HP</div>
            <div className="cor-mono" style={{ fontSize: 32, fontWeight: 700, color: 'var(--text-primary)' }}>11<span style={{ color: 'var(--text-secondary)', fontSize: 18 }}> / 12</span></div>
          </div>
          <div style={{ textAlign: 'center' }}>
            <div className="cor-body cor-uppercase" style={{ fontSize: 11, color: 'var(--state-mystic-teal)', letterSpacing: '0.18em' }}>MP</div>
            <div className="cor-mono" style={{ fontSize: 32, fontWeight: 700, color: 'var(--text-primary)' }}>8<span style={{ color: 'var(--text-secondary)', fontSize: 18 }}> / 10</span></div>
          </div>
        </div>
      </div>
    </div>

    {/* Content (slimmer, read-only) */}
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 24, padding: '32px 56px', position: 'relative' }}>
      <div className="cor-card" style={{ padding: 20 }}>
        <PanelTitle size="md">Attributes</PanelTitle>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16 }}>
          {[['Strength', 3], ['Agility', 5], ['Wits', 4], ['Empathy', 3]].map(([k, v]) => <StatBlock key={k} label={k} value={v} />)}
        </div>
      </div>
      <div className="cor-card" style={{ padding: 20 }}>
        <PanelTitle size="md">Skills (top)</PanelTitle>
        {[
          { name: 'Pilot', attr: 'AGI', rank: 5 },
          { name: 'Observation', attr: 'WIT', rank: 4 },
          { name: 'Dexterity', attr: 'AGI', rank: 4 },
          { name: 'Ranged Combat', attr: 'AGI', rank: 3 },
        ].map(s => <SkillRow key={s.name} {...s} />)}
      </div>
    </div>

    <div style={{ padding: '24px 56px 48px', textAlign: 'center', position: 'relative' }}>
      <div className="cor-body" style={{ fontSize: 11, color: 'var(--text-secondary)', fontStyle: 'italic' }}>
        This is a read-only share. Sign in to create your own character sheet.
      </div>
    </div>
  </div>
);

window.ShareViewer = ShareViewer;
