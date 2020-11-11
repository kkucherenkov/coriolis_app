import 'package:flutter/foundation.dart';

@immutable
abstract class LoginState {}

@immutable
class LoginInitialState extends LoginState {}

@immutable
class LoginLoggedInState extends LoginState {}

@immutable
class LoginFailedState extends LoginState {}

@immutable
class LoginLoggedOutState extends LoginState {}

@immutable
class LoginLoggingInState extends LoginState {}
