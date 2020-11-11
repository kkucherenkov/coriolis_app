import 'package:coriolis_app/create_character/screens/biography_screen.dart';
import 'package:coriolis_app/widgets/avatar.dart';
import 'package:coriolis_app/widgets/form_vertical_space.dart';
import 'package:coriolis_app/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:coriolis_app/model/user/user_model.dart';
import 'package:coriolis_app/localizations.dart';

import 'package:coriolis_app/main/bloc/main_bloc.dart';
import 'package:coriolis_app/main/model/main_repository.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MainRepository repository = MainRepository();
    MainBloc _bloc = MainBloc(repository: repository);
    return BlocProvider(
      create: (context) {
        return _bloc;
      },
      child: StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StartPageState();
  }
}

class StartPageState extends State<StartPage> {
  MainBloc _bloc;

  bool _loading = true;
  String _uid = '';
  String _name = '';
  String _email = '';
  String _admin = '';

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<MainBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final UserModel user = Provider.of<UserModel>(context);
    if (user != null) {
      setState(() {
        _loading = false;
        _uid = user.uid;
        _name = user.name;
        _email = user.email;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(labels.home.title),
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return BiographyScreen();
              },
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: LoadingScreen(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 120),
              Avatar(user),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FormVerticalSpace(),
                  Text(labels.home.uidLabel + ': ' + _uid,
                      style: TextStyle(fontSize: 16)),
                  FormVerticalSpace(),
                  Text(labels.home.nameLabel + ': ' + _name,
                      style: TextStyle(fontSize: 16)),
                  FormVerticalSpace(),
                  Text(labels.home.emailLabel + ': ' + _email,
                      style: TextStyle(fontSize: 16)),
                  FormVerticalSpace(),
                  Text(labels.home.adminUserLabel + ': ' + _admin,
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
        inAsyncCall: _loading,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
