import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future<bool> googleLogin() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("====================================j====0000");

    try {
      final googleUser = await googleSignIn.signIn();
      print("========================================0000");
      if (googleUser == null) return false; // If canceled the sign in
      _user = googleUser;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await prefs.setString('Uid', credential.accessToken!); // Use ! to assert that accessToken is not null.

      await FirebaseAuth.instance.signInWithCredential(credential);
      notifyListeners();
      return true; // Return true if everything goes well.
    } catch (error) {
      // If any error occurs, print it to the console and return false.
      print(error);
      return false;
    }
  }
}
