import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_app/main/bloc/main_events.dart';
import 'package:coriolis_app/main/bloc/main_states.dart';
import 'package:coriolis_app/common/repository.dart';
import 'package:coriolis_app/main/model/main_repository.dart';

class MainBloc extends Bloc<MainEvent, MainState> implements RepositoryListener<MainEvent> {
  final MainRepository repository;

  MainBloc({this.repository}) {
    this.repository.addListener(this);
  }

  void dispose() {
    repository.removeListener(this);
  }

  @override
  MainState get initialState {
    return MainInitialState();
  }

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    if (event is CheckUserAuthEvent) {
      repository.checkLoggedIn();
    } else if (event is UserLoggedInEvent) {
      yield LoggedInState();
    } else if (event is UserNotLoggedInEvent) {
      yield NotLoggedInState();
    }
  }

  @override
  void onRepositoryError(MainEvent error) {
    add(error);
  }

  @override
  void onRepositoryEvent(MainEvent event) {
    add(event);
  }
}
