import 'package:flutter/material.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/app/routes.dart';
import 'package:app_mobile/features/characters/domain/character_repository.dart';
import 'package:app_mobile/i18n/strings.g.dart';
import 'package:app_mobile/shared/di/injector.dart';

/// Character creation page.
///
/// Minimal form: just a name field. On submit, calls [CharacterRepository.create]
/// and navigates to the new character's sheet page.
class CharacterCreatePage extends StatefulWidget {
  const CharacterCreatePage({super.key});

  @override
  State<CharacterCreatePage> createState() => _CharacterCreatePageState();
}

class _CharacterCreatePageState extends State<CharacterCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = getIt<CharacterRepository>();
      final character = await repository.create(name: _nameController.text.trim());
      if (!mounted) return;
      // Replace the create page with the sheet detail so "back" goes to list.
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.characterDetail,
        arguments: character.id,
      );
    } on Object catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return Scaffold(
      backgroundColor: AppColors.surfaceVoid,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceNight,
        title: Text(
          t.newTitle,
          style: AppTypography.displaySm.copyWith(color: AppColors.brandBrass),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppField(
                  label: t.nameLabel,
                  child: TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.brandBrass,
                    ),
                    decoration: InputDecoration(
                      hintText: t.nameHint,
                      hintStyle: AppTypography.bodyMd.copyWith(
                        color: AppColors.textSecondary
                            .withOpacity(AppOpacity.muted),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceNight,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s4,
                        vertical: AppSpacing.s2,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                            color: AppColors.brandBrassShadow),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                            color: AppColors.brandBrass, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                            color: AppColors.stateCrimson, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                            color: AppColors.stateCrimsonBright,
                            width: 2),
                      ),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return t.nameValidationRequired;
                      if (v.length > 80) return t.nameValidationTooLong;
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.stateCrimsonBright,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                ],
                AppButton(
                  label: t.createButton,
                  loading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
