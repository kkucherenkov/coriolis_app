import 'package:coriolis_app/common/repository.dart';
import 'package:coriolis_app/login/model/login_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coriolis_app/login/bloc/login_events.dart';
import 'package:coriolis_app/login/bloc/login_states.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> implements RepositoryListener<LoginEvent> {
  final LoginRepository repository;

  LoginBloc({this.repository}) {
    repository.addListener(this);
  }

  void dispose() {
    repository.removeListener(this);
  }

  @override
  get initialState {
    return LoginInitialState();
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is DoLoginEvent) {
      repository.doLogin(username: event.username, password: event.password);
    } else if (event is DoGoogleLoginEvent) {
      repository.doGoogleLogin();
    } else if (event is LogginInProcessEvent) {
      yield LoginLoggingInState();
    } else if (event is LoginFailedEvent) {
      yield LoginFailedState();
    }
  }

  @override
  void onRepositoryError(LoginEvent error) {
    add(error);
  }

  @override
  void onRepositoryEvent(LoginEvent event) {
    add(event);
  }
}
