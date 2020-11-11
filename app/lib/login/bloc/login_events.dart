import 'package:flutter/foundation.dart';

@immutable
abstract class LoginEvent {}

@immutable
class CheckLoginEvent extends LoginEvent {}

@immutable
class DoLoginEvent extends LoginEvent {
  final String username;
  final String password;

  DoLoginEvent({this.username, this.password});
}

@immutable
class DoGoogleLoginEvent extends LoginEvent {
  DoGoogleLoginEvent();
}

@immutable
class LogginInProcessEvent extends LoginEvent {}

@immutable
class UserLoggedInEvent extends LoginEvent {}

@immutable
class UserNotLoggedInEvent extends LoginEvent {}

@immutable
class LoginFailedEvent extends LoginEvent {}
