import 'package:coriolis_app/services/auth_service.dart';
import 'package:coriolis_app/common/repository.dart';
import 'package:coriolis_app/login/bloc/login_events.dart';

class LoginRepository extends BaseRepository<LoginEvent> {
  AuthService authService = AuthService();

  void doGoogleLogin() async {
    publishEvent(LogginInProcessEvent());
    bool result = await authService.googleSignIn();
    if (!result) {
      publishEvent(LoginFailedEvent());
    }
  }

  void doLogin({String username, String password}) async {
    publishEvent(LogginInProcessEvent());

    bool result = await authService.signInWithEmailAndPassword(username, password);
    if (!result) {
      publishEvent(LoginFailedEvent());
    }
  }
}
