import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:coriolis_app/model/user/user_model.dart';
import 'package:coriolis_app/services/auth_service.dart';

class AuthWidgetBuilder extends StatelessWidget {
  const AuthWidgetBuilder({Key key, @required this.builder}) : super(key: key);
  final Widget Function(BuildContext, AsyncSnapshot<FirebaseUser>) builder;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder<FirebaseUser>(
      stream: authService.user,
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
        final FirebaseUser user = snapshot.data;
        if (user != null) {
          return MultiProvider(
            providers: [
              Provider<FirebaseUser>.value(value: user),
              StreamProvider<UserModel>.value(value: AuthService().streamFirestoreUser(user))
            ],
            child: builder(context, snapshot),
          );
        }
        return builder(context, snapshot);
      },
    );
  }
}
