import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createClass({
    required String programme,
    required String year,
    required String classCode,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    await firestore.collection('classes').add({
      'programme': programme,
      'year': year,
      'classCode': classCode,
      'createdBy': user.uid,
    });
  }

}