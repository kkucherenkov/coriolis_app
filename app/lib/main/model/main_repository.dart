import 'package:firebase_auth/firebase_auth.dart';

import 'package:coriolis_app/common/repository.dart';
import 'package:coriolis_app/main/bloc/main_events.dart';

class MainRepository extends BaseRepository<MainEvent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void checkLoggedIn() async {
    var user = await _auth.currentUser();
    if (user == null) {
      publishEvent(UserNotLoggedInEvent());
    } else {
      publishEvent(UserLoggedInEvent());
    }
  }
}
