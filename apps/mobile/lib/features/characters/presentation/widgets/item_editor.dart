import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/features/characters/domain/character.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:app_mobile/i18n/strings.g.dart';

/// Inventory list for the Gear tab.
class GearTabContent extends StatelessWidget {
  const GearTabContent({super.key, required this.inventory});

  final List<DomainItem> inventory;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final cubit = context.read<CharacterSheetCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (inventory.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
            child: Text(
              t.itemEmpty,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...inventory.map((item) => _ItemRow(
                item: item,
                onEdit: () => _openEditor(context, cubit, item: item),
                onToggleEquipped: () {
                  final toggled = item.copyWith(equipped: !(item.equipped ?? false));
                  cubit.updateItem(item.id, toggled);
                },
              )),
        const SizedBox(height: AppSpacing.s3),
        AppButton(
          label: '+ ${t.itemAddTitle}',
          variant: AppButtonVariant.ghost,
          onPressed: () => _openEditor(context, cubit),
        ),
      ],
    );
  }

  void _openEditor(
    BuildContext context,
    CharacterSheetCubit cubit, {
    DomainItem? item,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceNight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _ItemEditorSheet(item: item),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.onEdit,
    required this.onToggleEquipped,
  });

  final DomainItem item;
  final VoidCallback onEdit;
  final VoidCallback onToggleEquipped;

  String _typeLabel(BuildContext context) {
    final t = context.t.characters;
    return switch (item.type) {
      ItemType.weapon => t.itemTypeWeapon,
      ItemType.armor => t.itemTypeArmor,
      ItemType.gear => t.itemTypeGear,
      ItemType.cybernetic => t.itemTypeCybernetic,
      ItemType.shipModule => t.itemTypeShipModule,
      ItemType.other => t.itemTypeOther,
    };
  }

  @override
  Widget build(BuildContext context) {
    final hasEquipped = item.equipped != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s2),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.s3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: AppFontWeight.semibold,
                          ),
                        ),
                      ),
                      AppBadge(
                        label: _typeLabel(context),
                        tone: AppBadgeTone.brass,
                        size: AppBadgeSize.sm,
                      ),
                    ],
                  ),
                  if (item.weight != null || item.quantity != null) ...[
                    const SizedBox(height: AppSpacing.s1),
                    Row(
                      children: [
                        if (item.weight != null)
                          Text(
                            'W: ${item.weight}',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        if (item.weight != null && item.quantity != null)
                          const SizedBox(width: AppSpacing.s3),
                        if (item.quantity != null)
                          Text(
                            'x${item.quantity}',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasEquipped)
              Semantics(
                button: true,
                label: item.equipped == true ? 'Unequip' : 'Equip',
                child: GestureDetector(
                  onTap: onToggleEquipped,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Icon(
                        item.equipped == true
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: item.equipped == true
                            ? AppColors.stateSuccess
                            : AppColors.brandBrassDeep,
                        size: AppSpacing.s5,
                      ),
                    ),
                  ),
                ),
              ),
            Semantics(
              button: true,
              label: 'Edit ${item.name}',
              child: GestureDetector(
                onTap: onEdit,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Icon(
                      Icons.edit_outlined,
                      color: AppColors.brandBrassDeep,
                      size: AppSpacing.s4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet form for adding or editing an item with type-discriminated fields.
class _ItemEditorSheet extends StatefulWidget {
  const _ItemEditorSheet({this.item});
  final DomainItem? item;

  @override
  State<_ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<_ItemEditorSheet> {
  late ItemType _type;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _effectCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _damageCtrl;
  late final TextEditingController _bonusCtrl;
  late final TextEditingController _critCtrl;
  late final TextEditingController _armorRatingCtrl;
  late final TextEditingController _bodyPointsCtrl;
  late bool _equipped;
  late String _range;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _type = item?.type ?? ItemType.gear;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _notesCtrl = TextEditingController(text: item?.notes ?? '');
    _effectCtrl = TextEditingController(text: item?.effect ?? '');
    _weightCtrl = TextEditingController(text: item?.weight?.toString() ?? '1');
    _quantityCtrl =
        TextEditingController(text: item?.quantity?.toString() ?? '1');
    _damageCtrl = TextEditingController(text: item?.damage?.toString() ?? '1');
    _bonusCtrl = TextEditingController(text: item?.bonus?.toString() ?? '0');
    _critCtrl = TextEditingController(text: item?.crit?.toString() ?? '1');
    _armorRatingCtrl =
        TextEditingController(text: item?.armorRating?.toString() ?? '0');
    _bodyPointsCtrl =
        TextEditingController(text: item?.bodyPoints?.toString() ?? '0');
    _equipped = item?.equipped ?? false;
    _range = item?.range ?? 'arm';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _effectCtrl.dispose();
    _weightCtrl.dispose();
    _quantityCtrl.dispose();
    _damageCtrl.dispose();
    _bonusCtrl.dispose();
    _critCtrl.dispose();
    _armorRatingCtrl.dispose();
    _bodyPointsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final cubit = context.read<CharacterSheetCubit>();
    final types = [
      ItemType.weapon,
      ItemType.armor,
      ItemType.gear,
      ItemType.cybernetic,
      ItemType.shipModule,
      ItemType.other,
    ];
    final typeLabels = [
      t.itemTypeWeapon,
      t.itemTypeArmor,
      t.itemTypeGear,
      t.itemTypeCybernetic,
      t.itemTypeShipModule,
      t.itemTypeOther,
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s4,
        right: AppSpacing.s4,
        top: AppSpacing.s4,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s4,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppSpacing.s11,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.brandBrassDeep,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              _isEdit ? t.itemEditTitle : t.itemAddTitle,
              style:
                  AppTypography.displaySm.copyWith(color: AppColors.brandBrass),
            ),
            const SizedBox(height: AppSpacing.s3),
            // Type selector — split into 2 rows of 3 for mobile
            AppField(
              label: t.itemTypeLabel,
              child: Column(
                children: [
                  Row(
                    children: List.generate(3, (i) {
                      final itemType = types[i];
                      final selected = _type == itemType;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = itemType),
                          child: Container(
                            height: 44,
                            margin: EdgeInsets.only(right: i < 2 ? AppSpacing.s1 : 0),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.brandBrass
                                  : Colors.transparent,
                              border: Border.all(color: AppColors.brandBrassDeep),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Center(
                              child: Text(
                                typeLabels[i],
                                style: AppTypography.bodySm.copyWith(
                                  color: selected
                                      ? AppColors.textOnBrass
                                      : AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Row(
                    children: List.generate(3, (i) {
                      final itemType = types[i + 3];
                      final selected = _type == itemType;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = itemType),
                          child: Container(
                            height: 44,
                            margin: EdgeInsets.only(right: i < 2 ? AppSpacing.s1 : 0),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.brandBrass
                                  : Colors.transparent,
                              border: Border.all(color: AppColors.brandBrassDeep),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Center(
                              child: Text(
                                typeLabels[i + 3],
                                style: AppTypography.bodySm.copyWith(
                                  color: selected
                                      ? AppColors.textOnBrass
                                      : AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            // Common: Name
            AppField(
              label: t.itemNameLabel,
              child: AppInput(controller: _nameCtrl, hintText: t.itemNameHint),
            ),
            const SizedBox(height: AppSpacing.s3),
            // Type-specific fields
            ..._buildTypeFields(t),
            const SizedBox(height: AppSpacing.s4),
            AppButton(
              label: t.itemSave,
              onPressed: () => _save(context, cubit),
            ),
            if (_isEdit) ...[
              const SizedBox(height: AppSpacing.s2),
              AppButton(
                label: t.itemDelete,
                variant: AppButtonVariant.danger,
                onPressed: () => _delete(context, cubit),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTypeFields(TranslationsCharactersEn t) {
    switch (_type) {
      case ItemType.weapon:
        return [
          Row(
            children: [
              Expanded(
                child: AppField(
                  label: t.itemDamageLabel,
                  child: AppInput(
                    controller: _damageCtrl,
                    inputType: AppInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: AppField(
                  label: t.itemBonusLabel,
                  child: AppInput(
                    controller: _bonusCtrl,
                    inputType: AppInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: AppField(
                  label: t.itemCritLabel,
                  child: AppInput(
                    controller: _critCtrl,
                    inputType: AppInputType.number,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          AppField(
            label: t.itemRangeLabel,
            child: _RangeSelector(
              value: _range,
              onChanged: (v) => setState(() => _range = v),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              Expanded(
                child: AppField(
                  label: t.itemWeightLabel,
                  child: AppInput(
                    controller: _weightCtrl,
                    inputType: AppInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: AppField(
                  label: t.itemEquippedLabel,
                  child: AppSwitch(
                    value: _equipped,
                    onChanged: (v) => setState(() => _equipped = v),
                  ),
                ),
              ),
            ],
          ),
        ];
      case ItemType.armor:
        return [
          Row(
            children: [
              Expanded(
                child: AppField(
                  label: t.itemArmorRatingLabel,
                  child: AppInput(
                    controller: _armorRatingCtrl,
                    inputType: AppInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: AppField(
                  label: t.itemWeightLabel,
                  child: AppInput(
                    controller: _weightCtrl,
                    inputType: AppInputType.number,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          AppField(
            label: t.itemEquippedLabel,
            child: AppSwitch(
              value: _equipped,
              onChanged: (v) => setState(() => _equipped = v),
            ),
          ),
        ];
      case ItemType.gear:
        return [
          Row(
            children: [
              Expanded(
                child: AppField(
                  label: t.itemWeightLabel,
                  child: AppInput(
                    controller: _weightCtrl,
                    inputType: AppInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: AppField(
                  label: t.itemQuantityLabel,
                  child: AppInput(
                    controller: _quantityCtrl,
                    inputType: AppInputType.number,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          AppField(
            label: t.itemNotesLabel,
            child: AppTextarea(
              controller: _notesCtrl,
              rows: 2,
            ),
          ),
        ];
      case ItemType.cybernetic:
        return [
          AppField(
            label: t.itemBodyPointsLabel,
            child: AppInput(
              controller: _bodyPointsCtrl,
              inputType: AppInputType.number,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          AppField(
            label: t.itemEffectLabel,
            child: AppTextarea(
              controller: _effectCtrl,
              rows: 2,
            ),
          ),
        ];
      case ItemType.shipModule:
        return [
          AppField(
            label: t.itemEffectLabel,
            child: AppTextarea(
              controller: _effectCtrl,
              rows: 3,
            ),
          ),
        ];
      case ItemType.other:
        return [
          Row(
            children: [
              Expanded(
                child: AppField(
                  label: t.itemWeightLabel,
                  child: AppInput(
                    controller: _weightCtrl,
                    inputType: AppInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: AppField(
                  label: t.itemQuantityLabel,
                  child: AppInput(
                    controller: _quantityCtrl,
                    inputType: AppInputType.number,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          AppField(
            label: t.itemNotesLabel,
            child: AppTextarea(
              controller: _notesCtrl,
              rows: 2,
            ),
          ),
        ];
    }
  }

  DomainItem _buildDraft() {
    return DomainItem(
      id: widget.item?.id ?? '',
      type: _type,
      name: _nameCtrl.text.trim(),
      weight: double.tryParse(_weightCtrl.text),
      equipped: _equipped,
      damage: int.tryParse(_damageCtrl.text),
      range: _range,
      bonus: int.tryParse(_bonusCtrl.text),
      crit: int.tryParse(_critCtrl.text),
      armorRating: int.tryParse(_armorRatingCtrl.text),
      quantity: int.tryParse(_quantityCtrl.text),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      bodyPoints: int.tryParse(_bodyPointsCtrl.text),
      effect: _effectCtrl.text.trim().isEmpty ? null : _effectCtrl.text.trim(),
    );
  }

  Future<void> _save(BuildContext context, CharacterSheetCubit cubit) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final draft = _buildDraft();
    if (_isEdit) {
      await cubit.updateItem(widget.item!.id, draft);
    } else {
      await cubit.addItem(draft);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _delete(BuildContext context, CharacterSheetCubit cubit) async {
    await cubit.removeItem(widget.item!.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}

/// Weapon range selector using compact labeled buttons.
class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _ranges = ['arm', 'near', 'short', 'long', 'distant'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _ranges.map((r) {
        final selected = r == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(r),
            child: Container(
              height: 44,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: selected ? AppColors.brandBrass : Colors.transparent,
                border: Border.all(color: AppColors.brandBrassDeep),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(
                  r[0].toUpperCase(),
                  style: AppTypography.bodySm.copyWith(
                    color: selected
                        ? AppColors.textOnBrass
                        : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
