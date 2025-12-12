import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //Сегментація: використання amail та пароль
      await FirebaseAnalytics.instance.setUserProperty(
        name: 'login_method', 
        value: 'email_password', 
      );

      // Примусова подія
      await FirebaseAnalytics.instance.logEvent(
        name: 'login_successful',
        parameters: {'method': 'email_password'},
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      //Сегментація: використання amail та пароль
      await FirebaseAnalytics.instance.setUserProperty(
        name: 'login_method', 
        value: 'email_password', 
      );

      // Примусова подія 
      await FirebaseAnalytics.instance.logEvent(
        name: 'login_successful',
        parameters: {'method': 'email_password'},
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // Користувач скасував вхід
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      // Сегментація: використання Google
      await FirebaseAnalytics.instance.setUserProperty(
        name: 'login_method', 
        value: 'google', 
      );

      // Примусова подія
      await FirebaseAnalytics.instance.logEvent(
        name: 'login_successful',
        parameters: {'method': 'google'},
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}