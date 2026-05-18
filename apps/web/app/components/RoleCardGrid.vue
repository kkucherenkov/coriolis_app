<script setup lang="ts">
  import { useId, nextTick, ref, computed } from 'vue';
  import { rolesForConcept, keySkillsForRole } from '~/utils/roleCatalogue';
  import type { Concept, Role } from '@app/api-client-ts';

  interface Props {
    concept: Concept | null;
    role: Role | null;
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:role': [value: Role | null];
  }>();

  const { t } = useI18n({ useScope: 'local' });

  const id = useId();

  const roles = computed<readonly Role[]>(() => rolesForConcept(props.concept));

  // The index of the currently "active" card (for arrow-key tabindex management).
  // When nothing is selected, index 0 gets tabindex=0.
  const activeIdx = computed<number>(() => {
    if (props.role !== null) {
      const idx = roles.value.indexOf(props.role);
      return idx === -1 ? 0 : idx;
    }
    return 0;
  });

  const radioGroupRef = ref<HTMLElement | null>(null);

  function pickRole(slug: Role): void {
    emit('update:role', props.role === slug ? null : slug);
  }

  function moveFocus(delta: -1 | 1): void {
    const list = roles.value;
    if (list.length === 0) return;
    const next = (activeIdx.value + delta + list.length) % list.length;
    const newRole = list[next] ?? null;
    emit('update:role', newRole);
    void nextTick(() => {
      const btns = radioGroupRef.value?.querySelectorAll<HTMLElement>('[role="radio"]');
      btns?.[next]?.focus();
    });
  }
</script>

<i18n lang="json">
{
  "en": {
    "headline": "Choose your role",
    "keySkillsLabel": "Key skills",
    "role": {
      "companion": {
        "label": "Companion",
        "flavour": "A muse for hire — your craft is people, your stage is everywhere."
      },
      "musician": {
        "label": "Musician",
        "flavour": "Music is the language of the spheres. You play it fluently."
      },
      "poet": {
        "label": "Poet",
        "flavour": "Words cut deeper than blades. Yours leave marks that last."
      },
      "analyst": {
        "label": "Analyst",
        "flavour": "Data is the new ore. You refine it faster than anyone."
      },
      "correspondent": {
        "label": "Correspondent",
        "flavour": "Truth is dangerous cargo. You ship it anyway."
      },
      "network-djinn": {
        "label": "Network Djinn",
        "flavour": "You slip through firewalls like smoke through a cracked viewport."
      },
      "criminal": {
        "label": "Criminal",
        "flavour": "The law is a suggestion. You have always had better ideas."
      },
      "mystic": {
        "label": "Mystic",
        "flavour": "The Icons speak in frequencies others cannot hear. You listen."
      },
      "revolutionary": {
        "label": "Revolutionary",
        "flavour": "The old order burns. You carry the torch and the blueprint."
      },
      "agitator": {
        "label": "Agitator",
        "flavour": "A crowd is an instrument. You know every note to play."
      },
      "diplomat": {
        "label": "Diplomat",
        "flavour": "Peace is the most expensive thing in the Third Horizon. You broker it."
      },
      "dealer": {
        "label": "Dealer",
        "flavour": "Every deal has two sides. You always know which side you are on."
      },
      "assassin": {
        "label": "Assassin",
        "flavour": "Your target never sees you coming. That is the point."
      },
      "guard": {
        "label": "Guard",
        "flavour": "You stand between harm and the people who matter. Simple work."
      },
      "spy": {
        "label": "Spy",
        "flavour": "Every secret has a price. You know who is buying."
      },
      "ace": {
        "label": "Ace",
        "flavour": "Between enemy cannons and a debris field, you pick the debris field."
      },
      "driver": {
        "label": "Driver",
        "flavour": "Wheels under you, the road ahead. Streets, sands, or a ravine — all yours."
      },
      "trucker": {
        "label": "Trucker",
        "flavour": "Long hauls through void lanes. Cargo speaks louder than passengers."
      },
      "colonist": {
        "label": "Colonist",
        "flavour": "You plant roots in soil no one has touched. The horizon is home."
      },
      "prospector": {
        "label": "Prospector",
        "flavour": "Ore, relics, anomalies — if it has value, you will find it first."
      },
      "scout": {
        "label": "Scout",
        "flavour": "You map the edges so others do not fall off them."
      },
      "ascetic": {
        "label": "Ascetic",
        "flavour": "Flesh is noise. You have learned to hear past it."
      },
      "missionary": {
        "label": "Missionary",
        "flavour": "Faith travels farther than any ship. You are its fastest vessel."
      },
      "prophet": {
        "label": "Prophet",
        "flavour": "The Icons showed you the shape of things to come. Now you warn."
      },
      "archaeologist": {
        "label": "Archaeologist",
        "flavour": "The Portal Builders left answers everywhere. You dig them up."
      },
      "medicurg": {
        "label": "Medicurg",
        "flavour": "Flesh and field-surgery: you keep them breathing on the worst days."
      },
      "technologist": {
        "label": "Technologist",
        "flavour": "If it runs on power and logic, you can fix it. Or break it better."
      },
      "ship-engineer": {
        "label": "Ship Engineer",
        "flavour": "The ship breathes because you tend her engines. Never doubt that."
      },
      "labourer": {
        "label": "Labourer",
        "flavour": "Honest work, hard hours, and a sharp eye for trouble."
      },
      "loader": {
        "label": "Loader",
        "flavour": "Cargo does not move itself. You know exactly how to make it."
      },
      "legionnaire": {
        "label": "Legionnaire",
        "flavour": "The Legion forged you. Iron discipline, oiled rifle, no questions."
      },
      "mercenary": {
        "label": "Mercenary",
        "flavour": "Loyalty is a contract. Yours is always up for renewal."
      },
      "officer": {
        "label": "Officer",
        "flavour": "You were trained to lead. The hard part is choosing who to follow."
      }
    },
    "skill": {
      "dexterity": "Dexterity",
      "force": "Force",
      "infiltration": "Infiltration",
      "manipulation": "Manipulation",
      "meleeCombat": "Melee Combat",
      "observation": "Observation",
      "rangedCombat": "Ranged Combat",
      "survival": "Survival",
      "command": "Command",
      "culture": "Culture",
      "dataDjinn": "Data Djinn",
      "medicurgy": "Medicurgy",
      "mysticPowers": "Mystic Powers",
      "pilot": "Pilot",
      "science": "Science",
      "technology": "Technology"
    }
  },
  "ru": {
    "headline": "Выберите роль",
    "keySkillsLabel": "Ключевые навыки",
    "role": {
      "companion": {
        "label": "Компаньон",
        "flavour": "Муза по найму — твоё ремесло — люди, твоя сцена — везде."
      },
      "musician": {
        "label": "Музыкант",
        "flavour": "Музыка — язык сфер. Ты говоришь на нём свободно."
      },
      "poet": {
        "label": "Поэт",
        "flavour": "Слова режут глубже клинков. Твои оставляют следы на годы."
      },
      "analyst": {
        "label": "Аналитик",
        "flavour": "Данные — новая руда. Ты перерабатываешь их быстрее остальных."
      },
      "correspondent": {
        "label": "Корреспондент",
        "flavour": "Правда — опасный груз. Ты доставляешь его в любом случае."
      },
      "network-djinn": {
        "label": "Сетевой джинн",
        "flavour": "Ты проскальзываешь сквозь файрволы, как дым сквозь иллюминатор."
      },
      "criminal": {
        "label": "Преступник",
        "flavour": "Закон — лишь рекомендация. У тебя всегда были идеи получше."
      },
      "mystic": {
        "label": "Мистик",
        "flavour": "Иконы говорят на частотах, которых другие не слышат. Ты слушаешь."
      },
      "revolutionary": {
        "label": "Революционер",
        "flavour": "Старый порядок горит. Ты несёшь факел и чертёж нового."
      },
      "agitator": {
        "label": "Агитатор",
        "flavour": "Толпа — инструмент. Ты знаешь каждую ноту, которую нужно сыграть."
      },
      "diplomat": {
        "label": "Дипломат",
        "flavour": "Мир — самая дорогая вещь в Третьем горизонте. Ты его торгуешь."
      },
      "dealer": {
        "label": "Делец",
        "flavour": "У каждой сделки две стороны. Ты всегда знаешь, на какой стоишь."
      },
      "assassin": {
        "label": "Ассасин",
        "flavour": "Цель никогда не видит тебя. В этом весь смысл."
      },
      "guard": {
        "label": "Стражник",
        "flavour": "Ты стоишь между угрозой и теми, кто важен. Простая работа."
      },
      "spy": {
        "label": "Шпион",
        "flavour": "У каждого секрета есть цена. Ты знаешь, кто покупает."
      },
      "ace": {
        "label": "Ас",
        "flavour": "Между вражескими пушками и полем обломков ты выбираешь обломки."
      },
      "driver": {
        "label": "Водитель",
        "flavour": "Колёса под тобой, дорога перед глазами. Улицы, пески, скалы — всё твоё."
      },
      "trucker": {
        "label": "Дальнобойщик",
        "flavour": "Дальние рейсы через пустотные трассы. Груз важнее пассажиров."
      },
      "colonist": {
        "label": "Колонист",
        "flavour": "Ты пускаешь корни там, где никто не ступал. Горизонт — твой дом."
      },
      "prospector": {
        "label": "Старатель",
        "flavour": "Руда, реликты, аномалии — если есть ценность, ты найдёшь первым."
      },
      "scout": {
        "label": "Скаут",
        "flavour": "Ты картографируешь края, чтобы другие с них не упали."
      },
      "ascetic": {
        "label": "Аскет",
        "flavour": "Плоть — это шум. Ты научился слышать сквозь него."
      },
      "missionary": {
        "label": "Миссионер",
        "flavour": "Вера путешествует дальше любого корабля. Ты — её быстрейший сосуд."
      },
      "prophet": {
        "label": "Пророк",
        "flavour": "Иконы показали тебе контуры грядущего. Теперь ты предупреждаешь."
      },
      "archaeologist": {
        "label": "Археолог",
        "flavour": "Строители порталов оставили ответы везде. Ты их откапываешь."
      },
      "medicurg": {
        "label": "Медикург",
        "flavour": "Плоть и полевая хирургия: ты держишь их живыми в худшие дни."
      },
      "technologist": {
        "label": "Технологик",
        "flavour": "Если работает на электричестве — ты починишь. Или сломаешь интереснее."
      },
      "ship-engineer": {
        "label": "Бортинженер",
        "flavour": "Корабль дышит, потому что ты следишь за двигателями. Никогда не сомневайся."
      },
      "labourer": {
        "label": "Разнорабочий",
        "flavour": "Честный труд, долгие часы и острый глаз на неприятности."
      },
      "loader": {
        "label": "Грузчик",
        "flavour": "Груз сам себя не движет. Ты точно знаешь, как это сделать."
      },
      "legionnaire": {
        "label": "Легионер",
        "flavour": "Тебя выковал Легион. Железная дисциплина, смазанный карабин, никаких вопросов."
      },
      "mercenary": {
        "label": "Наёмник",
        "flavour": "Лояльность — контракт. Твой всегда открыт для переговоров."
      },
      "officer": {
        "label": "Офицер",
        "flavour": "Тебя учили вести. Трудная часть — выбрать, кому следовать."
      }
    },
    "skill": {
      "dexterity": "Проворство",
      "force": "Сила",
      "infiltration": "Скрытность",
      "manipulation": "Влияние",
      "meleeCombat": "Ближний бой",
      "observation": "Наблюдательность",
      "rangedCombat": "Стрельба",
      "survival": "Выживание",
      "command": "Лидерство",
      "culture": "Мудрость",
      "dataDjinn": "Инфомантия",
      "medicurgy": "Медикургия",
      "mysticPowers": "Психомистицизм",
      "pilot": "Пилотирование",
      "science": "Наука",
      "technology": "Технология"
    }
  }
}
</i18n>

<template>
  <div
    :id="`role-grid-${id}`"
    ref="radioGroupRef"
    class="role-card-grid"
    role="radiogroup"
    :aria-label="t('headline')"
  >
    <button
      v-for="(slug, idx) in roles"
      :key="slug"
      type="button"
      role="radio"
      :aria-checked="role === slug"
      :tabindex="activeIdx === idx ? 0 : -1"
      :class="['role-card-grid__card', { 'role-card-grid__card--selected': role === slug }]"
      @click="pickRole(slug)"
      @keydown.up.prevent="moveFocus(-1)"
      @keydown.down.prevent="moveFocus(+1)"
    >
      <span class="role-card-grid__card-name">{{ t(`role.${slug}.label`) }}</span>
      <span class="role-card-grid__card-flavour">{{ t(`role.${slug}.flavour`) }}</span>
      <ul class="role-card-grid__card-skills" :aria-label="t('keySkillsLabel')">
        <li v-for="key in keySkillsForRole(slug)" :key="key" class="role-card-grid__skill-chip">
          {{ t(`skill.${key}`) }}
        </li>
      </ul>
    </button>
  </div>
</template>

<style lang="scss" scoped>
  $role-card-min-width: 200px;

  .role-card-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax($role-card-min-width, 1fr));
    gap: var(--space-3);

    &__card {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
      padding: var(--space-4);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      cursor: pointer;
      text-align: left;
      transition:
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        border-color: var(--brand-brass);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &--selected {
        border-color: var(--brand-brass);
        background-color: var(--brand-brass-deep);
      }
    }

    &__card-name {
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      font-weight: 700;
      color: var(--brand-brass-light);
    }

    &__card-flavour {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      line-height: 1.45;
      flex: 1;
    }

    &__card-skills {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-1);
      list-style: none;
      margin: var(--space-1) 0 0;
      padding: 0;
    }

    &__skill-chip {
      padding: var(--space-1) var(--space-2);
      background-color: color-mix(in srgb, var(--brand-brass-shadow) 40%, transparent);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-pill);
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      font-weight: 500;
      color: var(--brand-brass);

      .role-card-grid__card--selected & {
        background-color: color-mix(in srgb, var(--brand-brass) 20%, transparent);
        border-color: var(--brand-brass);
        color: var(--brand-brass-light);
      }
    }
  }
</style>
