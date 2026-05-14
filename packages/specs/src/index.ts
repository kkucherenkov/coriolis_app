export type { paths, components } from './openapi-types.js';
export {
  CREW_TALENTS,
  ICON_GIFTS,
  PERSONAL_TALENTS,
  RECOMMENDED_PERSONAL_TALENTS_BY_CONCEPT,
  STIGMA_TALENTS,
  TALENT_CATALOG,
  findCatalogTalentById,
  findCatalogTalentByName,
  getCrewTalentsByConcept,
  getIconGiftByIconId,
  getRecommendedPersonalTalents,
  pickLocalized,
} from './talents.js';
export type {
  CatalogLocale,
  CatalogTalent,
  CatalogTalentBase,
  CrewTalentCatalogEntry,
  IconGiftCatalogEntry,
  LocalizedString,
  PersonalTalentCatalogEntry,
  StigmaTalentCatalogEntry,
} from './talents.js';
export { STARTER_KIT_CATALOG, findStarterKit, pickStarterKitItemName } from './starter-kits.js';
export type {
  StarterKit,
  StarterKitChoice,
  StarterKitItem,
  StarterKitItemKind,
  StarterKitItemTemplate,
} from './starter-kits.js';
