import 'package:flutter/foundation.dart';

@immutable
abstract class RegistrationState {}

@immutable
class InitialState extends RegistrationState {}

@immutable
class SubmittingState extends RegistrationState {}

@immutable
class RegistrationFailedState extends RegistrationState {}
