import 'package:flutter/foundation.dart';

@immutable
abstract class CreateCharacterEvent {}

@immutable
class StartLoadingEvent extends CreateCharacterEvent {}
