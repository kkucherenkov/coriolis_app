import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_app/common/repository.dart';
import 'package:coriolis_app/registration/model/registration_repository.dart';
import 'package:coriolis_app/registration/bloc/registration_events.dart';
import 'package:coriolis_app/registration/bloc/registration_states.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState>
    implements RepositoryListener<RegistrationEvent> {
  final RegistrationRepository repository;

  RegistrationBloc({this.repository}) {
    repository.addListener(this);
  }

  void dispose() {
    repository.removeListener(this);
  }

  @override
  RegistrationState get initialState => InitialState();

  @override
  Stream<RegistrationState> mapEventToState(RegistrationEvent event) async* {
    if (event is SignUpEvent) {
      repository.register(name: event.name, email: event.email, password: event.password);
    } else if (event is GoogleSignUpEvent) {
      repository.doGoogleSignUp();
    } else if (event is RegistratonInProcessEvent) {
      yield SubmittingState();
    } else if (event is RegistratonFailedEvent) {
      yield RegistrationFailedState();
    }
  }

  @override
  void onRepositoryError(RegistrationEvent error) {
    add(error);
  }

  @override
  void onRepositoryEvent(RegistrationEvent event) {
    add(event);
  }
}
