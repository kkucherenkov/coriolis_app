import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:coriolis_app/common/app_themes.dart';
import 'package:coriolis_app/common/routes.dart';
import 'package:coriolis_app/localizations.dart';
import 'package:coriolis_app/services/auth_service.dart';
import 'package:coriolis_app/services/theme_provider.dart';
import 'package:coriolis_app/services/language_provider.dart';
import 'package:coriolis_app/services/auth_widget_builder.dart';

import 'package:coriolis_app/login/login_screen.dart';
import 'package:coriolis_app/main/main_screen.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<LanguageProvider>(
          create: (context) => LanguageProvider(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(),
        ),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (_, languageProviderRef, __) {
        return Consumer<ThemeProvider>(
          builder: (_, themeProviderRef, __) {
            return AuthWidgetBuilder(
              builder: (BuildContext context,
                  AsyncSnapshot<FirebaseUser> userSnapshot) {
                return MaterialApp(
                  title: 'Coriolis App',
                  debugShowCheckedModeBanner: false,
                  routes: Routes.routes,
                  locale: languageProviderRef.getLocale, // <- Current locale
                  localizationsDelegates: [
                    const AppLocalizationsDelegate(), // <- Your custom delegate
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.languages.keys
                      .toList(), // <- Supported locales
                  theme: AppThemes.lightTheme,
                  darkTheme: AppThemes.darkTheme,
                  themeMode: themeProviderRef.isDarkModeOn
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  home: (userSnapshot?.data?.uid != null)
                      ? StartScreen()
                      : LoginScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}
