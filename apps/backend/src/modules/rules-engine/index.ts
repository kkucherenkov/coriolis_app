/**
 * Barrel export for the rules-engine module.
 * Import from here rather than from the internal file.
 */
export {
  computeHpMax,
  computeMpMax,
  computeEncumbranceMax,
  computeEncumbranceCurrent,
  sumArmorExtraSlots,
  canPush,
  applyConditions,
  UPBRINGING_BUDGETS,
  CONCEPT_KEYS,
  CONCEPT_ROLES,
  ROLE_BY_CONCEPT,
  CONCEPT_BY_ROLE,
  getRoleKeySkills,
  defaultRoleForConcept,
  sumAttributes,
  sumSkills,
} from './rules-engine';
export type {
  AttributeKey,
  CanPushResult,
  ConditionFlags,
  Concept,
  ConceptKeys,
  CrewConcept,
  Role,
  RoleData,
  SkillKey,
  TalentKind,
  Upbringing,
  UpbringingBudget,
} from './rules-engine';
export {
  BASE_STATS_BY_CLASS,
  BASE_STATS_BY_TIER,
  TIER_BY_SHIP_TYPE,
  getBaseStatsByShipType,
  getTierForShipType,
} from './ship-class-table';
export type { ShipBaseStats, ShipTier } from './ship-class-table';
