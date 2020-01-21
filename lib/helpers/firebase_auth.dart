import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<FirebaseUser> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    return result.user;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<bool> checkIfUsernameExists(String userName) async {
    try {
      final response = await Firestore.instance
          .collection("users")
          .where("user_name", isEqualTo: userName)
          .getDocuments();
      if (response.documents.isNotEmpty) return true;
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> addUserToDatabase(String userId, Map<String,String> newUser) async {
    final Map<String, dynamic> userData = {
      "id": userId,
      "name": newUser["name"],
      "email": newUser["email"],
      "role": newUser["role"],
      "image_url": "NA",
    };

    try {
      await Firestore.instance
          .collection("users")
          .document(userId)
          .setData(userData);
    } catch (error) {
      throw error;
    }
  }
}