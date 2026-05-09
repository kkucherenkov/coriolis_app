// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (new Serializers().toBuilder()
      ..add($ItemBase.serializer)
      ..add($ShipModuleBase.serializer)
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
      ..add(ConditionFlags.serializer)
      ..add(CrewPosition.serializer)
      ..add(CrewSlot.serializer)
      ..add(CriticalInjury.serializer)
      ..add(CriticalInjurySeverity.serializer)
      ..add(DependencyStatus.serializer)
      ..add(HealthStatus.serializer)
      ..add(HealthStatusDependencies.serializer)
      ..add(IconId.serializer)
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
      ..add(ItemSlotType.serializer)
      ..add(ItemUpdate.serializer)
      ..add(ItemWeapon.serializer)
      ..add(ItemWeaponCreate.serializer)
      ..add(ItemWeaponCreateTypeEnum.serializer)
      ..add(ItemWeaponUpdate.serializer)
      ..add(ItemWeaponUpdateTypeEnum.serializer)
      ..add(Me.serializer)
      ..add(MeThemeEnum.serializer)
      ..add(MeUpdate.serializer)
      ..add(MeUpdateThemeEnum.serializer)
      ..add(Problem.serializer)
      ..add(RealtimeToken.serializer)
      ..add(Relationship.serializer)
      ..add(RelationshipKind.serializer)
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
      ..add(TalentUpdate.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Character)]),
          () => new ListBuilder<Character>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CriticalInjury)]),
          () => new ListBuilder<CriticalInjury>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CriticalInjury)]),
          () => new ListBuilder<CriticalInjury>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Talent)]),
          () => new ListBuilder<Talent>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Relationship)]),
          () => new ListBuilder<Relationship>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Item)]),
          () => new ListBuilder<Item>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ShareLink)]),
          () => new ListBuilder<ShareLink>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Ship)]),
          () => new ListBuilder<Ship>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ShipModule)]),
          () => new ListBuilder<ShipModule>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CrewSlot)]),
          () => new ListBuilder<CrewSlot>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
