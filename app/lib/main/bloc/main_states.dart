import 'package:flutter/foundation.dart';

@immutable
abstract class MainState {}

@immutable
class MainInitialState extends MainState {}

@immutable
class LoggedInState extends MainState {}

@immutable
class NotLoggedInState extends MainState {}
