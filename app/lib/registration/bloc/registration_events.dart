import 'package:flutter/foundation.dart';

@immutable
abstract class RegistrationEvent {}

@immutable
class SignUpEvent extends RegistrationEvent {
  final String name;
  final String email;
  final String password;

  SignUpEvent({this.name, this.email, this.password});
}

@immutable
class GoogleSignUpEvent extends RegistrationEvent {}

@immutable
class RegistratonInProcessEvent extends RegistrationEvent {}

@immutable
class RegistratonFailedEvent extends RegistrationEvent {}
