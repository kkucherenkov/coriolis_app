<script setup lang="ts">
  import { computed } from 'vue';

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:pickedTalentIds': [value: string[]];
  }>();

  // TODO(wizard-step-7-relationships): Relationships step deferred to v1.1+.

  const MAX_FREE_PICKS = 3;

  interface TalentEntry {
    id: string;
    name: string;
    description: string;
  }

  interface Props {
    pickedTalentIds: string[];
  }

  const { t } = useI18n({ useScope: 'local' });

  // Static talent pool for v1. Sourced from Coriolis core rulebook general talents.
  const TALENT_POOL: TalentEntry[] = [
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

  const pickedCount = computed<number>(() => props.pickedTalentIds.length);
  const canPickMore = computed<boolean>(() => pickedCount.value < MAX_FREE_PICKS);

  function isPicked(id: string): boolean {
    return props.pickedTalentIds.includes(id);
  }

  function toggle(id: string): void {
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
    "counter": "{count} / {max} selected",
    "pickPrompt": "Pick up to {max} starting talents. You can add more later on the character sheet.",
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
    }
  },
  "ru": {
    "counter": "Выбрано {count} / {max}",
    "pickPrompt": "Выберите до {max} начальных талантов. Остальные можно добавить позже.",
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
    }
  },
  "uk": {
    "counter": "[uk-todo] {count} / {max} selected",
    "pickPrompt": "[uk-todo] Pick up to {max} starting talents.",
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
      "combatVeteranDesc": "[uk-todo] Once per turn, ignore the first point of damage.",
      "defenderOfFaithDesc": "[uk-todo] +2 to Mystic Powers for believers.",
      "everydayHeroDesc": "[uk-todo] When pushing, 5 also counts.",
      "executionerDesc": "[uk-todo] +1 damage vs prone.",
      "facelessDesc": "[uk-todo] Disappear from a scene.",
      "gunfighterDesc": "[uk-todo] Draw sidearm free; +1 init.",
      "hardToKillDesc": "[uk-todo] +1 HP from Medicurgy.",
      "investigatorDesc": "[uk-todo] Learn place history.",
      "juryRiggerDesc": "[uk-todo] Repair tech +1.",
      "killerInstinctDesc": "[uk-todo] +1 melee damage.",
      "linguistDesc": "[uk-todo] Speak all languages.",
      "nineLivesDesc": "[uk-todo] Stay on 1 HP."
    }
  },
  "el": {
    "counter": "[el-todo] {count} / {max} selected",
    "pickPrompt": "[el-todo] Pick up to {max} starting talents.",
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
      "combatVeteranDesc": "[el-todo] Once per turn, ignore the first point of damage.",
      "defenderOfFaithDesc": "[el-todo] +2 to Mystic Powers for believers.",
      "everydayHeroDesc": "[el-todo] When pushing, 5 also counts.",
      "executionerDesc": "[el-todo] +1 damage vs prone.",
      "facelessDesc": "[el-todo] Disappear from a scene.",
      "gunfighterDesc": "[el-todo] Draw sidearm free; +1 init.",
      "hardToKillDesc": "[el-todo] +1 HP from Medicurgy.",
      "investigatorDesc": "[el-todo] Learn place history.",
      "juryRiggerDesc": "[el-todo] Repair tech +1.",
      "killerInstinctDesc": "[el-todo] +1 melee damage.",
      "linguistDesc": "[el-todo] Speak all languages.",
      "nineLivesDesc": "[el-todo] Stay on 1 HP."
    }
  }
}
</i18n>

<template>
  <div class="step-talents">
    <div class="step-talents__meta">
      <span class="step-talents__counter">
        {{ t('counter', { count: pickedCount, max: MAX_FREE_PICKS }) }}
      </span>
      <p class="step-talents__prompt">
        {{ t('pickPrompt', { max: MAX_FREE_PICKS }) }}
      </p>
    </div>

    <div class="step-talents__grid">
      <div
        v-for="talent in TALENT_POOL"
        :key="talent.id"
        class="step-talents__card"
        :class="{
          'step-talents__card--picked': isPicked(talent.id),
          'step-talents__card--disabled': !isPicked(talent.id) && !canPickMore,
        }"
        role="checkbox"
        :aria-checked="isPicked(talent.id)"
        tabindex="0"
        @click="toggle(talent.id)"
        @keydown.enter.space.prevent="toggle(talent.id)"
      >
        <div class="step-talents__card-head">
          <span class="step-talents__talent-name">
            {{ t(`talentName.${talent.name}`) }}
          </span>
          <span
            v-if="isPicked(talent.id)"
            class="step-talents__badge"
          >
            {{ t('pickedBadge') }}
          </span>
        </div>
        <p class="step-talents__desc">
          {{ t(`talentDesc.${talent.description}`) }}
        </p>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  $talents-max-width: 1000px;

  .step-talents {
    max-width: $talents-max-width;
    margin: 0 auto;

    &__meta {
      margin-bottom: var(--space-6);
      text-align: center;
    }

    &__counter {
      font-family: var(--font-mono);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__prompt {
      margin: var(--space-2) 0 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
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
  }
</style>
