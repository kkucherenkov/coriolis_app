import 'package:coriolis_app/common/repository.dart';
import 'package:coriolis_app/create_character/bloc/biography/biography_events.dart';
import 'package:coriolis_app/create_character/bloc/biography/biography_states.dart';
import 'package:coriolis_app/create_character/bloc/create_character_events.dart';
import 'package:coriolis_app/create_character/model/create_character_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiographyBloc extends Bloc<CreateCharacterEvent, BiographyScreenState>
    implements RepositoryListener<CreateCharacterEvent> {
  final CreateCharacterRepository repository;

  BiographyBloc({this.repository}) {
    this.repository.addListener(this);
  }

  void dispose() {
    repository.removeListener(this);
  }

  @override
  BiographyScreenState get initialState {
    repository.loadBiographies();
    return InitialState();
  }

  @override
  Stream<BiographyScreenState> mapEventToState(CreateCharacterEvent event) async* {
    if (event is StartLoadingBiographyEvent) {
      yield LoadingState();
    } else if (event is BiographyLoadedEvent) {
      yield LoadedState(biographyData: event.biographyData);
    } else if (event is SubmitBiographyEvent) {
      repository.submitBiography(event.biography);
    }
  }

  @override
  void onRepositoryError(CreateCharacterEvent error) {
    add(error);
  }

  @override
  void onRepositoryEvent(CreateCharacterEvent event) {
    add(event);
  }
}
