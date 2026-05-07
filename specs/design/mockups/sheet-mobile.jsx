// Character Sheet — Mobile (375x812), Russian locale to demo Cyrillic
const SheetMobile = () => {
  const general = [
    { name: 'Ловкость', attr: 'ЛОВ', rank: 4 },
    { name: 'Сила', attr: 'СИЛ', rank: 1 },
    { name: 'Скрытность', attr: 'ЛОВ', rank: 3 },
    { name: 'Манипуляция', attr: 'ЭМП', rank: 2 },
    { name: 'Ближний бой', attr: 'СИЛ', rank: 1 },
    { name: 'Наблюдательность', attr: 'УМ', rank: 4 },
    { name: 'Дальний бой', attr: 'ЛОВ', rank: 3 },
    { name: 'Выживание', attr: 'УМ', rank: 2 },
  ];
  const advanced = [
    { name: 'Пилотаж', attr: 'ЛОВ', rank: 5, key: true },
    { name: 'Технологии', attr: 'УМ', rank: 3 },
    { name: 'Дата-джинн', attr: 'УМ', rank: 2 },
    { name: 'Командование', attr: 'ЭМП', rank: 2 },
    { name: 'Наука!', attr: 'УМ', rank: 1 },
    { name: 'Культура', attr: 'ЭМП', rank: 1 },
    { name: 'Медикургия', attr: 'УМ', rank: 0 },
    { name: 'Мистика', attr: 'ЭМП', rank: 0 },
  ];

  return (
    <div className="cor-surface-void" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column', overflow: 'hidden', position: 'relative' }}>
      {/* Status bar */}
      <div style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 18px 0', fontSize: 11, color: 'var(--text-secondary)' }}>
        <span className="cor-mono">04:32</span>
        <span className="cor-mono">●●●●○</span>
      </div>

      {/* Sticky condensed header */}
      <div style={{
        position: 'relative',
        background: 'linear-gradient(180deg, #15193F 0%, #0B0E2C 100%)',
        borderBottom: '1px solid var(--brand-brass-deep)',
        padding: '12px 18px 14px',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <Portrait initials="ТА" size={36} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="cor-display cor-track-04" style={{ fontSize: 18, color: 'var(--brand-brass-light)', lineHeight: 1.1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
              Тарик аль-Асари
            </div>
            <div className="cor-body" style={{ fontSize: 10, color: 'var(--text-secondary)', letterSpacing: '0.06em' }}>Пилот · Странник</div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            <MiniCounter label="ОЗ" v={11} m={12} />
            <MiniCounter label="ОР" v={8} m={10} mystic />
          </div>
        </div>
        {/* condition pills */}
        <div style={{ display: 'flex', gap: 6, marginTop: 10, overflowX: 'auto' }}>
          <span className="cor-chip cor-chip--cond" style={{ fontSize: 10, padding: '3px 8px' }}>Бессонный</span>
          <span className="cor-chip cor-chip--cond" style={{ fontSize: 10, padding: '3px 8px' }}>Жаждущий</span>
          <span className="cor-chip" style={{ fontSize: 10, padding: '3px 8px' }}>Сломанная рука</span>
        </div>
      </div>

      {/* Body — scrollable area */}
      <div style={{ flex: 1, overflow: 'auto', padding: '18px' }}>
        {/* Attributes */}
        <div className="cor-card" style={{ padding: 14, marginBottom: 14 }}>
          <div className="cor-display cor-track-04" style={{ fontSize: 14, color: 'var(--brand-brass-light)', marginBottom: 10, letterSpacing: '0.08em', textTransform: 'uppercase' }}>Атрибуты</div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8 }}>
            {[['СИЛ', 3], ['ЛОВ', 5], ['УМ', 4], ['ЭМП', 3]].map(([k, v]) => (
              <div key={k} style={{ textAlign: 'center', padding: '8px 4px', background: 'var(--surface-void)', border: '1px solid rgba(166,124,40,0.4)', borderRadius: 4 }}>
                <div className="cor-body cor-uppercase" style={{ fontSize: 9, color: 'var(--brand-brass)', letterSpacing: '0.14em' }}>{k}</div>
                <div className="cor-mono" style={{ fontSize: 22, fontWeight: 700, color: 'var(--text-primary)', lineHeight: 1.1 }}>{v}</div>
                <div style={{ display: 'flex', justifyContent: 'center', gap: 2, marginTop: 4 }}>
                  {Array.from({ length: 5 }).map((_, i) => (
                    <span key={i} style={{ width: 5, height: 5, borderRadius: '50%', background: i < v ? 'var(--brand-brass)' : 'transparent', border: '1px solid var(--brand-brass-deep)' }} />
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Skills — split into general + advanced */}
        <div className="cor-card" style={{ padding: 14, marginBottom: 14 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
            <div className="cor-display cor-track-04" style={{ fontSize: 14, color: 'var(--brand-brass-light)', letterSpacing: '0.08em', textTransform: 'uppercase' }}>Навыки</div>
            <div style={{ display: 'flex', gap: 10, fontSize: 9, fontFamily: 'Inter', letterSpacing: '0.12em', textTransform: 'uppercase' }}>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, color: 'var(--text-secondary)' }}>
                <span className="cor-dot cor-dot--filled" style={{ width: 6, height: 6 }} />
                Общие
              </span>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, color: 'var(--state-mystic-teal)' }}>
                <StarOrnament size={9} color="var(--state-mystic-teal)" />
                Спец.
              </span>
            </div>
          </div>

          <div className="cor-display cor-track-04 cor-uppercase" style={{ fontSize: 10, color: 'var(--brand-brass)', letterSpacing: '0.18em', marginBottom: 4, paddingBottom: 4, borderBottom: '1px solid var(--brand-brass-deep)' }}>Общие</div>
          {general.map(s => (
            <div key={s.name} style={{ display: 'grid', gridTemplateColumns: '1fr auto auto', alignItems: 'center', gap: 10, padding: '6px 0', borderBottom: '1px solid rgba(166,124,40,0.15)' }}>
              <span className="cor-body" style={{ fontSize: 12, color: 'var(--text-primary)' }}>{s.name}</span>
              <span className="cor-body cor-uppercase" style={{ fontSize: 9, color: 'var(--brand-brass)', letterSpacing: '0.14em' }}>{s.attr}</span>
              <span className="cor-dots">
                {Array.from({ length: 5 }).map((_, i) => <span key={i} className={`cor-dot ${i < s.rank ? 'cor-dot--filled' : ''}`} style={{ width: 6, height: 6 }} />)}
              </span>
            </div>
          ))}

          <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 10, color: 'var(--state-mystic-teal)', fontFamily: 'Forum, serif', letterSpacing: '0.18em', textTransform: 'uppercase', marginTop: 12, marginBottom: 4, paddingBottom: 4, borderBottom: '1px solid var(--state-mystic-teal)' }}>
            <StarOrnament size={10} color="var(--state-mystic-teal)" />
            Специальные
          </div>
          {advanced.map(s => (
            <div key={s.name} style={{ position: 'relative', display: 'grid', gridTemplateColumns: '1fr auto auto', alignItems: 'center', gap: 10, padding: '6px 0 6px 8px', borderBottom: '1px solid rgba(166,124,40,0.15)' }}>
              <span style={{ position: 'absolute', left: 0, top: 6, bottom: 6, width: 2, background: s.rank > 0 ? 'var(--state-mystic-teal)' : 'rgba(43,163,160,0.25)', borderRadius: 1 }} />
              <span className="cor-body" style={{ fontSize: 12, color: 'var(--text-primary)', display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                {s.name}
                {s.key && <span className="cor-chip cor-chip--mystic" style={{ fontSize: 8, padding: '0 5px' }}>ключ.</span>}
              </span>
              <span className="cor-body cor-uppercase" style={{ fontSize: 9, color: 'var(--brand-brass)', letterSpacing: '0.14em' }}>{s.attr}</span>
              <span className="cor-dots">
                {Array.from({ length: 5 }).map((_, i) => <span key={i} className={`cor-dot ${i < s.rank ? 'cor-dot--filled' : ''}`} style={{ width: 6, height: 6 }} />)}
              </span>
            </div>
          ))}
        </div>

        {/* Push status floating CTA */}
        <button style={{
          width: '100%', padding: 14,
          background: 'rgba(43,163,160,0.12)',
          border: '1px solid var(--state-mystic-teal)',
          color: 'var(--state-mystic-teal)',
          borderRadius: 4,
          fontFamily: 'Forum, serif', fontSize: 14, letterSpacing: '0.1em', textTransform: 'uppercase',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          cursor: 'pointer',
        }}>
          <StarOrnament size={18} color="var(--state-mystic-teal)" />
          Подтолкнуть бросок
        </button>
      </div>

      {/* Bottom tab bar */}
      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)',
        background: 'var(--surface-night)',
        borderTop: '1px solid var(--brand-brass-deep)',
        padding: '8px 0 18px',
      }}>
        {[
          { k: 'Параметры', a: true, l: 'S' },
          { k: 'Снаряжение', l: 'G' },
          { k: 'Таланты', l: 'T' },
          { k: 'Заметки', l: 'N' },
        ].map(t => (
          <div key={t.k} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
            color: t.a ? 'var(--brand-brass-light)' : 'var(--text-secondary)',
            position: 'relative',
          }}>
            <div style={{
              width: 28, height: 28, borderRadius: '50%',
              border: `1px solid ${t.a ? 'var(--brand-brass)' : 'var(--brand-brass-shadow)'}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span className="cor-display" style={{ fontSize: 13 }}>{t.l}</span>
            </div>
            <span className="cor-body" style={{ fontSize: 9, letterSpacing: '0.06em' }}>{t.k}</span>
            {t.a && <div style={{ position: 'absolute', bottom: -8, width: 16, height: 2, background: 'var(--brand-brass)' }} />}
          </div>
        ))}
      </div>
    </div>
  );
};

const MiniCounter = ({ label, v, m, mystic }) => (
  <div style={{ textAlign: 'center', minWidth: 44 }}>
    <div className="cor-body cor-uppercase" style={{ fontSize: 9, color: mystic ? 'var(--state-mystic-teal)' : 'var(--brand-brass)', letterSpacing: '0.14em' }}>{label}</div>
    <div className="cor-mono" style={{ fontSize: 16, fontWeight: 700, color: 'var(--text-primary)', lineHeight: 1.1 }}>
      {v}<span style={{ color: 'var(--text-secondary)', fontSize: 10 }}>/{m}</span>
    </div>
  </div>
);

window.SheetMobile = SheetMobile;
