import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String fullName,
    required String registrationNumber,
  }) async {

    final userCredential=
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userId = userCredential.user!.uid;
    print('About to save user to Firestore');


    await firestore.collection('users').doc(userId).set({
      'fullName': fullName,
      'registrationNumber': registrationNumber,
      'email': email,
      'role': 'student',
    });

    print('User saved to Firestore');

    return userCredential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final userCredential =
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential;
  }

}