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
  },
  "uk": {
    "headline": "[uk-todo] Choose your role",
    "keySkillsLabel": "[uk-todo] Key skills",
    "role": {
      "companion": { "label": "[uk-todo] Companion", "flavour": "[uk-todo] A muse for hire." },
      "musician": { "label": "[uk-todo] Musician", "flavour": "[uk-todo] Music of the spheres." },
      "poet": { "label": "[uk-todo] Poet", "flavour": "[uk-todo] Words cut deeper than blades." },
      "analyst": { "label": "[uk-todo] Analyst", "flavour": "[uk-todo] Data is the new ore." },
      "correspondent": {
        "label": "[uk-todo] Correspondent",
        "flavour": "[uk-todo] Truth is dangerous cargo."
      },
      "network-djinn": {
        "label": "[uk-todo] Network Djinn",
        "flavour": "[uk-todo] You slip through firewalls."
      },
      "criminal": {
        "label": "[uk-todo] Criminal",
        "flavour": "[uk-todo] The law is a suggestion."
      },
      "mystic": { "label": "[uk-todo] Mystic", "flavour": "[uk-todo] The Icons speak." },
      "revolutionary": {
        "label": "[uk-todo] Revolutionary",
        "flavour": "[uk-todo] The old order burns."
      },
      "agitator": {
        "label": "[uk-todo] Agitator",
        "flavour": "[uk-todo] A crowd is an instrument."
      },
      "diplomat": { "label": "[uk-todo] Diplomat", "flavour": "[uk-todo] Peace is expensive." },
      "dealer": { "label": "[uk-todo] Dealer", "flavour": "[uk-todo] Every deal has two sides." },
      "assassin": {
        "label": "[uk-todo] Assassin",
        "flavour": "[uk-todo] Your target never sees you."
      },
      "guard": {
        "label": "[uk-todo] Guard",
        "flavour": "[uk-todo] You stand between harm and others."
      },
      "spy": { "label": "[uk-todo] Spy", "flavour": "[uk-todo] Every secret has a price." },
      "ace": { "label": "[uk-todo] Ace", "flavour": "[uk-todo] Between cannons and debris." },
      "driver": { "label": "[uk-todo] Driver", "flavour": "[uk-todo] Wheels under you." },
      "trucker": {
        "label": "[uk-todo] Trucker",
        "flavour": "[uk-todo] Long hauls through void lanes."
      },
      "colonist": { "label": "[uk-todo] Colonist", "flavour": "[uk-todo] You plant roots." },
      "prospector": {
        "label": "[uk-todo] Prospector",
        "flavour": "[uk-todo] Ore, relics, anomalies."
      },
      "scout": { "label": "[uk-todo] Scout", "flavour": "[uk-todo] You map the edges." },
      "ascetic": { "label": "[uk-todo] Ascetic", "flavour": "[uk-todo] Flesh is noise." },
      "missionary": { "label": "[uk-todo] Missionary", "flavour": "[uk-todo] Faith travels far." },
      "prophet": { "label": "[uk-todo] Prophet", "flavour": "[uk-todo] The Icons showed you." },
      "archaeologist": {
        "label": "[uk-todo] Archaeologist",
        "flavour": "[uk-todo] The Portal Builders left answers."
      },
      "medicurg": {
        "label": "[uk-todo] Medicurg",
        "flavour": "[uk-todo] Flesh and field-surgery."
      },
      "technologist": {
        "label": "[uk-todo] Technologist",
        "flavour": "[uk-todo] If it runs on power."
      },
      "ship-engineer": {
        "label": "[uk-todo] Ship Engineer",
        "flavour": "[uk-todo] The ship breathes."
      },
      "labourer": {
        "label": "[uk-todo] Labourer",
        "flavour": "[uk-todo] Honest work, hard hours."
      },
      "loader": { "label": "[uk-todo] Loader", "flavour": "[uk-todo] Cargo does not move itself." },
      "legionnaire": {
        "label": "[uk-todo] Legionnaire",
        "flavour": "[uk-todo] The Legion forged you."
      },
      "mercenary": {
        "label": "[uk-todo] Mercenary",
        "flavour": "[uk-todo] Loyalty is a contract."
      },
      "officer": { "label": "[uk-todo] Officer", "flavour": "[uk-todo] You were trained to lead." }
    },
    "skill": {
      "dexterity": "[uk-todo] Dexterity",
      "force": "[uk-todo] Force",
      "infiltration": "[uk-todo] Infiltration",
      "manipulation": "[uk-todo] Manipulation",
      "meleeCombat": "[uk-todo] Melee Combat",
      "observation": "[uk-todo] Observation",
      "rangedCombat": "[uk-todo] Ranged Combat",
      "survival": "[uk-todo] Survival",
      "command": "[uk-todo] Command",
      "culture": "[uk-todo] Culture",
      "dataDjinn": "[uk-todo] Data Djinn",
      "medicurgy": "[uk-todo] Medicurgy",
      "mysticPowers": "[uk-todo] Mystic Powers",
      "pilot": "[uk-todo] Pilot",
      "science": "[uk-todo] Science",
      "technology": "[uk-todo] Technology"
    }
  },
  "el": {
    "headline": "[el-todo] Choose your role",
    "keySkillsLabel": "[el-todo] Key skills",
    "role": {
      "companion": { "label": "[el-todo] Companion", "flavour": "[el-todo] A muse for hire." },
      "musician": { "label": "[el-todo] Musician", "flavour": "[el-todo] Music of the spheres." },
      "poet": { "label": "[el-todo] Poet", "flavour": "[el-todo] Words cut deeper than blades." },
      "analyst": { "label": "[el-todo] Analyst", "flavour": "[el-todo] Data is the new ore." },
      "correspondent": {
        "label": "[el-todo] Correspondent",
        "flavour": "[el-todo] Truth is dangerous cargo."
      },
      "network-djinn": {
        "label": "[el-todo] Network Djinn",
        "flavour": "[el-todo] You slip through firewalls."
      },
      "criminal": {
        "label": "[el-todo] Criminal",
        "flavour": "[el-todo] The law is a suggestion."
      },
      "mystic": { "label": "[el-todo] Mystic", "flavour": "[el-todo] The Icons speak." },
      "revolutionary": {
        "label": "[el-todo] Revolutionary",
        "flavour": "[el-todo] The old order burns."
      },
      "agitator": {
        "label": "[el-todo] Agitator",
        "flavour": "[el-todo] A crowd is an instrument."
      },
      "diplomat": { "label": "[el-todo] Diplomat", "flavour": "[el-todo] Peace is expensive." },
      "dealer": { "label": "[el-todo] Dealer", "flavour": "[el-todo] Every deal has two sides." },
      "assassin": {
        "label": "[el-todo] Assassin",
        "flavour": "[el-todo] Your target never sees you."
      },
      "guard": {
        "label": "[el-todo] Guard",
        "flavour": "[el-todo] You stand between harm and others."
      },
      "spy": { "label": "[el-todo] Spy", "flavour": "[el-todo] Every secret has a price." },
      "ace": { "label": "[el-todo] Ace", "flavour": "[el-todo] Between cannons and debris." },
      "driver": { "label": "[el-todo] Driver", "flavour": "[el-todo] Wheels under you." },
      "trucker": {
        "label": "[el-todo] Trucker",
        "flavour": "[el-todo] Long hauls through void lanes."
      },
      "colonist": { "label": "[el-todo] Colonist", "flavour": "[el-todo] You plant roots." },
      "prospector": {
        "label": "[el-todo] Prospector",
        "flavour": "[el-todo] Ore, relics, anomalies."
      },
      "scout": { "label": "[el-todo] Scout", "flavour": "[el-todo] You map the edges." },
      "ascetic": { "label": "[el-todo] Ascetic", "flavour": "[el-todo] Flesh is noise." },
      "missionary": { "label": "[el-todo] Missionary", "flavour": "[el-todo] Faith travels far." },
      "prophet": { "label": "[el-todo] Prophet", "flavour": "[el-todo] The Icons showed you." },
      "archaeologist": {
        "label": "[el-todo] Archaeologist",
        "flavour": "[el-todo] The Portal Builders left answers."
      },
      "medicurg": {
        "label": "[el-todo] Medicurg",
        "flavour": "[el-todo] Flesh and field-surgery."
      },
      "technologist": {
        "label": "[el-todo] Technologist",
        "flavour": "[el-todo] If it runs on power."
      },
      "ship-engineer": {
        "label": "[el-todo] Ship Engineer",
        "flavour": "[el-todo] The ship breathes."
      },
      "labourer": {
        "label": "[el-todo] Labourer",
        "flavour": "[el-todo] Honest work, hard hours."
      },
      "loader": { "label": "[el-todo] Loader", "flavour": "[el-todo] Cargo does not move itself." },
      "legionnaire": {
        "label": "[el-todo] Legionnaire",
        "flavour": "[el-todo] The Legion forged you."
      },
      "mercenary": {
        "label": "[el-todo] Mercenary",
        "flavour": "[el-todo] Loyalty is a contract."
      },
      "officer": { "label": "[el-todo] Officer", "flavour": "[el-todo] You were trained to lead." }
    },
    "skill": {
      "dexterity": "[el-todo] Dexterity",
      "force": "[el-todo] Force",
      "infiltration": "[el-todo] Infiltration",
      "manipulation": "[el-todo] Manipulation",
      "meleeCombat": "[el-todo] Melee Combat",
      "observation": "[el-todo] Observation",
      "rangedCombat": "[el-todo] Ranged Combat",
      "survival": "[el-todo] Survival",
      "command": "[el-todo] Command",
      "culture": "[el-todo] Culture",
      "dataDjinn": "[el-todo] Data Djinn",
      "medicurgy": "[el-todo] Medicurgy",
      "mysticPowers": "[el-todo] Mystic Powers",
      "pilot": "[el-todo] Pilot",
      "science": "[el-todo] Science",
      "technology": "[el-todo] Technology"
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
