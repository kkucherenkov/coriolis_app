import 'package:flutter/services.dart';

class AssetsDataManager {
  Future<String> jsonString(String name) {
    return rootBundle.loadString("assets/data/${name.toLowerCase()}.json");
  }
}
