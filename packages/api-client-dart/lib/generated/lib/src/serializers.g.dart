// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add($Encounter.serializer)
      ..add($GameSession.serializer)
      ..add($ItemBase.serializer)
      ..add($ShipModuleBase.serializer)
      ..add(AssignCharacterToSession.serializer)
      ..add(AssignCrewRequest.serializer)
      ..add(Attributes.serializer)
      ..add(Character.serializer)
      ..add(CharacterCreate.serializer)
      ..add(CharacterCreateHp.serializer)
      ..add(CharacterCreateStatusEnum.serializer)
      ..add(CharacterEncumbrance.serializer)
      ..add(CharacterHp.serializer)
      ..add(CharacterList.serializer)
      ..add(CharacterMp.serializer)
      ..add(CharacterStatusEnum.serializer)
      ..add(CharacterUpdate.serializer)
      ..add(CharacterUpdateStatusEnum.serializer)
      ..add(Combatant.serializer)
      ..add(CombatantCreate.serializer)
      ..add(CombatantList.serializer)
      ..add(CombatantType.serializer)
      ..add(CombatantUpdate.serializer)
      ..add(Concept.serializer)
      ..add(ConditionFlags.serializer)
      ..add(CrewConcept.serializer)
      ..add(CrewPosition.serializer)
      ..add(CrewSlot.serializer)
      ..add(CriticalInjury.serializer)
      ..add(CriticalInjurySeverity.serializer)
      ..add(DependencyStatus.serializer)
      ..add(DpAdjustment.serializer)
      ..add(DpEvent.serializer)
      ..add(DpEventList.serializer)
      ..add(DpSource.serializer)
      ..add(EncounterCreate.serializer)
      ..add(EncounterList.serializer)
      ..add(EncounterStatus.serializer)
      ..add(EncounterUpdate.serializer)
      ..add(GameSessionCreate.serializer)
      ..add(GameSessionList.serializer)
      ..add(GameSessionStatus.serializer)
      ..add(GameSessionUpdate.serializer)
      ..add(HealthStatus.serializer)
      ..add(HealthStatusDependencies.serializer)
      ..add(IconId.serializer)
      ..add(InitiativeReorderRequest.serializer)
      ..add(InitiativeRollResult.serializer)
      ..add(Item.serializer)
      ..add(ItemArmor.serializer)
      ..add(ItemArmorCreate.serializer)
      ..add(ItemArmorCreateTypeEnum.serializer)
      ..add(ItemArmorUpdate.serializer)
      ..add(ItemArmorUpdateTypeEnum.serializer)
      ..add(ItemCreate.serializer)
      ..add(ItemCybernetic.serializer)
      ..add(ItemCyberneticCreate.serializer)
      ..add(ItemCyberneticCreateTypeEnum.serializer)
      ..add(ItemCyberneticUpdate.serializer)
      ..add(ItemCyberneticUpdateTypeEnum.serializer)
      ..add(ItemGear.serializer)
      ..add(ItemGearCreate.serializer)
      ..add(ItemGearCreateTypeEnum.serializer)
      ..add(ItemGearUpdate.serializer)
      ..add(ItemGearUpdateTypeEnum.serializer)
      ..add(ItemOther.serializer)
      ..add(ItemOtherCreate.serializer)
      ..add(ItemOtherCreateTypeEnum.serializer)
      ..add(ItemOtherUpdate.serializer)
      ..add(ItemOtherUpdateTypeEnum.serializer)
      ..add(ItemRangeEnum.serializer)
      ..add(ItemShipModule.serializer)
      ..add(ItemShipModuleCreate.serializer)
      ..add(ItemShipModuleCreateTypeEnum.serializer)
      ..add(ItemShipModuleUpdate.serializer)
      ..add(ItemShipModuleUpdateTypeEnum.serializer)
      ..add(ItemUpdate.serializer)
      ..add(ItemWeapon.serializer)
      ..add(ItemWeaponCreate.serializer)
      ..add(ItemWeaponCreateTypeEnum.serializer)
      ..add(ItemWeaponUpdate.serializer)
      ..add(ItemWeaponUpdateTypeEnum.serializer)
      ..add(Me.serializer)
      ..add(MeExportBundle.serializer)
      ..add(MeExportBundleDollarSchemaVersionEnum.serializer)
      ..add(MeExportEncounter.serializer)
      ..add(MeExportGameSession.serializer)
      ..add(MeExportUser.serializer)
      ..add(MeThemeEnum.serializer)
      ..add(MeUpdate.serializer)
      ..add(MeUpdateThemeEnum.serializer)
      ..add(MutantLineage.serializer)
      ..add(Npc.serializer)
      ..add(NpcCreate.serializer)
      ..add(NpcCreateHp.serializer)
      ..add(NpcCreateMp.serializer)
      ..add(NpcHp.serializer)
      ..add(NpcList.serializer)
      ..add(NpcMp.serializer)
      ..add(NpcUpdate.serializer)
      ..add(NpcUpdateHp.serializer)
      ..add(Problem.serializer)
      ..add(RealtimeToken.serializer)
      ..add(Relationship.serializer)
      ..add(RelationshipKind.serializer)
      ..add(Role.serializer)
      ..add(Roll.serializer)
      ..add(RollBreakdown.serializer)
      ..add(RollCreate.serializer)
      ..add(RollKind.serializer)
      ..add(RollList.serializer)
      ..add(ShareLink.serializer)
      ..add(ShareLinkCreate.serializer)
      ..add(ShareLinkList.serializer)
      ..add(Ship.serializer)
      ..add(ShipClass.serializer)
      ..add(ShipCreate.serializer)
      ..add(ShipCreateEnergy.serializer)
      ..add(ShipCreateHull.serializer)
      ..add(ShipEnergy.serializer)
      ..add(ShipHull.serializer)
      ..add(ShipList.serializer)
      ..add(ShipModule.serializer)
      ..add(ShipModuleCreate.serializer)
      ..add(ShipModuleHold.serializer)
      ..add(ShipModuleHoldCreate.serializer)
      ..add(ShipModuleHoldCreateSlotEnum.serializer)
      ..add(ShipModuleHoldUpdate.serializer)
      ..add(ShipModuleHoldUpdateSlotEnum.serializer)
      ..add(ShipModuleOther.serializer)
      ..add(ShipModuleOtherCreate.serializer)
      ..add(ShipModuleOtherUpdate.serializer)
      ..add(ShipModuleSensor.serializer)
      ..add(ShipModuleSensorCreate.serializer)
      ..add(ShipModuleSensorCreateSlotEnum.serializer)
      ..add(ShipModuleSensorUpdate.serializer)
      ..add(ShipModuleSensorUpdateSlotEnum.serializer)
      ..add(ShipModuleSlot.serializer)
      ..add(ShipModuleTorpedo.serializer)
      ..add(ShipModuleTorpedoCreate.serializer)
      ..add(ShipModuleTorpedoCreateSlotEnum.serializer)
      ..add(ShipModuleTorpedoUpdate.serializer)
      ..add(ShipModuleTorpedoUpdateSlotEnum.serializer)
      ..add(ShipModuleUpdate.serializer)
      ..add(ShipModuleWeapon.serializer)
      ..add(ShipModuleWeaponCreate.serializer)
      ..add(ShipModuleWeaponCreateSlotEnum.serializer)
      ..add(ShipModuleWeaponUpdate.serializer)
      ..add(ShipModuleWeaponUpdateSlotEnum.serializer)
      ..add(ShipUpdate.serializer)
      ..add(ShipUpdateHull.serializer)
      ..add(ShipWeaponRange.serializer)
      ..add(Skills.serializer)
      ..add(Talent.serializer)
      ..add(TalentCreate.serializer)
      ..add(TalentKind.serializer)
      ..add(TalentUpdate.serializer)
      ..add(TurnAdvanceResult.serializer)
      ..add(Upbringing.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Character)]),
          () => ListBuilder<Character>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Character)]),
          () => ListBuilder<Character>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Ship)]),
          () => ListBuilder<Ship>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Npc)]),
          () => ListBuilder<Npc>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(MeExportGameSession)]),
          () => ListBuilder<MeExportGameSession>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Combatant)]),
          () => ListBuilder<Combatant>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Combatant)]),
          () => ListBuilder<Combatant>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Combatant)]),
          () => ListBuilder<Combatant>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CriticalInjury)]),
          () => ListBuilder<CriticalInjury>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CriticalInjury)]),
          () => ListBuilder<CriticalInjury>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Talent)]),
          () => ListBuilder<Talent>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Relationship)]),
          () => ListBuilder<Relationship>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Item)]),
          () => ListBuilder<Item>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(DpEvent)]),
          () => ListBuilder<DpEvent>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Encounter)]),
          () => ListBuilder<Encounter>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GameSession)]),
          () => ListBuilder<GameSession>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ItemArmor)]),
          () => ListBuilder<ItemArmor>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ItemWeapon)]),
          () => ListBuilder<ItemWeapon>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ItemArmor)]),
          () => ListBuilder<ItemArmor>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ItemWeapon)]),
          () => ListBuilder<ItemWeapon>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ItemArmor)]),
          () => ListBuilder<ItemArmor>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ItemWeapon)]),
          () => ListBuilder<ItemWeapon>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MeExportEncounter)]),
          () => ListBuilder<MeExportEncounter>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Npc)]),
          () => ListBuilder<Npc>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Roll)]),
          () => ListBuilder<Roll>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ShareLink)]),
          () => ListBuilder<ShareLink>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Ship)]),
          () => ListBuilder<Ship>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ShipModule)]),
          () => ListBuilder<ShipModule>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CrewSlot)]),
          () => ListBuilder<CrewSlot>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
