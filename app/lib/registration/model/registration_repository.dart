import 'package:coriolis_app/common/repository.dart';
import 'package:coriolis_app/registration/bloc/registration_events.dart';
import 'package:coriolis_app/services/auth_service.dart';

class RegistrationRepository extends BaseRepository<RegistrationEvent> {
  AuthService authService = AuthService();

  void register({String name, String email, String password}) async {
    publishEvent(RegistratonInProcessEvent());
    bool result = await authService.registerWithEmailAndPassword(name, email, password);
    if (!result) {
      publishEvent(RegistratonFailedEvent());
    }
  }

  void doGoogleSignUp() async {
    publishEvent(RegistratonInProcessEvent());
    bool result = await authService.googleSignIn();
    if (!result) {
      publishEvent(RegistratonFailedEvent());
    }
  }
}
