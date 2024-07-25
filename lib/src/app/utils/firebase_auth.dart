import 'package:drone_s500/src/app/model/user_settings_crud_model.dart';
import 'package:drone_s500/src/app/model/user_settings_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class FirebaseAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserSetting userSetting;
  UserSettingCrud userSettingCrud = new UserSettingCrud();

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> signInWithEmail(
      String name, String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      if (!user.isEmailVerified)
        return false;
      else
        userSettingCrud.getUserById(user.email, user.uid, name);
    } catch (e) {
      print('Error in signing in  with email');
      return false;
    }

    return true;
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser user = result.user;
      await user.sendEmailVerification();
      if (user == null) return false;
    } catch (e) {
      print('Error in signing up  with email');
      return false;
    }
    return true;
  }

  Future<bool> logOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      print('Error logging out');
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    try {
      var facebookLogin = new FacebookLogin();
      var result = await facebookLogin.logIn(['email']);

      if (result.status == FacebookLoginStatus.loggedIn) {
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );
        final FirebaseUser user =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        if (user == null)
          return false;
        else
          userSettingCrud.getUserById(user.email, user.uid, user.displayName);
      }
    } catch (e) {
      print('Error in logging with facebook');
    }
    return true;
  }

  Future<bool> loginWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount account = await googleSignIn.signIn();
      if (account == null) return false;
      AuthResult res =
      await _auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: (await account.authentication).idToken,
        accessToken: (await account.authentication).accessToken,
      ));

      if (res.user == null)
        return false;
      else
        userSettingCrud.getUserById(
            res.user.email, res.user.uid, res.user.displayName);
    } catch (e) {
      print("Error in logging with google");
      return false;
    }
    return true;
  }
}
