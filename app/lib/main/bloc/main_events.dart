import 'package:flutter/foundation.dart';

@immutable
abstract class MainEvent {}

@immutable
class CheckUserAuthEvent extends MainEvent {}

@immutable
class UserLoggedInEvent extends MainEvent {}

@immutable
class UserNotLoggedInEvent extends MainEvent {}
