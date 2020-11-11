import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coriolis_app/localizations.dart';
import 'package:coriolis_app/widgets/loading_screen.dart';

import 'package:coriolis_app/create_character/bloc/biography/biography_bloc.dart';
import 'package:coriolis_app/create_character/bloc/biography/biography_states.dart';
import 'package:coriolis_app/create_character/model/create_character_repository.dart';
import 'package:coriolis_app/create_character/model/podo/biography_variant.dart';

class BiographyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CreateCharacterRepository repository = CreateCharacterRepository();
    BiographyBloc _bloc = BiographyBloc(repository: repository);

    return BlocProvider(
      create: (context) {
        return _bloc;
      },
      child: BiographyPage(),
    );
  }
}

class BiographyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BiographyPageState();
  }
}

class BiographyPageState extends State<BiographyPage> {
  bool _loading = true;
  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(labels.home.title),
      ),
      body: BlocListener<BiographyBloc, BiographyScreenState>(
        listener: (context, screenState) {
          if (screenState is SubmittedState) {
            //Noop(),
          }
        },
        child: BlocBuilder<BiographyBloc, BiographyScreenState>(
          builder: (context, screenState) {
            List<BiographyVariant> backgrounds = List();
            if (screenState is LoadingState) {
              _loading = true;
            } else if (screenState is SubmittingState) {
              _loading = true;
            } else {
              _loading = false;
              if (screenState is LoadedState) {
                backgrounds.clear();
                backgrounds.addAll(screenState.biographyData);
              }
            }
            return LoadingScreen(
                child: ListView.builder(
                    itemCount: backgrounds.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Column(
                          children: [
                            Text(
                              backgrounds[index].title,
                              style: Theme.of(context).textTheme.title,
                            ),
                            Text(
                              backgrounds[index].description,
                              style: Theme.of(context).textTheme.subhead,
                            ),
                          ],
                        ),
                      );
                    }),
                inAsyncCall: _loading,
                color: Theme.of(context).scaffoldBackgroundColor);
          },
        ),
      ),
    );
  }
}
