// Dice Roller — open + pushed states (rendered as two artboards)
const DiceRollerOpen = () => (
  <div
    className="cor-surface-void"
    style={{
      minHeight: '100%',
      padding: 32,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'center',
    }}
  >
    {/* Floating panel */}
    <div
      className="cor-card cor-card--featured"
      style={{ padding: 28, position: 'relative', maxWidth: 420, margin: '0 auto', width: '100%' }}
    >
      <div style={{ position: 'absolute', top: 6, left: 6 }}>
        <ArabesqueCorner size={26} color="var(--brand-brass)" orientation="tl" />
      </div>
      <div style={{ position: 'absolute', top: 6, right: 6 }}>
        <ArabesqueCorner size={26} color="var(--brand-brass)" orientation="tr" />
      </div>
      <div style={{ position: 'absolute', bottom: 6, left: 6 }}>
        <ArabesqueCorner size={26} color="var(--brand-brass)" orientation="bl" />
      </div>
      <div style={{ position: 'absolute', bottom: 6, right: 6 }}>
        <ArabesqueCorner size={26} color="var(--brand-brass)" orientation="br" />
      </div>

      <PanelTitle size="md">Pilot · Evade</PanelTitle>

      <div
        className="cor-body"
        style={{ fontSize: 12, color: 'var(--text-secondary)', marginBottom: 14 }}
      >
        Agility 5 + Pilot 5 − Broken arm 2 ={' '}
        <span className="cor-mono" style={{ color: 'var(--brand-brass-light)', fontSize: 13 }}>
          8 dice
        </span>
      </div>

      {/* Pool size selector */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 18 }}>
        <button
          style={{
            width: 36,
            height: 36,
            border: '1px solid var(--brand-brass-deep)',
            background: 'transparent',
            color: 'var(--brand-brass)',
            borderRadius: 4,
            fontSize: 16,
            cursor: 'pointer',
          }}
        >
          −
        </button>
        <div
          className="cor-mono"
          style={{
            fontSize: 28,
            fontWeight: 700,
            color: 'var(--text-primary)',
            minWidth: 48,
            textAlign: 'center',
          }}
        >
          8
        </div>
        <button
          style={{
            width: 36,
            height: 36,
            border: '1px solid var(--brand-brass-deep)',
            background: 'transparent',
            color: 'var(--brand-brass)',
            borderRadius: 4,
            fontSize: 16,
            cursor: 'pointer',
          }}
        >
          +
        </button>
        <div style={{ flex: 1, display: 'flex', gap: 6, justifyContent: 'flex-end' }}>
          <span className="cor-chip">+ Talent</span>
          <span className="cor-chip">+ Gear</span>
        </div>
      </div>

      {/* Dice result */}
      <div
        style={{
          padding: 18,
          background: 'var(--surface-void)',
          border: '1px solid var(--brand-brass-shadow)',
          borderRadius: 4,
          marginBottom: 16,
        }}
      >
        <div
          className="cor-body cor-uppercase"
          style={{
            fontSize: 10,
            color: 'var(--brand-brass)',
            letterSpacing: '0.16em',
            marginBottom: 12,
          }}
        >
          Result · 2 successes
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
          {[6, 3, 1, 5, 4, 6, 2, 4].map((v, i) => (
            <Die key={i} value={v} size={42} />
          ))}
        </div>
      </div>

      {/* Buttons */}
      <button
        className="cor-btn cor-btn--mystic"
        style={{
          width: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 10,
          padding: 14,
          fontFamily: 'Forum, serif',
          fontSize: 16,
          letterSpacing: '0.12em',
          textTransform: 'uppercase',
        }}
      >
        <StarOrnament size={20} color="var(--text-on-brass)" />
        Push the Roll · 1 DP
      </button>
      <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
        <button className="cor-btn cor-btn--secondary" style={{ flex: 1 }}>
          Reroll
        </button>
        <button className="cor-btn cor-btn--ghost" style={{ flex: 1 }}>
          Close
        </button>
      </div>
    </div>
  </div>
);

const DiceRollerPushed = () => (
  <div
    className="cor-surface-void"
    style={{
      minHeight: '100%',
      padding: 32,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'center',
    }}
  >
    <div
      className="cor-card cor-card--featured"
      style={{ padding: 28, position: 'relative', maxWidth: 480, margin: '0 auto', width: '100%' }}
    >
      <div style={{ position: 'absolute', top: 6, left: 6 }}>
        <ArabesqueCorner size={26} color="var(--brand-brass)" orientation="tl" />
      </div>
      <div style={{ position: 'absolute', top: 6, right: 6 }}>
        <ArabesqueCorner size={26} color="var(--brand-brass)" orientation="tr" />
      </div>
      <div style={{ position: 'absolute', bottom: 6, left: 6 }}>
        <ArabesqueCorner size={26} color="var(--brand-brass)" orientation="bl" />
      </div>
      <div style={{ position: 'absolute', bottom: 6, right: 6 }}>
        <ArabesqueCorner size={26} color="var(--brand-brass)" orientation="br" />
      </div>

      <PanelTitle size="md">Pilot · Evade · Pushed</PanelTitle>

      <div className="cor-chip cor-chip--mystic" style={{ marginBottom: 16 }}>
        <span
          style={{
            width: 6,
            height: 6,
            borderRadius: '50%',
            background: 'var(--state-mystic-teal)',
          }}
        />
        Prayer accepted · The Traveler hears you
      </div>

      {/* Original + pushed dice rows */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          gap: 14,
          padding: 18,
          background: 'var(--surface-void)',
          border: '1px solid var(--brand-brass-shadow)',
          borderRadius: 4,
          marginBottom: 16,
        }}
      >
        <div>
          <div
            className="cor-body cor-uppercase"
            style={{
              fontSize: 10,
              color: 'var(--text-secondary)',
              letterSpacing: '0.16em',
              marginBottom: 8,
            }}
          >
            Original · 2 successes
          </div>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {[6, 3, 1, 5, 4, 6, 2, 4].map((v, i) => {
              const kept = v === 6;
              return (
                <div key={i} style={{ opacity: kept ? 1 : 0.35 }}>
                  <Die value={v} size={36} />
                </div>
              );
            })}
          </div>
        </div>

        <div
          style={{ display: 'flex', alignItems: 'center', gap: 10, color: 'var(--brand-brass)' }}
        >
          <div style={{ flex: 1, height: 1, background: 'var(--brand-brass-deep)' }} />
          <span
            className="cor-display cor-uppercase"
            style={{ fontSize: 11, letterSpacing: '0.2em' }}
          >
            ↳ Pushed
          </span>
          <div style={{ flex: 1, height: 1, background: 'var(--brand-brass-deep)' }} />
        </div>

        <div>
          <div
            className="cor-body cor-uppercase"
            style={{
              fontSize: 10,
              color: 'var(--state-mystic-teal)',
              letterSpacing: '0.16em',
              marginBottom: 8,
            }}
          >
            Reroll · +2 successes (4 total)
          </div>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {/* Kept 6s, then 6 pushed dice translated right */}
            <Die value={6} size={36} />
            <Die value={6} size={36} />
            <span style={{ width: 12 }} />
            {[6, 2, 6, 4, 1, 5].map((v, i) => (
              <div key={i} style={{ transform: 'translateY(-2px)' }}>
                <Die value={v} size={36} pushed />
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Aftermath */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 8 }}>
        <div
          style={{
            padding: 12,
            background: 'rgba(91,42,120,0.18)',
            border: '1px solid rgba(165,123,200,0.4)',
            borderRadius: 4,
          }}
        >
          <div
            className="cor-body cor-uppercase"
            style={{ fontSize: 10, color: '#C5A3D8', letterSpacing: '0.14em', marginBottom: 4 }}
          >
            Darkness
          </div>
          <div className="cor-mono" style={{ fontSize: 18, fontWeight: 700, color: '#E1C8F0' }}>
            +1 DP
          </div>
        </div>
        <div
          style={{
            padding: 12,
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
              letterSpacing: '0.14em',
              marginBottom: 4,
            }}
          >
            Cost
          </div>
          <div className="cor-body" style={{ fontSize: 13, color: 'var(--text-primary)' }}>
            −1 random Attribute
          </div>
        </div>
      </div>
    </div>
  </div>
);

window.DiceRollerOpen = DiceRollerOpen;
window.DiceRollerPushed = DiceRollerPushed;
