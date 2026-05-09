<script setup lang="ts">
  import { computed } from 'vue';
  import type { IconId, CrewConcept } from '@app/api-client-ts';

  // TODO(wizard-step-7-relationships): Relationships step deferred to v1.1+.

  interface PersonalTalent {
    id: string;
    name: string;
    description: string;
  }

  interface Props {
    pickedTalentIds: string[];
    iconId: IconId | null;
    crewConcept: CrewConcept | null;
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:pickedTalentIds': [value: string[]];
  }>();

  const MAX_PERSONAL_PICKS = 1;

  const { t } = useI18n({ useScope: 'local' });

  // ST3001 ch.4 — placeholder personal talent pool. The full catalog is
  // populated in Block 4 (Talent catalog data + i18n).
  const PERSONAL_POOL: PersonalTalent[] = [
    { id: 'combat-veteran', name: 'combatVeteran', description: 'combatVeteranDesc' },
    { id: 'defender-of-faith', name: 'defenderOfFaith', description: 'defenderOfFaithDesc' },
    { id: 'everyday-hero', name: 'everydayHero', description: 'everydayHeroDesc' },
    { id: 'executioner', name: 'executioner', description: 'executionerDesc' },
    { id: 'faceless', name: 'faceless', description: 'facelessDesc' },
    { id: 'gunfighter', name: 'gunfighter', description: 'gunfighterDesc' },
    { id: 'hard-to-kill', name: 'hardToKill', description: 'hardToKillDesc' },
    { id: 'investigator', name: 'investigator', description: 'investigatorDesc' },
    { id: 'jury-rigger', name: 'juryRigger', description: 'juryRiggerDesc' },
    { id: 'killer-instinct', name: 'killerInstinct', description: 'killerInstinctDesc' },
    { id: 'linguist', name: 'linguist', description: 'linguistDesc' },
    { id: 'nine-lives', name: 'nineLives', description: 'nineLivesDesc' },
  ];

  // Auto-derived iconGift label — actual talent ID is recorded server-side.
  const iconGiftLabel = computed<string>(() =>
    props.iconId ? t(`iconGiftName.${props.iconId}`) : '',
  );

  // Crew talent placeholder: catalog data is Block 4. For now we just label
  // the section with the chosen crew concept so the player sees the slot.
  const crewLabel = computed<string>(() =>
    props.crewConcept ? t(`crewName.${props.crewConcept}`) : '',
  );

  const personalPicked = computed<string[]>(() =>
    props.pickedTalentIds.filter((id) => PERSONAL_POOL.some((p) => p.id === id)),
  );

  const canPickMore = computed<boolean>(() => personalPicked.value.length < MAX_PERSONAL_PICKS);

  function isPicked(id: string): boolean {
    return personalPicked.value.includes(id);
  }

  function togglePersonal(id: string): void {
    if (isPicked(id)) {
      emit(
        'update:pickedTalentIds',
        props.pickedTalentIds.filter((x) => x !== id),
      );
    } else if (canPickMore.value) {
      emit('update:pickedTalentIds', [...props.pickedTalentIds, id]);
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "intro": "Each character begins with three talents — one personal, one shared by your crew, and one icon gift derived from your patron Icon.",
    "personal": {
      "title": "Personal talent",
      "help": "Pick {max} talent that fits your character. (Block 4 will narrow this list to your concept's personal pool.)",
      "counter": "{count} / {max} selected"
    },
    "crew": {
      "title": "Crew talent",
      "help": "Shared by your team. Catalog comes in Block 4 — for now your crew gets one of the talents from the {label} amplua.",
      "noCrew": "Pick a crew amplua on Step 2 first."
    },
    "iconGift": {
      "title": "Icon gift",
      "help": "Auto-derived from the Icon you chose on Step 3. The full gift description loads on the character sheet once Block 4 catalog is in.",
      "noIcon": "Pick an Icon on Step 3 first."
    },
    "pickedBadge": "Picked",
    "talentName": {
      "combatVeteran": "Combat Veteran",
      "defenderOfFaith": "Defender of the Faith",
      "everydayHero": "Everyday Hero",
      "executioner": "Executioner",
      "faceless": "Faceless",
      "gunfighter": "Gunfighter",
      "hardToKill": "Hard to Kill",
      "investigator": "Investigator",
      "juryRigger": "Jury-Rigger",
      "killerInstinct": "Killer Instinct",
      "linguist": "Linguist",
      "nineLives": "Nine Lives"
    },
    "talentDesc": {
      "combatVeteranDesc": "Once per turn, ignore the first point of damage you take.",
      "defenderOfFaithDesc": "+2 to Mystic Powers checks made to defend a fellow believer.",
      "everydayHeroDesc": "When you push a roll, gain 1 success on a 5 as well as a 6.",
      "executionerDesc": "+1 damage when you attack a target who is already prone.",
      "facelessDesc": "NPCs forget you in a crowd. Spend 1 DP to disappear from a scene.",
      "gunfighterDesc": "Draw a sidearm as a free action; +1 initiative in firefights.",
      "hardToKillDesc": "Recover 1 extra HP when treated with Medicurgy.",
      "investigatorDesc": "Take 10 minutes and a Culture roll to learn the recent history of any place.",
      "juryRiggerDesc": "Repair broken tech outside a workshop with a Technology roll at +1.",
      "killerInstinctDesc": "+1 to all Melee Combat damage rolls.",
      "linguistDesc": "You speak every Horizon language well enough to bargain.",
      "nineLivesDesc": "When reduced to 0 HP, spend 1 DP to remain on 1 HP instead."
    },
    "iconGiftName": {
      "lady-of-tears": "Gift of the Lady of Tears",
      "traveler": "Gift of the Traveler",
      "messenger": "Gift of the Messenger",
      "merchant": "Gift of the Merchant",
      "dancer": "Gift of the Dancer",
      "gambler": "Gift of the Gambler",
      "judge": "Gift of the Judge",
      "faceless-one": "Gift of the Faceless One",
      "deckhand": "Gift of the Deckhand"
    },
    "crewName": {
      "free-trader": "Free Traders",
      "mercenary": "Mercenaries",
      "explorer": "Explorers",
      "agents": "Agents",
      "pilgrim": "Pilgrims"
    }
  },
  "ru": {
    "intro": "Каждый персонаж получает три таланта — одно личное достоинство, одно от амплуа команды и один дар Иконы.",
    "personal": {
      "title": "Личное достоинство",
      "help": "Выберите {max} достоинство для своего персонажа. (Block 4 ограничит этот список достоинствами вашего амплуа.)",
      "counter": "Выбрано {count} / {max}"
    },
    "crew": {
      "title": "Достоинство команды",
      "help": "Общее на всю команду. Каталог появится в Block 4 — пока что ваша команда получает одно из достоинств амплуа «{label}».",
      "noCrew": "Сначала выберите амплуа команды на шаге 2."
    },
    "iconGift": {
      "title": "Дар Иконы",
      "help": "Выводится из Иконы, выбранной на шаге 3. Полное описание подгрузится на листе персонажа после Block 4.",
      "noIcon": "Сначала выберите Икону на шаге 3."
    },
    "pickedBadge": "Выбрано",
    "talentName": {
      "combatVeteran": "Ветеран боёв",
      "defenderOfFaith": "Защитник веры",
      "everydayHero": "Обычный герой",
      "executioner": "Палач",
      "faceless": "Безликий",
      "gunfighter": "Стрелок",
      "hardToKill": "Живучий",
      "investigator": "Следователь",
      "juryRigger": "Умелец",
      "killerInstinct": "Инстинкт убийцы",
      "linguist": "Полиглот",
      "nineLives": "Девять жизней"
    },
    "talentDesc": {
      "combatVeteranDesc": "Раз в ход игнорируйте первую единицу полученного урона.",
      "defenderOfFaithDesc": "+2 к броскам Мистических сил при защите союзника-верующего.",
      "everydayHeroDesc": "Когда вы давите бросок, 5 тоже считается успехом.",
      "executionerDesc": "+1 урон при атаке лежащей цели.",
      "facelessDesc": "НПС забывают вас в толпе. Потратьте 1 ОС, чтобы исчезнуть со сцены.",
      "gunfighterDesc": "Достать пистолет — бесплатное действие; +1 к инициативе в перестрелках.",
      "hardToKillDesc": "Получайте на 1 ОЗ больше при лечении Медицинскими технологиями.",
      "investigatorDesc": "За 10 минут и бросок Культуры узнайте недавнюю историю любого места.",
      "juryRiggerDesc": "Починить сломанную технику без мастерской с +1 к броску Технологии.",
      "killerInstinctDesc": "+1 урон во всех бросках Рукопашного боя.",
      "linguistDesc": "Вы говорите на всех языках Горизонта достаточно для торга.",
      "nineLivesDesc": "При снижении ОЗ до 0 потратьте 1 ОС, чтобы остаться с 1 ОЗ."
    },
    "iconGiftName": {
      "lady-of-tears": "Дар Владычицы Слёз",
      "traveler": "Дар Странника",
      "messenger": "Дар Вестника",
      "merchant": "Дар Купца",
      "dancer": "Дар Плясуньи",
      "gambler": "Дар Игрока",
      "judge": "Дар Судьи",
      "faceless-one": "Дар Безликого",
      "deckhand": "Дар Палубного"
    },
    "crewName": {
      "free-trader": "Вольные торговцы",
      "mercenary": "Наёмники",
      "explorer": "Исследователи",
      "agents": "Агенты",
      "pilgrim": "Пилигримы"
    }
  },
  "uk": {
    "intro": "[uk-todo] Three starting talents.",
    "personal": {
      "title": "[uk-todo] Personal talent",
      "help": "[uk-todo] Pick {max} talent.",
      "counter": "[uk-todo] {count} / {max} selected"
    },
    "crew": {
      "title": "[uk-todo] Crew talent",
      "help": "[uk-todo] Shared by team. Crew amplua: {label}.",
      "noCrew": "[uk-todo] Pick crew on Step 2."
    },
    "iconGift": {
      "title": "[uk-todo] Icon gift",
      "help": "[uk-todo] Derived from chosen Icon.",
      "noIcon": "[uk-todo] Pick Icon on Step 3."
    },
    "pickedBadge": "[uk-todo] Picked",
    "talentName": {
      "combatVeteran": "[uk-todo] Combat Veteran",
      "defenderOfFaith": "[uk-todo] Defender of the Faith",
      "everydayHero": "[uk-todo] Everyday Hero",
      "executioner": "[uk-todo] Executioner",
      "faceless": "[uk-todo] Faceless",
      "gunfighter": "[uk-todo] Gunfighter",
      "hardToKill": "[uk-todo] Hard to Kill",
      "investigator": "[uk-todo] Investigator",
      "juryRigger": "[uk-todo] Jury-Rigger",
      "killerInstinct": "[uk-todo] Killer Instinct",
      "linguist": "[uk-todo] Linguist",
      "nineLives": "[uk-todo] Nine Lives"
    },
    "talentDesc": {
      "combatVeteranDesc": "[uk-todo] ...",
      "defenderOfFaithDesc": "[uk-todo] ...",
      "everydayHeroDesc": "[uk-todo] ...",
      "executionerDesc": "[uk-todo] ...",
      "facelessDesc": "[uk-todo] ...",
      "gunfighterDesc": "[uk-todo] ...",
      "hardToKillDesc": "[uk-todo] ...",
      "investigatorDesc": "[uk-todo] ...",
      "juryRiggerDesc": "[uk-todo] ...",
      "killerInstinctDesc": "[uk-todo] ...",
      "linguistDesc": "[uk-todo] ...",
      "nineLivesDesc": "[uk-todo] ..."
    },
    "iconGiftName": {
      "lady-of-tears": "[uk-todo] Gift of Lady",
      "traveler": "[uk-todo] Gift of Traveler",
      "messenger": "[uk-todo] Gift of Messenger",
      "merchant": "[uk-todo] Gift of Merchant",
      "dancer": "[uk-todo] Gift of Dancer",
      "gambler": "[uk-todo] Gift of Gambler",
      "judge": "[uk-todo] Gift of Judge",
      "faceless-one": "[uk-todo] Gift of Faceless",
      "deckhand": "[uk-todo] Gift of Deckhand"
    },
    "crewName": {
      "free-trader": "[uk-todo] Free Traders",
      "mercenary": "[uk-todo] Mercenaries",
      "explorer": "[uk-todo] Explorers",
      "agents": "[uk-todo] Agents",
      "pilgrim": "[uk-todo] Pilgrims"
    }
  },
  "el": {
    "intro": "[el-todo] Three starting talents.",
    "personal": {
      "title": "[el-todo] Personal talent",
      "help": "[el-todo] Pick {max} talent.",
      "counter": "[el-todo] {count} / {max} selected"
    },
    "crew": {
      "title": "[el-todo] Crew talent",
      "help": "[el-todo] Shared by team. Crew amplua: {label}.",
      "noCrew": "[el-todo] Pick crew on Step 2."
    },
    "iconGift": {
      "title": "[el-todo] Icon gift",
      "help": "[el-todo] Derived from chosen Icon.",
      "noIcon": "[el-todo] Pick Icon on Step 3."
    },
    "pickedBadge": "[el-todo] Picked",
    "talentName": {
      "combatVeteran": "[el-todo] Combat Veteran",
      "defenderOfFaith": "[el-todo] Defender of the Faith",
      "everydayHero": "[el-todo] Everyday Hero",
      "executioner": "[el-todo] Executioner",
      "faceless": "[el-todo] Faceless",
      "gunfighter": "[el-todo] Gunfighter",
      "hardToKill": "[el-todo] Hard to Kill",
      "investigator": "[el-todo] Investigator",
      "juryRigger": "[el-todo] Jury-Rigger",
      "killerInstinct": "[el-todo] Killer Instinct",
      "linguist": "[el-todo] Linguist",
      "nineLives": "[el-todo] Nine Lives"
    },
    "talentDesc": {
      "combatVeteranDesc": "[el-todo] ...",
      "defenderOfFaithDesc": "[el-todo] ...",
      "everydayHeroDesc": "[el-todo] ...",
      "executionerDesc": "[el-todo] ...",
      "facelessDesc": "[el-todo] ...",
      "gunfighterDesc": "[el-todo] ...",
      "hardToKillDesc": "[el-todo] ...",
      "investigatorDesc": "[el-todo] ...",
      "juryRiggerDesc": "[el-todo] ...",
      "killerInstinctDesc": "[el-todo] ...",
      "linguistDesc": "[el-todo] ...",
      "nineLivesDesc": "[el-todo] ..."
    },
    "iconGiftName": {
      "lady-of-tears": "[el-todo] Gift of Lady",
      "traveler": "[el-todo] Gift of Traveler",
      "messenger": "[el-todo] Gift of Messenger",
      "merchant": "[el-todo] Gift of Merchant",
      "dancer": "[el-todo] Gift of Dancer",
      "gambler": "[el-todo] Gift of Gambler",
      "judge": "[el-todo] Gift of Judge",
      "faceless-one": "[el-todo] Gift of Faceless",
      "deckhand": "[el-todo] Gift of Deckhand"
    },
    "crewName": {
      "free-trader": "[el-todo] Free Traders",
      "mercenary": "[el-todo] Mercenaries",
      "explorer": "[el-todo] Explorers",
      "agents": "[el-todo] Agents",
      "pilgrim": "[el-todo] Pilgrims"
    }
  }
}
</i18n>

<template>
  <div class="step-talents">
    <p class="step-talents__intro">
      {{ t('intro') }}
    </p>

    <section class="step-talents__section">
      <header class="step-talents__section-head">
        <h3 class="step-talents__section-title">
          {{ t('personal.title') }}
        </h3>
        <span class="step-talents__counter">
          {{
            t('personal.counter', {
              count: personalPicked.length,
              max: MAX_PERSONAL_PICKS,
            })
          }}
        </span>
      </header>
      <p class="step-talents__section-help">
        {{ t('personal.help', { max: MAX_PERSONAL_PICKS }) }}
      </p>
      <div class="step-talents__grid">
        <div
          v-for="talent in PERSONAL_POOL"
          :key="talent.id"
          class="step-talents__card"
          :class="{
            'step-talents__card--picked': isPicked(talent.id),
            'step-talents__card--disabled': !isPicked(talent.id) && !canPickMore,
          }"
          role="checkbox"
          :aria-checked="isPicked(talent.id)"
          tabindex="0"
          @click="togglePersonal(talent.id)"
          @keydown.enter.space.prevent="togglePersonal(talent.id)"
        >
          <div class="step-talents__card-head">
            <span class="step-talents__talent-name">{{ t(`talentName.${talent.name}`) }}</span>
            <span v-if="isPicked(talent.id)" class="step-talents__badge">
              {{ t('pickedBadge') }}
            </span>
          </div>
          <p class="step-talents__desc">
            {{ t(`talentDesc.${talent.description}`) }}
          </p>
        </div>
      </div>
    </section>

    <section class="step-talents__section">
      <header class="step-talents__section-head">
        <h3 class="step-talents__section-title">
          {{ t('crew.title') }}
        </h3>
      </header>
      <div v-if="crewConcept" class="step-talents__slot step-talents__slot--filled">
        <span class="step-talents__slot-label">{{ crewLabel }}</span>
        <span class="step-talents__slot-help">
          {{ t('crew.help', { label: crewLabel }) }}
        </span>
      </div>
      <div v-else class="step-talents__slot step-talents__slot--empty">
        {{ t('crew.noCrew') }}
      </div>
    </section>

    <section class="step-talents__section">
      <header class="step-talents__section-head">
        <h3 class="step-talents__section-title">
          {{ t('iconGift.title') }}
        </h3>
      </header>
      <div v-if="iconId" class="step-talents__slot step-talents__slot--filled">
        <span class="step-talents__slot-label">{{ iconGiftLabel }}</span>
        <span class="step-talents__slot-help">{{ t('iconGift.help') }}</span>
      </div>
      <div v-else class="step-talents__slot step-talents__slot--empty">
        {{ t('iconGift.noIcon') }}
      </div>
    </section>
  </div>
</template>

<style lang="scss" scoped>
  $talents-max-width: 1000px;

  .step-talents {
    max-width: $talents-max-width;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    gap: var(--space-6);

    &__intro {
      margin: 0;
      text-align: center;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__section {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__section-head {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: var(--space-3);
    }

    &__section-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__section-help {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__counter {
      font-family: var(--font-mono);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass-light);
    }

    &__grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: var(--space-3);

      @media (max-width: 640px) {
        grid-template-columns: 1fr;
      }
    }

    &__card {
      padding: var(--space-4);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      cursor: pointer;
      transition:
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);
      outline: none;

      &:hover:not(.step-talents__card--disabled):not(.step-talents__card--picked) {
        border-color: var(--brand-brass-deep);
        background-color: var(--surface-dawn);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &--picked {
        border-color: var(--brand-brass);
        background-color: var(--surface-dawn);
      }

      &--disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }

    &__card-head {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-2);
      margin-bottom: var(--space-2);
    }

    &__talent-name {
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__badge {
      display: inline-block;
      padding: var(--space-1) var(--space-2);
      background-color: color-mix(in srgb, var(--state-mystic-teal) 15%, transparent);
      border: 1px solid var(--state-mystic-teal);
      border-radius: var(--radius-sm);
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--state-mystic-teal);
      text-transform: uppercase;
      letter-spacing: 0.1em;
      flex-shrink: 0;
    }

    &__desc {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      line-height: 1.5;
    }

    &__slot {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      padding: var(--space-3) var(--space-4);
      border-radius: var(--radius-md);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);

      &--filled {
        background-color: var(--surface-dawn);
        border: 1px solid var(--brand-brass);
      }

      &--empty {
        background-color: var(--surface-night);
        border: 1px dashed var(--brand-brass-shadow);
        color: var(--text-secondary);
        font-style: italic;
      }
    }

    &__slot-label {
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__slot-help {
      color: var(--text-secondary);
      font-style: italic;
    }
  }
</style>
