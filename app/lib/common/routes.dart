import 'package:flutter/material.dart';

import 'package:coriolis_app/login/login_screen.dart';
import 'package:coriolis_app/registration/screen/registration_screen.dart';
import 'package:coriolis_app/settings/settings_screen.dart';

class Routes {
  Routes._(); //this is to prevent anyone from instantiating this object
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String resetPassword = '/reset-password';

  static final routes = <String, WidgetBuilder>{
    signin: (BuildContext context) => LoginScreen(),
    signup: (BuildContext context) => RegistrationScreen(),
    settings: (BuildContext context) => SettingsScreen(),
    // resetPassword: (BuildContext context) => ResetPasswordUI(),
    // updateProfile: (BuildContext context) => UpdateProfileUI(),
  };
}
