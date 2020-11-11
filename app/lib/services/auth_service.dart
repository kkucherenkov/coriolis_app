import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_gravatar/simple_gravatar.dart';

import 'package:coriolis_app/model/user/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  // Firebase user one-time fetch
  Future<FirebaseUser> get getUser => _auth.currentUser();

  // Firebase user a realtime stream
  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  //Streams the firestore user from the firestore collection
  Stream<UserModel> streamFirestoreUser(FirebaseUser firebaseUser) {
    if (firebaseUser?.uid != null) {
      return _db
          .document('/users/${firebaseUser.uid}')
          .snapshots()
          .map((snapshot) => UserModel.fromMap(snapshot.data));
    }
    return null;
  }

  //Method to handle user sign in using email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  // User registration using email and password
  Future<bool> registerWithEmailAndPassword(String name, String email, String password) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((result) async {
        print('uID: ' + result.user.uid);
        print('email: ' + result.user.email);
        //get photo url from gravatar if user has one
        Gravatar gravatar = Gravatar(email);
        String gravatarUrl = gravatar.imageUrl(
          size: 200,
          defaultImage: GravatarImage.retro,
          rating: GravatarRating.pg,
          fileExtension: true,
        );
        //create the new user object
        UserModel _newUser = UserModel(
            uid: result.user.uid, email: result.user.email, name: name, photoUrl: gravatarUrl);
        //update the user in firestore
        _updateUserFirestore(_newUser, result.user);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
        // scopes: [
        //   'email',
        //   'https://www.googleapis.com/auth/contacts.readonly',
        // ],
        );
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      AuthResult result = await _auth.signInWithCredential(credential);
      FirebaseUser user = result.user;
      Gravatar gravatar = Gravatar(user.email);
      String gravatarUrl = gravatar.imageUrl(
        size: 200,
        defaultImage: GravatarImage.retro,
        rating: GravatarRating.pg,
        fileExtension: true,
      );
      UserModel _newUser = UserModel(
          uid: user.uid, email: user.email, name: user.displayName, photoUrl: gravatarUrl);
      _updateUserFirestore(_newUser, result.user);
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  //handles updating the user when updating profile
  Future<bool> updateUser(UserModel user, String oldEmail, String password) async {
    bool _result = false;
    await _auth
        .signInWithEmailAndPassword(email: oldEmail, password: password)
        .then((_firebaseUser) {
      _firebaseUser.user.updateEmail(user.email);
      _updateUserFirestore(user, _firebaseUser.user);
      _result = true;
    });
    return _result;
  }

  //updates the firestore users collection
  void _updateUserFirestore(UserModel user, FirebaseUser firebaseUser) {
    _db.document('/users/${firebaseUser.uid}').setData(user.toJson(), merge: true);
  }

  //password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> isAdmin() async {
    bool _isAdmin = false;
    await _auth.currentUser().then((user) async {
      DocumentSnapshot adminRef = await _db.collection('admin').document(user?.uid).get();
      if (adminRef.exists) {
        _isAdmin = true;
      }
    });
    return _isAdmin;
  }

  // Sign out
  Future<void> signOut() {
    return _auth.signOut();
  }
}
