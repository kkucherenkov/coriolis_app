import 'dart:convert';
import 'package:coriolis_app/common/assets_data_manager.dart';
import 'package:coriolis_app/common/repository.dart';
import 'package:coriolis_app/create_character/bloc/biography/biography_events.dart';
import 'package:coriolis_app/create_character/bloc/create_character_events.dart';
import 'package:coriolis_app/create_character/model/podo/biography_variant.dart';

class CreateCharacterRepository extends BaseRepository<CreateCharacterEvent> {
  void loadBiographies() async {
    publishEvent(StartLoadingBiographyEvent());
    Map<String, dynamic> data = await _parseJsonFromAssets('biography');
    List<BiographyVariant> biographies = BiographyVariant.parseList(data);
    publishEvent(BiographyLoadedEvent(biographyData: biographies));
  }

  Future<Map<String, dynamic>> _parseJsonFromAssets(String assetsPath) async {
    return AssetsDataManager()
        .jsonString(assetsPath)
        .then((jsonStr) => jsonDecode(jsonStr));
  }

  void submitBiography(BiographyVariant biography) {}
}
