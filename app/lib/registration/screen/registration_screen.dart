import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_app/common/utils.dart';
import 'package:coriolis_app/localizations.dart';

import 'package:coriolis_app/registration/bloc/registration_bloc.dart';
import 'package:coriolis_app/registration/bloc/registration_events.dart';
import 'package:coriolis_app/registration/bloc/registration_states.dart';

import 'package:coriolis_app/registration/model/registration_repository.dart';

import 'package:coriolis_app/widgets/form_input_field_with_icon.dart';
import 'package:coriolis_app/widgets/form_vertical_space.dart';
import 'package:coriolis_app/widgets/label_button.dart';
import 'package:coriolis_app/widgets/loading_screen.dart';
import 'package:coriolis_app/widgets/logo_graphic_header.dart';
import 'package:coriolis_app/widgets/primary_button.dart';

class RegistrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegistrationBloc>(
      create: (context) {
        return RegistrationBloc(repository: RegistrationRepository());
      },
      child: RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegistrationPageState();
  }
}

class RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RegistrationBloc _registrationBloc;
  @override
  void initState() {
    super.initState();
    _registrationBloc = BlocProvider.of<RegistrationBloc>(context);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _registrationBloc.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    bool _loading = false;

    return Scaffold(
      key: _scaffoldKey,
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, registrationState) {
          if (registrationState is RegistrationFailedState) {
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text(labels.auth.signUpError),
              ),
            );
          }
        },
        child: BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (context, registrationState) {
            if (registrationState is SubmittingState) {
              _loading = true;
            } else {
              _loading = false;
            }
            return LoadingScreen(
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
                            controller: _name,
                            iconPrefix: Icons.person,
                            labelText: labels.auth.nameFormField,
                            validator: Validator(labels).name,
                            onChanged: (value) => null,
                            onSaved: (value) => _name.text = value,
                          ),
                          FormVerticalSpace(),
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
                            maxLines: 1,
                            onChanged: (value) => null,
                            onSaved: (value) => _password.text = value,
                          ),
                          FormVerticalSpace(),
                          PrimaryButton(
                              labelText: labels.auth.signUpButton,
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  SystemChannels.textInput.invokeMethod(
                                      'TextInput.hide'); //to hide the keyboard - if any
                                  _registrationBloc.add(
                                    SignUpEvent(
                                        name: _name.text,
                                        email: _email.text,
                                        password: _password.text),
                                  );
                                }
                              }),
                          FormVerticalSpace(),
                          LabelButton(
                            labelText: labels.auth.signInLabelButton,
                            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              inAsyncCall: _loading,
              color: Theme.of(context).scaffoldBackgroundColor,
            );
          },
        ),
      ),
    );
  }
}
