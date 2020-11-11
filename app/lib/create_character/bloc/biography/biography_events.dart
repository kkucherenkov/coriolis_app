import 'package:coriolis_app/create_character/bloc/create_character_events.dart';
import 'package:coriolis_app/create_character/model/podo/biography_variant.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class BiographyEvent extends CreateCharacterEvent {}

@immutable
class SubmitBiographyEvent extends BiographyEvent {
  final BiographyVariant biography;

  SubmitBiographyEvent({this.biography});
}

@immutable
class BiographyLoadedEvent extends CreateCharacterEvent {
  final List<BiographyVariant> biographyData;

  BiographyLoadedEvent({this.biographyData});
}

@immutable
class StartLoadingBiographyEvent extends CreateCharacterEvent {}
