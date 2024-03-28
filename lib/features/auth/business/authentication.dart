import 'package:assignment/utils/logger_helper.dart';
import 'package:assignment/utils/show_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      showToast(toastMsg: e.message.toString());
      LoggerHelper.showErrorLog(text: 'error while signing  : ${e.message}');
      return e.message;
    }
  }


  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (err) {
      LoggerHelper.showErrorLog(text: 'error while signing out : $err', );
    }
  }
}
