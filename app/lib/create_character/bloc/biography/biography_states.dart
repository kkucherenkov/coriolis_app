import 'package:coriolis_app/create_character/model/podo/biography_variant.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class BiographyScreenState {}

@immutable
class InitialState extends BiographyScreenState {}

@immutable
class LoadingState extends BiographyScreenState {}

@immutable
class LoadedState extends BiographyScreenState {
  final List<BiographyVariant> biographyData;

  LoadedState({this.biographyData});
}

@immutable
class SubmittingState extends BiographyScreenState {}

@immutable
class SubmittedState extends BiographyScreenState {}
