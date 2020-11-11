import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_app/localizations.dart';
import 'package:coriolis_app/common/utils.dart';

import 'package:coriolis_app/widgets/loading_screen.dart';
import 'package:coriolis_app/widgets/logo_graphic_header.dart';
import 'package:coriolis_app/widgets/form_input_field_with_icon.dart';
import 'package:coriolis_app/widgets/label_button.dart';
import 'package:coriolis_app/widgets/primary_button.dart';
import 'package:coriolis_app/widgets/form_vertical_space.dart';

import 'package:coriolis_app/login/model/login_repository.dart';
import 'package:coriolis_app/login/bloc/login_bloc.dart';
import 'package:coriolis_app/login/bloc/login_events.dart';
import 'package:coriolis_app/login/bloc/login_states.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) {
        return LoginBloc(repository: LoginRepository());
      },
      child: LoginPage(title: 'Coriolis App: Login'),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

  AppLocalizations_Labels labels;

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    labels = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, loginState) {
          if (loginState is LoginFailedState) {
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text(labels.auth.signInError),
              ),
            );
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, loginState) {
            if (loginState is LoginLoggingInState) {
              _loading = true;
            } else {
              _loading = false;
            }

            return LoadingScreen(
              inAsyncCall: _loading,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          LogoGraphicHeader(),
                          SizedBox(height: 48.0),
                          FormInputFieldWithIcon(
                            controller: _email,
                            iconPrefix: Icons.email,
                            labelText: labels.auth.emailFormField,
                            validator: Validator(labels).email,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => null,
                            onSaved: (value) => _email.text = value,
                          ),
                          FormVerticalSpace(),
                          FormInputFieldWithIcon(
                            controller: _password,
                            iconPrefix: Icons.lock,
                            labelText: labels.auth.passwordFormField,
                            validator: Validator(labels).password,
                            obscureText: true,
                            onChanged: (value) => null,
                            onSaved: (value) => _password.text = value,
                            maxLines: 1,
                          ),
                          FormVerticalSpace(),
                          PrimaryButton(
                            labelText: labels.auth.signInButton,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _loginBloc.add(
                                  DoLoginEvent(username: _email.text, password: _password.text),
                                );
                              }
                            },
                          ),
                          FormVerticalSpace(),
                          GoogleSignInButton(
                            onPressed: () {
                              _loginBloc.add(
                                DoGoogleLoginEvent(),
                              );
                            },
                            darkMode: true, // default: false
                          ),
                          FormVerticalSpace(),
                          LabelButton(
                            labelText: labels.auth.resetPasswordLabelButton,
                            onPressed: () =>
                                Navigator.pushReplacementNamed(context, '/reset-password'),
                          ),
                          LabelButton(
                            labelText: labels.auth.signUpLabelButton,
                            onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
